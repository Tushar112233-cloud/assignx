import { Router, Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import crypto from 'crypto';
import { authenticate } from '../middleware/auth';
// import { paymentLimiter } from '../middleware/rateLimiter';
import { Project, UserWallet, DoerWallet, SupervisorWallet, WalletTransaction } from '../models';
import { AppError } from '../middleware/errorHandler';

function getWalletModel(role: string): { model: any; field: string } {
  switch (role) {
    case 'user': case 'student': case 'professional': case 'business':
      return { model: UserWallet, field: 'userId' };
    case 'doer':
      return { model: DoerWallet, field: 'doerId' };
    case 'supervisor':
      return { model: SupervisorWallet, field: 'supervisorId' };
    default:
      throw new AppError(`No wallet for role: ${role}`, 400);
  }
}

function getWalletType(role: string): 'user' | 'doer' | 'supervisor' {
  if (['user', 'student', 'professional', 'business'].includes(role)) return 'user';
  if (role === 'doer') return 'doer';
  if (role === 'supervisor') return 'supervisor';
  throw new AppError(`Invalid role: ${role}`, 400);
}

const router = Router();

// POST /payments/create-order
router.post('/create-order', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { amount, projectId, notes } = req.body;
    if (!amount || amount <= 0) throw new AppError('Invalid amount', 400);

    const amountInPaise = Math.round(amount * 100);
    const keyId = process.env.RAZORPAY_KEY_ID;
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!keyId || !keySecret) throw new AppError('Payment gateway not configured', 500);

    // Create real Razorpay order via REST API
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
        notes: { projectId, userId: req.user!.id, ...notes },
      }),
    });

    if (!rzpRes.ok) {
      const errBody = await rzpRes.text();
      console.error('Razorpay order creation failed:', errBody);
      throw new AppError('Failed to create payment order', 500);
    }

    const order = await rzpRes.json() as { id: string; amount: number; currency: string; notes: any };

    res.json({
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId,
      notes: order.notes,
    });
  } catch (err) {
    next(err);
  }
});

// POST /payments/verify
router.post('/verify', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, project_id } = req.body;

    // Verify Razorpay signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || '')
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (expectedSignature !== razorpay_signature) {
      throw new AppError('Payment verification failed', 400);
    }

    // If this is a project payment, update project status to paid
    if (project_id) {
      const project = await Project.findById(project_id);
      if (project) {
        project.payment = {
          ...project.payment,
          isPaid: true,
          paidAt: new Date(),
          paymentId: razorpay_payment_id,
        };
        if (['quoted', 'payment_pending'].includes(project.status)) {
          project.status = 'paid';
          project.statusUpdatedAt = new Date();
          project.statusHistory = project.statusHistory || [];
          project.statusHistory.push({
            fromStatus: 'quoted',
            toStatus: 'paid',
            changedBy: req.user!.id as any,
            notes: 'Payment completed via Razorpay',
            createdAt: new Date(),
          });
        }
        await project.save();
      }
    }

    res.json({ success: true, paymentId: razorpay_payment_id });
  } catch (err) {
    next(err);
  }
});

// POST /payments/wallet-pay
router.post('/wallet-pay', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { projectId, amount } = req.body;
    if (!projectId || !amount) throw new AppError('projectId and amount required', 400);

    const { model: WM, field } = getWalletModel(req.user!.role);
    const wallet = await WM.findOne({ [field]: req.user!.id }).session(session);
    if (!wallet || wallet.balance < amount) throw new AppError('Insufficient balance', 400);

    const project = await Project.findById(projectId).session(session);
    if (!project) throw new AppError('Project not found', 404);

    // Debit wallet
    const balanceBefore = wallet.balance;
    wallet.balance -= amount;
    wallet.totalDebited += amount;
    await wallet.save({ session });

    // Record transaction
    await WalletTransaction.create([{
      walletId: wallet._id,
      walletType: getWalletType(req.user!.role),
      transactionType: 'project_payment',
      amount: -amount,
      status: 'completed',
      description: `Payment for project ${project.projectNumber}`,
      referenceId: projectId,
      referenceType: 'project',
      balanceBefore,
      balanceAfter: wallet.balance,
    }], { session });

    // Update project payment status
    project.payment.isPaid = true;
    project.payment.paidAt = new Date();
    project.payment.paymentId = `wallet_${Date.now()}`;
    if (project.status === 'draft' || project.status === 'pending_payment') {
      project.status = 'pending';
      project.statusUpdatedAt = new Date();
    }
    await project.save({ session });

    await session.commitTransaction();

    const io = req.app.get('io');
    if (io) {
      io.to(`user:${req.user!.id}`).emit('wallet:updated', { balance: wallet.balance });
    }

    res.json({ success: true, balance: wallet.balance, project });
  } catch (err) {
    await session.abortTransaction();
    next(err);
  } finally {
    session.endSession();
  }
});

// POST /payments/partial-pay
router.post('/partial-pay', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { projectId, walletAmount, razorpayPaymentId } = req.body;
    if (!projectId) throw new AppError('projectId required', 400);

    const project = await Project.findById(projectId).session(session);
    if (!project) throw new AppError('Project not found', 404);

    // Debit wallet portion if any
    if (walletAmount > 0) {
      const { model: WM, field } = getWalletModel(req.user!.role);
      const wallet = await WM.findOne({ [field]: req.user!.id }).session(session);
      if (!wallet || wallet.balance < walletAmount) throw new AppError('Insufficient wallet balance', 400);

      const balanceBefore = wallet.balance;
      wallet.balance -= walletAmount;
      wallet.totalDebited += walletAmount;
      await wallet.save({ session });

      await WalletTransaction.create([{
        walletId: wallet._id,
        walletType: getWalletType(req.user!.role),
        transactionType: 'project_payment',
        amount: -walletAmount,
        status: 'completed',
        description: `Partial payment for project ${project.projectNumber}`,
        referenceId: projectId,
        referenceType: 'project',
        balanceBefore,
        balanceAfter: wallet.balance,
      }], { session });
    }

    // Update project payment
    project.payment.isPaid = true;
    project.payment.paidAt = new Date();
    project.payment.paymentId = razorpayPaymentId || `partial_${Date.now()}`;
    if (project.status === 'draft' || project.status === 'pending_payment') {
      project.status = 'pending';
      project.statusUpdatedAt = new Date();
    }
    await project.save({ session });

    await session.commitTransaction();
    res.json({ success: true, project });
  } catch (err) {
    await session.abortTransaction();
    next(err);
  } finally {
    session.endSession();
  }
});

export default router;
