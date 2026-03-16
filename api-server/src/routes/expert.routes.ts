import { Router, Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { authenticate } from '../middleware/auth';
import { Expert, ExpertBooking } from '../models';
import { IExpert } from '../models/Expert';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// --- Normalize helper ---
function normalizeExpert(expert: IExpert) {
  return {
    id: expert._id,
    _id: expert._id,
    name: expert.name,
    full_name: expert.name,
    email: expert.email,
    avatar: expert.avatarUrl || null,
    avatar_url: expert.avatarUrl || null,
    designation: expert.designation || expert.title || '',
    headline: expert.title || '',
    bio: expert.bio || '',
    organization: expert.organization || '',
    category: expert.category || expert.specialization || '',
    specialization: expert.specialization || '',
    specializations: expert.specializations || [],
    rating: expert.rating || 0,
    review_count: expert.totalReviews || 0,
    reviewCount: expert.totalReviews || 0,
    total_reviews: expert.totalReviews || 0,
    total_sessions: expert.totalSessions || 0,
    totalSessions: expert.totalSessions || 0,
    hourly_rate: expert.hourlyRate || 0,
    hourlyRate: expert.hourlyRate || 0,
    price_per_session: expert.hourlyRate || 0,
    pricePerSession: expert.hourlyRate || 0,
    response_time: expert.responseTime || 'Under 1 hour',
    responseTime: expert.responseTime || 'Under 1 hour',
    languages: expert.languages || ['English'],
    education: expert.education || '',
    experience: expert.experience || '',
    verified: expert.verificationStatus === 'verified',
    verification_status: expert.verificationStatus || 'pending',
    is_featured: expert.isFeatured || false,
    isFeatured: expert.isFeatured || false,
    is_available: expert.isAvailable !== false,
    isAvailable: expert.isAvailable !== false,
    availability: expert.isAvailable ? 'available' : 'offline',
    is_active: expert.isActive !== false,
    isActive: expert.isActive !== false,
    whatsapp_number: expert.whatsappNumber || '',
    availability_slots: expert.availabilitySlots || [],
    availabilitySlots: expert.availabilitySlots || [],
    currency: 'INR',
    created_at: expert.createdAt,
    updated_at: expert.updatedAt,
  };
}

// GET /experts - with pagination and filters
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const {
      specialization,
      search,
      category,
      status,
      featured,
      page: pageParam,
      perPage: perPageParam,
    } = req.query;

    const filter: Record<string, unknown> = { isActive: true };

    if (specialization) filter.specialization = specialization;
    if (category) filter.category = category;
    if (status) filter.verificationStatus = status;
    if (featured === 'true') filter.isFeatured = true;

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { designation: { $regex: search, $options: 'i' } },
        { specialization: { $regex: search, $options: 'i' } },
        { category: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const page = Math.max(1, parseInt(pageParam as string) || 1);
    const perPage = Math.min(100, Math.max(1, parseInt(perPageParam as string) || 20));
    const skip = (page - 1) * perPage;

    const [experts, total] = await Promise.all([
      Expert.find(filter).sort({ rating: -1 }).skip(skip).limit(perPage),
      Expert.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / perPage);

    res.json({
      experts: experts.map((e) => normalizeExpert(e as IExpert)),
      total,
      page,
      totalPages,
    });
  } catch (err) {
    next(err);
  }
});

// POST /experts (create expert - admin)
router.post('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const {
      fullName, email, headline, designation, organization,
      category, hourlyRate, bio, whatsappNumber,
      specializations, languages, education, experience,
      avatarUrl, responseTime,
    } = req.body;

    const expert = await Expert.create({
      name: fullName,
      email,
      title: headline,
      designation,
      organization,
      category,
      specialization: category,
      specializations: specializations || (category ? [category] : []),
      hourlyRate: hourlyRate || 0,
      bio,
      whatsappNumber,
      languages,
      education,
      experience,
      avatarUrl,
      responseTime,
      verificationStatus: 'verified',
    });

    res.status(201).json({ expert: normalizeExpert(expert as IExpert) });
  } catch (err) {
    next(err);
  }
});

