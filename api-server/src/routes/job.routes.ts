import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { Job, JobApplication } from '../models';
import { IJob } from '../models/Job';
import { IJobApplication } from '../models/JobApplication';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// --- Normalize helpers ---

function normalizeJob(job: IJob) {
  const salary = job.salary
    ? `${job.salary.currency} ${job.salary.min.toLocaleString()} - ${job.salary.max.toLocaleString()}`
    : null;

  return {
    id: job._id,
    _id: job._id,
    title: job.title,
    company: job.company,
    company_logo: job.companyLogo || null,
    companyLogo: job.companyLogo || null,
    location: job.location,
    type: job.type,
    category: job.category,
    is_remote: job.isRemote,
    isRemote: job.isRemote,
    salary,
    salary_raw: job.salary || null,
    salaryRaw: job.salary || null,
    description: job.description,
    requirements: job.requirements || [],
    skills: job.skills || [],
    tags: job.skills || [],
    apply_url: job.applyUrl || null,
    applyUrl: job.applyUrl || null,
    posted_by: job.postedBy,
    postedBy: job.postedBy,
    is_active: job.isActive,
    isActive: job.isActive,
    application_count: job.applicationCount || 0,
    applicationCount: job.applicationCount || 0,
    posted_at: job.createdAt,
    postedAt: formatRelativeTime(job.createdAt),
    created_at: job.createdAt,
    updated_at: job.updatedAt,
  };
}

function normalizeApplication(app: IJobApplication & { jobId?: any }) {
  return {
    id: app._id,
    _id: app._id,
    job_id: app.jobId?._id || app.jobId,
    jobId: app.jobId?._id || app.jobId,
    job: app.jobId?._id ? normalizeJob(app.jobId as any) : undefined,
    user_id: app.userId,
    userId: app.userId,
    resume_url: app.resumeUrl,
    resumeUrl: app.resumeUrl,
    cover_letter: app.coverLetter || null,
    coverLetter: app.coverLetter || null,
    status: app.status,
    created_at: app.createdAt,
    updated_at: app.updatedAt,
  };
}

function formatRelativeTime(date: Date): string {
  const now = new Date();
  const diffMs = now.getTime() - new Date(date).getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return '1 day ago';
  if (diffDays < 7) return `${diffDays} days ago`;
  if (diffDays < 30) {
    const weeks = Math.floor(diffDays / 7);
    return weeks === 1 ? '1 week ago' : `${weeks} weeks ago`;
  }
  const months = Math.floor(diffDays / 30);
  return months === 1 ? '1 month ago' : `${months} months ago`;
}

// GET /jobs/my-applications - must be before /:id
router.get('/my-applications', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const applications = await JobApplication.find({ userId: req.user!.id })
      .populate('jobId')
      .sort({ createdAt: -1 });

    res.json({
      applications: applications.map((a) => normalizeApplication(a as any)),
      total: applications.length,
    });
  } catch (err) {
    next(err);
  }
});

// GET /jobs/stats - public stats for hero section
router.get('/stats', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const [activeJobs, companies, applicationsThisMonth] = await Promise.all([
      Job.countDocuments({ isActive: true }),
      Job.distinct('company', { isActive: true }).then((arr) => arr.length),
      JobApplication.countDocuments({
        createdAt: {
          $gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
        },
      }),
    ]);

    res.json({
      active_jobs: activeJobs,
      activeJobs,
      top_companies: companies,
      topCompanies: companies,
      hired_this_month: applicationsThisMonth,
      hiredThisMonth: applicationsThisMonth,
    });
  } catch (err) {
    next(err);
  }
});

// GET /jobs - list jobs (public, with filters)
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const {
      category,
      type,
      remote,
      search,
      page: pageParam,
      perPage: perPageParam,
    } = req.query;

    const filter: Record<string, unknown> = { isActive: true };

    if (category && category !== 'all') filter.category = category;
    if (type && type !== 'all') filter.type = type;
    if (remote === 'true') filter.isRemote = true;

    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { company: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { skills: { $regex: search, $options: 'i' } },
      ];
    }

    const page = Math.max(1, parseInt(pageParam as string) || 1);
    const perPage = Math.min(100, Math.max(1, parseInt(perPageParam as string) || 20));
    const skip = (page - 1) * perPage;

    const [jobs, total] = await Promise.all([
      Job.find(filter).sort({ createdAt: -1 }).skip(skip).limit(perPage),
      Job.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / perPage);

    res.json({
      jobs: jobs.map((j) => normalizeJob(j as IJob)),
      total,
      page,
      totalPages,
    });
  } catch (err) {
    next(err);
  }
});

