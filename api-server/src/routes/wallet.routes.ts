import { Router, Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { authenticate } from '../middleware/auth';
import { paymentLimiter } from '../middleware/rateLimiter';
import { UserWallet, DoerWallet, SupervisorWallet, WalletTransaction, PayoutRequest } from '../models';
import { AppError } from '../middleware/errorHandler';

const router = Router();

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

// GET /wallets/me
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    let wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet) {
      wallet = await WalletModel.create({ [field]: req.user!.id });
    }
    res.json({ wallet });
  } catch (err) {
    next(err);
  }
});

// GET /wallets/transactions (frontend-compatible path)
router.get('/transactions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', type } = req.query;
    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    const wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet) return res.json({ transactions: [], total: 0 });

    const filter: Record<string, unknown> = { walletId: wallet._id };
    if (type) filter.transactionType = type;

    const skip = (Number(page) - 1) * Number(limit);
    const [transactions, total] = await Promise.all([
      WalletTransaction.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      WalletTransaction.countDocuments(filter),
    ]);

    res.json({ transactions, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// GET /wallets/me/transactions
router.get('/me/transactions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page = '1', limit = '20', type } = req.query;
    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    const wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet) return res.json({ transactions: [], total: 0 });

    const filter: Record<string, unknown> = { walletId: wallet._id };
    if (type) filter.transactionType = type;

    const skip = (Number(page) - 1) * Number(limit);
    const [transactions, total] = await Promise.all([
      WalletTransaction.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
      WalletTransaction.countDocuments(filter),
    ]);

    res.json({ transactions, total, page: Number(page), totalPages: Math.ceil(total / Number(limit)) });
  } catch (err) {
    next(err);
  }
});

// POST /wallets/transfer
router.post('/transfer', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { toRole, toId, amount, description } = req.body;
    if (!toRole || !toId || !amount || amount <= 0) throw new AppError('Invalid transfer parameters', 400);

    const { model: FromWalletModel, field: fromField } = getWalletModel(req.user!.role);
    const fromWallet = await FromWalletModel.findOne({ [fromField]: req.user!.id }).session(session);
    if (!fromWallet) throw new AppError('Source wallet not found', 404);
    if (fromWallet.balance < amount) throw new AppError('Insufficient balance', 400);

    const { model: ToWalletModel, field: toField } = getWalletModel(toRole);
    let toWallet = await ToWalletModel.findOne({ [toField]: toId }).session(session);
    if (!toWallet) {
      const created = await ToWalletModel.create([{ [toField]: toId }], { session });
      toWallet = created[0];
    }

    // Debit source
    fromWallet.balance -= amount;
    fromWallet.totalDebited += amount;
    await fromWallet.save({ session });

    // Credit destination
    toWallet!.balance += amount;
    toWallet!.totalCredited += amount;
    await toWallet!.save({ session });

    const fromWalletType = getWalletType(req.user!.role);
    const toWalletType = getWalletType(toRole);

    // Create transactions
    await WalletTransaction.create([
      {
        walletId: fromWallet._id,
        walletType: fromWalletType,
        transactionType: 'transfer_out',
        amount: -amount,
        status: 'completed',
        description: description || 'Transfer',
        balanceBefore: fromWallet.balance + amount,
        balanceAfter: fromWallet.balance,
      },
      {
        walletId: toWallet!._id,
        walletType: toWalletType,
        transactionType: 'transfer_in',
        amount,
        status: 'completed',
        description: description || 'Transfer received',
        balanceBefore: toWallet!.balance - amount,
        balanceAfter: toWallet!.balance,
      },
    ], { session });

    await session.commitTransaction();

    const io = req.app.get('io');
    if (io) {
      io.to(`user:${req.user!.id}`).emit('wallet:updated', { balance: fromWallet.balance });
      io.to(`user:${toId}`).emit('wallet:updated', { balance: toWallet!.balance });
    }

    res.json({ success: true, balance: fromWallet.balance });
  } catch (err) {
    await session.abortTransaction();
    next(err);
  } finally {
    session.endSession();
  }
});