// PUT /experts/bookings/:id/meet-link - Admin: add or update meet link (must be before /:id)
router.put('/bookings/:id/meet-link', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { meetLink } = req.body;
    if (!meetLink) throw new AppError('meetLink is required', 400);

    const booking = await ExpertBooking.findByIdAndUpdate(
      req.params.id,
      { meetLink },
      { new: true, runValidators: true },
    );
    if (!booking) throw new AppError('Booking not found', 404);

    res.json({ booking });
  } catch (err) {
    next(err);
  }
});

// PUT /experts/:id (update expert - admin)
router.put('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const allowedFields = [
      'name', 'email', 'title', 'designation', 'specialization', 'specializations',
      'category', 'bio', 'avatarUrl', 'organization', 'whatsappNumber',
      'hourlyRate', 'responseTime', 'languages', 'education', 'experience',
      'verificationStatus', 'rejectionReason', 'isFeatured', 'isAvailable', 'isActive',
      'availabilitySlots',
      // Accept admin-facing field names too
      'fullName', 'headline',
    ];

    const updates: Record<string, unknown> = {};
    for (const key of allowedFields) {
      if (req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    }

    // Map admin field names to model field names
    if (updates.fullName !== undefined) {
      updates.name = updates.fullName;
      delete updates.fullName;
    }
    if (updates.headline !== undefined) {
      updates.title = updates.headline;
      delete updates.headline;
    }

    const expert = await Expert.findByIdAndUpdate(req.params.id, updates, { new: true, runValidators: true });
    if (!expert) throw new AppError('Expert not found', 404);

    res.json({ expert: normalizeExpert(expert as IExpert) });
  } catch (err) {
    next(err);
  }
});

// DELETE /experts/:id (soft delete)
router.delete('/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const expert = await Expert.findByIdAndUpdate(req.params.id, { isActive: false }, { new: true });
    if (!expert) throw new AppError('Expert not found', 404);

    res.json({ message: 'Expert deactivated', expert: normalizeExpert(expert as IExpert) });
  } catch (err) {
    next(err);
  }
});