// GET /jobs/:id - get single job
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const job = await Job.findById(req.params.id);
    if (!job) throw new AppError('Job not found', 404);
    res.json({ job: normalizeJob(job as IJob) });
  } catch (err) {
    next(err);
  }
});

// POST /jobs - create job (admin only)
router.post('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'admin' && req.user!.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const {
      title, company, companyLogo, location, type, category,
      isRemote, salary, description, requirements, skills, applyUrl,
    } = req.body;

    const job = await Job.create({
      title,
      company,
      companyLogo,
      location,
      type,
      category,
      isRemote: isRemote || false,
      salary: salary || undefined,
      description,
      requirements: requirements || [],
      skills: skills || [],
      applyUrl,
      postedBy: req.user!.id,
    });

    res.status(201).json({ job: normalizeJob(job as IJob) });
  } catch (err) {
    next(err);
  }
});

// PUT /jobs/:id - update job (admin only)
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'admin' && req.user!.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const allowedFields = [
      'title', 'company', 'companyLogo', 'location', 'type', 'category',
      'isRemote', 'salary', 'description', 'requirements', 'skills',
      'applyUrl', 'isActive',
    ];

    const updates: Record<string, unknown> = {};
    for (const key of allowedFields) {
      if (req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    }

    const job = await Job.findByIdAndUpdate(req.params.id, updates, {
      new: true,
      runValidators: true,
    });
    if (!job) throw new AppError('Job not found', 404);

    res.json({ job: normalizeJob(job as IJob) });
  } catch (err) {
    next(err);
  }
});

// DELETE /jobs/:id - deactivate job (admin only, soft delete)
router.delete('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'admin' && req.user!.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const job = await Job.findByIdAndUpdate(
      req.params.id,
      { isActive: false },
      { new: true }
    );
    if (!job) throw new AppError('Job not found', 404);

    res.json({ message: 'Job deactivated', job: normalizeJob(job as IJob) });
  } catch (err) {
    next(err);
  }
});

// GET /jobs/:id/applications - list all applications for a job (admin only)
router.get('/:id/applications', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'admin' && req.user!.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const job = await Job.findById(req.params.id);
    if (!job) throw new AppError('Job not found', 404);

    const applications = await JobApplication.find({ jobId: req.params.id })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 });

    const normalized = applications.map((app: any) => ({
      id: app._id,
      _id: app._id,
      job_id: app.jobId,
      user_id: app.userId?._id || app.userId,
      applicant_name: app.userId?.fullName || 'Unknown',
      applicant_email: app.userId?.email || '',
      resume_url: app.resumeUrl,
      cover_letter: app.coverLetter || null,
      status: app.status,
      created_at: app.createdAt,
      updated_at: app.updatedAt,
    }));

    res.json({
      applications: normalized,
      total: normalized.length,
    });
  } catch (err) {
    next(err);
  }
});

// PUT /jobs/:id/applications/:appId/status - update application status (admin only)
router.put('/:id/applications/:appId/status', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (req.user!.role !== 'admin' && req.user!.role !== 'super_admin') {
      throw new AppError('Admin access required', 403);
    }

    const { status } = req.body;
    if (!status || !['applied', 'reviewing', 'shortlisted', 'rejected'].includes(status)) {
      throw new AppError('Valid status is required (applied, reviewing, shortlisted, rejected)', 400);
    }

    const application = await JobApplication.findByIdAndUpdate(
      req.params.appId,
      { status },
      { new: true }
    ).populate('userId', 'fullName email');

    if (!application) throw new AppError('Application not found', 404);

    res.json({
      application: {
        id: application._id,
        status: application.status,
      },
    });
  } catch (err) {
    next(err);
  }
});

// POST /jobs/:id/apply - apply to job (authenticated)
router.post('/:id/apply', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { resumeUrl, coverLetter } = req.body;

    if (!resumeUrl) {
      throw new AppError('Resume URL is required', 400);
    }

    const job = await Job.findById(req.params.id);
    if (!job) throw new AppError('Job not found', 404);
    if (!job.isActive) throw new AppError('This job is no longer accepting applications', 400);

    // Check for duplicate application
    const existing = await JobApplication.findOne({
      jobId: req.params.id,
      userId: req.user!.id,
    });
    if (existing) {
      throw new AppError('You have already applied to this job', 400);
    }

    const application = await JobApplication.create({
      jobId: req.params.id,
      userId: req.user!.id,
      resumeUrl,
      coverLetter,
    });

    // Increment application count
    await Job.findByIdAndUpdate(req.params.id, { $inc: { applicationCount: 1 } });

    res.status(201).json({ application: normalizeApplication(application as any) });
  } catch (err) {
    next(err);
  }
});

export default router;