// POST /wallets/topup
router.post('/topup', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    const { amount, paymentId } = req.body;
    if (!amount || amount <= 0) throw new AppError('Invalid amount', 400);

    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    let wallet = await WalletModel.findOne({ [field]: req.user!.id }).session(session);
    if (!wallet) {
      const created = await WalletModel.create([{ [field]: req.user!.id }], { session });
      wallet = created[0];
    }

    const balanceBefore = wallet!.balance;
    wallet!.balance += amount;
    wallet!.totalCredited += amount;
    await wallet!.save({ session });

    await WalletTransaction.create([{
      walletId: wallet!._id,
      walletType: getWalletType(req.user!.role),
      transactionType: 'topup',
      amount,
      status: 'completed',
      description: 'Wallet top-up',
      referenceId: paymentId,
      referenceType: 'razorpay',
      balanceBefore,
      balanceAfter: wallet!.balance,
    }], { session });

    await session.commitTransaction();

    const io = req.app.get('io');
    if (io) io.to(`user:${req.user!.id}`).emit('wallet:updated', { balance: wallet!.balance });

    res.json({ success: true, balance: wallet!.balance });
  } catch (err) {
    await session.abortTransaction();
    next(err);
  } finally {
    session.endSession();
  }
});

// POST /wallets/payout-request
router.post('/payout-request', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { amount, payoutMethod } = req.body;
    if (!amount || amount <= 0) throw new AppError('Invalid amount', 400);

    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    const wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet || wallet.balance < amount) throw new AppError('Insufficient balance', 400);

    const payout = await PayoutRequest.create({
      recipientId: req.user!.id,
      recipientRole: getWalletType(req.user!.role),
      amount,
      payoutMethod: payoutMethod || 'bank_transfer',
    });

    res.status(201).json({ payout });
  } catch (err) {
    next(err);
  }
});

// GET /wallets/earnings/monthly
router.get('/earnings/monthly', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    const wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet) return res.json({ earnings: [] });

    const earnings = await WalletTransaction.aggregate([
      { $match: { walletId: wallet._id, amount: { $gt: 0 }, status: 'completed' } },
      {
        $group: {
          _id: { year: { $year: '$createdAt' }, month: { $month: '$createdAt' } },
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.year': -1, '_id.month': -1 } },
      { $limit: 12 },
    ]);

    res.json({ earnings });
  } catch (err) {
    next(err);
  }
});

// GET /wallets/earnings/summary
router.get('/earnings/summary', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    const wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet) return res.json({ summary: { balance: 0, totalEarned: 0, totalWithdrawn: 0 } });

    const now = new Date();
    const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const monthlyEarnings = await WalletTransaction.aggregate([
      { $match: { walletId: wallet._id, amount: { $gt: 0 }, status: 'completed', createdAt: { $gte: thisMonth } } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    res.json({
      summary: {
        balance: wallet.balance,
        totalCredited: wallet.totalCredited,
        totalDebited: wallet.totalDebited,
        totalWithdrawn: wallet.totalWithdrawn,
        lockedAmount: wallet.lockedAmount,
        thisMonthEarnings: monthlyEarnings[0]?.total || 0,
      },
    });
  } catch (err) {
    next(err);
  }
});

// GET /wallets/me/transactions/:id - Get single transaction
router.get('/me/transactions/:id', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const transaction = await WalletTransaction.findById(req.params.id);
    if (!transaction) throw new AppError('Transaction not found', 404);
    res.json(transaction);
  } catch (err) {
    next(err);
  }
});

// POST /wallets/me/withdraw - Request withdrawal
router.post('/me/withdraw', authenticate, paymentLimiter, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { amount, paymentMethod } = req.body;
    if (!amount || amount <= 0) throw new AppError('Invalid amount', 400);

    const { model: WalletModel, field } = getWalletModel(req.user!.role);
    const wallet = await WalletModel.findOne({ [field]: req.user!.id });
    if (!wallet || wallet.balance < amount) throw new AppError('Insufficient balance', 400);

    const payout = await PayoutRequest.create({
      recipientId: req.user!.id,
      recipientRole: getWalletType(req.user!.role),
      amount,
      payoutMethod: paymentMethod || 'bank_transfer',
    });

    // Create a pending transaction
    const transaction = await WalletTransaction.create({
      walletId: wallet._id,
      walletType: getWalletType(req.user!.role),
      transactionType: 'withdrawal',
      amount: -amount,
      status: 'pending',
      description: 'Withdrawal request',
      referenceId: payout._id.toString(),
      referenceType: 'payout',
      balanceBefore: wallet.balance,
      balanceAfter: wallet.balance,
    });

    res.json(transaction);
  } catch (err) {
    next(err);
  }
});

export default router;