// POST /experts/bookings/create-order - Create Razorpay order for expert booking
router.post('/bookings/create-order', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { expertId, amount } = req.body;
    if (!expertId || !amount || amount <= 0) throw new AppError('expertId and valid amount required', 400);

    const expert = await Expert.findById(expertId);
    if (!expert) throw new AppError('Expert not found', 404);

    const amountInPaise = Math.round(amount * 100);
    const keyId = process.env.RAZORPAY_KEY_ID;
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!keyId || !keySecret) throw new AppError('Payment gateway not configured', 500);

    const auth = Buffer.from(`${keyId}:${keySecret}`).toString('base64');
    const rzpRes = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`,
      },
      body: JSON.stringify({
        amount: amountInPaise,
        currency: 'INR',
        notes: { expertId, userId: req.user!.id, type: 'expert_booking' },
      }),
    });

    if (!rzpRes.ok) {
      const errBody = await rzpRes.text();
      console.error('Razorpay order creation failed:', errBody);
      throw new AppError('Failed to create payment order', 500);
    }

    const order = await rzpRes.json() as { id: string; amount: number; currency: string };

    res.json({
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId,
    });
  } catch (err) {
    next(err);
  }
});

// POST /experts/bookings/verify-payment - Verify Razorpay payment and create booking
router.post('/bookings/verify-payment', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const {
      razorpay_order_id, razorpay_payment_id, razorpay_signature,
      expertId, date, time, startTime, endTime, duration, topic, notes, amount, sessionType,
    } = req.body;

    // Verify Razorpay signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || '')
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (expectedSignature !== razorpay_signature) {
      throw new AppError('Payment verification failed', 400);
    }

    // Check the time slot is still available (prevent double-booking)
    const bookingDate = new Date(date);
    const slotTime = startTime || time;
    const existing = await ExpertBooking.findOne({
      expertId,
      date: bookingDate,
      startTime: slotTime,
      status: { $nin: ['cancelled'] },
    });
    if (existing) {
      throw new AppError('This time slot has already been booked. Please select another time.', 409);
    }

    // Calculate platform fee (33.33%)
    const totalAmount = amount || 0;
    const platformFee = Math.round(totalAmount * 0.3333);

    // Create the booking with confirmed payment
    const booking = await ExpertBooking.create({
      expertId,
      userId: req.user!.id,
      date: bookingDate,
      timeSlot: slotTime,
      startTime: slotTime,
      endTime: endTime || '',
      duration: duration || 60,
      topic: topic || '',
      notes: notes || '',
      amount: totalAmount,
      platformFee,
      paymentId: razorpay_payment_id,
      paymentStatus: 'completed',
      status: 'confirmed',
    });

    // Increment expert session count
    await Expert.findByIdAndUpdate(expertId, { $inc: { totalSessions: 1 } });

    res.status(201).json({ booking });
  } catch (err) {
    next(err);
  }
});

// POST /experts/bookings (must be before /:id) - Legacy endpoint, now requires paymentId
router.post('/bookings', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { expertId, date, time, startTime, topic, notes, duration, hourlyRate, paymentId } = req.body;

    // If paymentId is provided, treat as paid booking
    const bookingDate = new Date(date);
    const slotTime = startTime || time;
    const totalAmount = hourlyRate || 0;
    const platformFee = Math.round(totalAmount * 0.3333);

    const booking = await ExpertBooking.create({
      expertId,
      userId: req.user!.id,
      date: bookingDate,
      timeSlot: slotTime,
      startTime: slotTime,
      endTime: '',
      duration: duration || 60,
      topic: topic || '',
      notes: notes || '',
      amount: totalAmount,
      platformFee,
      paymentId: paymentId || undefined,
      paymentStatus: paymentId ? 'completed' : 'pending',
      status: paymentId ? 'confirmed' : 'pending',
    });

    res.status(201).json({ booking });
  } catch (err) {
    next(err);
  }
});

// GET /experts/bookings/me (must be before /:id)
router.get('/bookings/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const bookings = await ExpertBooking.find({ userId: req.user!.id })
      .populate('expertId')
      .sort({ date: -1 });
    res.json({ bookings });
  } catch (err) {
    next(err);
  }
});

// GET /experts/bookings/all - Admin: list all bookings with optional filters
router.get('/bookings/all', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, page: pageParam, perPage: perPageParam } = req.query;
    const filter: Record<string, unknown> = {};
    if (status) filter.status = status;

    const page = Math.max(1, parseInt(pageParam as string) || 1);
    const perPage = Math.min(100, Math.max(1, parseInt(perPageParam as string) || 20));
    const skip = (page - 1) * perPage;

    const [bookings, total] = await Promise.all([
      ExpertBooking.find(filter)
        .populate('expertId')
        .populate('userId', 'name email avatarUrl')
        .sort({ date: -1 })
        .skip(skip)
        .limit(perPage),
      ExpertBooking.countDocuments(filter),
    ]);

    res.json({ bookings, total, page, totalPages: Math.ceil(total / perPage) });
  } catch (err) {
    next(err);
  }
});

// GET /experts/:id
router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const expert = await Expert.findById(req.params.id);
    if (!expert) throw new AppError('Expert not found', 404);
    res.json({ expert: normalizeExpert(expert as IExpert) });
  } catch (err) {
    next(err);
  }
});

// GET /experts/:id/availability?date=YYYY-MM-DD - Get available time slots for a date
router.get('/:id/availability', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { date } = req.query;
    if (!date) throw new AppError('date query param is required (YYYY-MM-DD)', 400);

    const expert = await Expert.findById(req.params.id);
    if (!expert) throw new AppError('Expert not found', 404);

    const requestedDate = new Date(date as string);
    const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    const dayName = dayNames[requestedDate.getUTCDay()];

    // Find the expert's availability for this day of the week
    const daySlot = (expert.availabilitySlots || []).find(
      (s) => s.day.toLowerCase() === dayName,
    );

    // If expert has availability slots defined but NOT for this day, return empty
    const hasSchedule = (expert.availabilitySlots || []).length > 0;
    if (hasSchedule && !daySlot) {
      return res.json({ slots: [], date: date, day: dayName, message: 'Expert is not available on this day' });
    }

    // Generate hourly slots from expert's schedule or use defaults (9-17 if no schedule set)
    let startH = 9;
    let endH = 17;
    if (daySlot) {
      const [sH] = daySlot.startTime.split(':').map(Number);
      const [eH] = daySlot.endTime.split(':').map(Number);
      startH = sH;
      endH = eH;
    }

    // Find already-booked slots for this expert on this date
    const startOfDay = new Date(date as string);
    startOfDay.setUTCHours(0, 0, 0, 0);
    const endOfDay = new Date(date as string);
    endOfDay.setUTCHours(23, 59, 59, 999);

    const bookedSlots = await ExpertBooking.find({
      expertId: req.params.id,
      date: { $gte: startOfDay, $lte: endOfDay },
      status: { $nin: ['cancelled'] },
    }).select('startTime');

    const bookedTimes = new Set(bookedSlots.map((b) => b.startTime));

    // Generate available slots
    const dateStr = date as string;
    const slots = [];
    for (let h = startH; h < endH; h++) {
      const time = `${String(h).padStart(2, '0')}:00`;
      const displayHour = h > 12 ? h - 12 : h === 0 ? 12 : h;
      const ampm = h >= 12 ? 'PM' : 'AM';
      const isBooked = bookedTimes.has(time);

      slots.push({
        id: `${dateStr}-${time}`,
        time,
        displayTime: `${displayHour}:00 ${ampm}`,
        display_time: `${displayHour}:00 ${ampm}`,
        available: !isBooked,
        booked: isBooked,
      });
    }

    // Also check if the expert has availability set for this day at all
    const hasAvailability = !daySlot
      ? true // No schedule set = default availability
      : true;

    res.json({
      date: dateStr,
      expertId: req.params.id,
      dayAvailable: hasAvailability,
      slots,
      bookedCount: bookedTimes.size,
    });
  } catch (err) {
    next(err);
  }
});

// GET /experts/:id/reviews
router.get('/:id/reviews', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const reviews = await ExpertBooking.find({
      expertId: req.params.id,
      rating: { $exists: true, $ne: null },
    })
      .populate('userId', 'name email avatarUrl')
      .sort({ updatedAt: -1 })
      .limit(50);

    const formattedReviews = reviews.map(r => ({
      id: r._id,
      expertId: r.expertId,
      clientId: r.userId,
      bookingId: r._id,
      rating: r.rating,
      comment: r.review || '',
      clientName: (r.userId as any)?.name || 'Anonymous',
      clientAvatar: (r.userId as any)?.avatarUrl || null,
      createdAt: r.updatedAt,
    }));

    res.json({ reviews: formattedReviews });
  } catch (err) {
    next(err);
  }
});

// POST /experts/:id/review
router.post('/:id/review', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { rating, review, bookingId } = req.body;

    if (bookingId) {
      await ExpertBooking.findByIdAndUpdate(bookingId, { rating, review });
    }

    const expert = await Expert.findById(req.params.id);
    if (!expert) throw new AppError('Expert not found', 404);

    const newTotal = expert.totalReviews + 1;
    const newRating = ((expert.rating * expert.totalReviews) + rating) / newTotal;
    expert.rating = Math.round(newRating * 10) / 10;
    expert.totalReviews = newTotal;
    await expert.save();

    res.json({ expert: normalizeExpert(expert as IExpert) });
  } catch (err) {
    next(err);
  }
});

export default router;
