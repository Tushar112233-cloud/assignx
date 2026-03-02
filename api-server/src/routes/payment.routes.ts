import { Router, Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import crypto from 'crypto';
import { authenticate } from '../middleware/auth';
import { paymentLimiter } from '../middleware/rateLimiter';
import { Project, Wallet, WalletTransaction } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// POST /payments/create-order
router.post('/create-order', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { amount, projectId, notes } = req.body;
    if (!amount || amount <= 0) throw new AppError('Invalid amount', 400);

    // In production, create Razorpay order via their API
    // For now, return a mock order for the test key
    const orderId = `order_${Date.now()}_${Math.random().toString(36).substring(7)}`;

    res.json({
      orderId,
      amount: amount * 100, // Razorpay uses paise
      currency: 'INR',
      keyId: process.env.RAZORPAY_KEY_ID,
      notes: { projectId, userId: req.user!.id, ...notes },
    });
  } catch (err) {
    next(err);
  }
});

// POST /payments/verify
router.post('/verify', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    // Verify signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET!)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (expectedSignature !== razorpay_signature) {
      throw new AppError('Payment verification failed', 400);
    }

    res.json({ success: true, paymentId: razorpay_payment_id });
  } catch (err) {
    next(err);
  }
});

// POST /payments/wallet-pay
router.post('/wallet-pay', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { projectId, amount } = req.body;
    if (!projectId || !amount) throw new AppError('projectId and amount required', 400);

    const wallet = await Wallet.findOne({ profileId: req.user!.id }).session(session);
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
router.post('/partial-pay', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { projectId, walletAmount, razorpayPaymentId } = req.body;
    if (!projectId) throw new AppError('projectId required', 400);

    const project = await Project.findById(projectId).session(session);
    if (!project) throw new AppError('Project not found', 404);

    // Debit wallet portion if any
    if (walletAmount > 0) {
      const wallet = await Wallet.findOne({ profileId: req.user!.id }).session(session);
      if (!wallet || wallet.balance < walletAmount) throw new AppError('Insufficient wallet balance', 400);

      const balanceBefore = wallet.balance;
      wallet.balance -= walletAmount;
      wallet.totalDebited += walletAmount;
      await wallet.save({ session });

      await WalletTransaction.create([{
        walletId: wallet._id,
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
