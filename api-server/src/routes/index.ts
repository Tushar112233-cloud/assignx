import { Router } from 'express';
// Rate limiting disabled for dev
// import { apiLimiter } from '../middleware/rateLimiter';
import authRoutes from './auth.routes';
import uploadRoutes from './upload.routes';
import userRoutes from './user.routes';
import doerRoutes from './doer.routes';
import supervisorRoutes from './supervisor.routes';
import projectRoutes from './project.routes';
import chatRoutes from './chat.routes';
import walletRoutes from './wallet.routes';
import notificationRoutes from './notification.routes';
import supportRoutes from './support.routes';
import communityRoutes from './community.routes';
import marketplaceRoutes from './marketplace.routes';
import expertRoutes from './expert.routes';
import trainingRoutes from './training.routes';
import referenceRoutes from './reference.routes';
import adminRoutes from './admin.routes';
import paymentRoutes from './payment.routes';
import resourcesRoutes from './resources.routes';
import connectRoutes from './connect.routes';
import accessRequestRoutes from './access-request.routes';
import jobRoutes from './job.routes';
import investorRoutes from './investor.routes';

const router = Router();

// router.use(apiLimiter);

router.use('/auth', authRoutes);
router.use('/upload', uploadRoutes);
router.use('/users', userRoutes);
router.use('/profiles', userRoutes); // backward compat alias
router.use('/doers', doerRoutes);
router.use('/supervisors', supervisorRoutes);
router.use('/supervisor', supervisorRoutes);
router.use('/projects', projectRoutes);
router.use('/chat', chatRoutes);
router.use('/wallets', walletRoutes);
router.use('/notifications', notificationRoutes);
router.use('/support', supportRoutes);
router.use('/community', communityRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/experts', expertRoutes);
router.use('/training', trainingRoutes);
router.use('/', referenceRoutes);
router.use('/admin', adminRoutes);
router.use('/payments', paymentRoutes);
router.use('/resources', resourcesRoutes);
router.use('/connect', connectRoutes);
router.use('/access-requests', accessRequestRoutes);
router.use('/jobs', jobRoutes);
router.use('/investors', investorRoutes);

export default router;
