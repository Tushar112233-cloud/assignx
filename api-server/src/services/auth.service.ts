import bcrypt from 'bcryptjs';
import { AuthToken, User, Doer, Supervisor, Admin } from '../models';
import { AccessRequest } from '../models/AccessRequest';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from './jwt.service';
import { sendOTPEmail } from './email.service';
import { AppError } from '../middleware/errorHandler';

const OTP_EXPIRY_MINUTES = 10;
const OTP_MAX_ATTEMPTS = 5;
const OTP_LOCKOUT_MINUTES = 15;
const OTP_RESEND_COOLDOWN_SECONDS = 60;

function generateOTP(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Get the Mongoose model for a given role.
 */
function getModelByRole(role: string): any {
  switch (role) {
    case 'user': return User;
    case 'student': return User;
    case 'professional': return User;
    case 'business': return User;
    case 'doer': return Doer;
    case 'supervisor': return Supervisor;
    case 'admin': return Admin;
    default: throw new AppError(`Invalid role: ${role}`, 400);
  }
}

export const checkAccount = async (email: string, role?: string) => {
  const normalizedEmail = email.toLowerCase().trim();
  if (role) {
    const Model = getModelByRole(role);
    const doc = await Model.findOne({ email: normalizedEmail });

    // Also check AccessRequest for pending applications (supervisor/doer)
    if (!doc && (role === 'supervisor' || role === 'doer')) {
      const pendingRequest = await AccessRequest.findOne({
        email: normalizedEmail,
        role,
        status: 'pending',
      });
      if (pendingRequest) {
        return { available: false, exists: true, conflictingRole: role, pendingApproval: true };
      }
    }

    if (doc) {
      return { available: false, exists: true, conflictingRole: role };
    }

    // Check all other role collections for conflicts
    const allModels: { name: string; model: any }[] = [
      { name: 'user', model: User },
      { name: 'doer', model: Doer },
      { name: 'supervisor', model: Supervisor },
      { name: 'admin', model: Admin },
    ].filter((m) => m.name !== (['student', 'professional', 'business'].includes(role) ? 'user' : role));

    for (const { name, model } of allModels) {
      const conflict = await model.findOne({ email: normalizedEmail });
      if (conflict) {
        return { available: false, exists: true, conflictingRole: name };
      }
    }

    return { available: true, exists: false };
  }
  // Check all collections
  const [user, doer, supervisor, admin] = await Promise.all([
    User.findOne({ email: normalizedEmail }),
    Doer.findOne({ email: normalizedEmail }),
    Supervisor.findOne({ email: normalizedEmail }),
    Admin.findOne({ email: normalizedEmail }),
  ]);
  const exists = !!(user || doer || supervisor || admin);
  return { available: !exists, exists };
};

export const sendOTP = async (email: string, purpose: 'login' | 'signup', role: string) => {
  const normalizedEmail = email.toLowerCase().trim();
  const Model = getModelByRole(role);
  const effectiveRole = ['student', 'professional', 'business'].includes(role) ? 'user' : role;

  const account = await Model.findOne({ email: normalizedEmail });

  if (purpose === 'login' && !account) {
    throw new AppError('No account found for this email. Please sign up first.', 404);
  }

  // For doer login, check activation status
  if (purpose === 'login' && effectiveRole === 'doer' && account) {
    if (!(account as any).isActivated) {
      throw new AppError('Your profile is under review. Please wait for approval.', 403);
    }
  }

  // Supervisor login: must be activated
  if (purpose === 'login' && effectiveRole === 'supervisor' && account) {
    if (!(account as any).isActivated) {
      throw new AppError('Your supervisor account is not activated yet. Please wait for approval.', 403);
    }
  }

  if (purpose === 'signup') {
    if (effectiveRole === 'doer') {
      if (account) {
        throw new AppError('An account with this email already exists. Please login instead.', 409);
      }
    }
    if (effectiveRole === 'supervisor') {
      const existingRequest = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor', status: 'pending' });
      if (existingRequest) {
        throw new AppError('You already have a pending application. Please wait for approval.', 409);
      }
      if (account) {
        throw new AppError('An account with this email already exists. Please login instead.', 409);
      }
    }
  }

  // Check cooldown
  const recentToken = await AuthToken.findOne({
    email: normalizedEmail,
    role: effectiveRole,
    purpose,
  }).sort({ createdAt: -1 });

  if (recentToken) {
    const elapsed = Date.now() - recentToken.createdAt.getTime();
    if (elapsed < OTP_RESEND_COOLDOWN_SECONDS * 1000) {
      const remaining = Math.ceil((OTP_RESEND_COOLDOWN_SECONDS * 1000 - elapsed) / 1000);
      throw new AppError(`Please wait ${remaining} seconds before requesting a new code.`, 429);
    }
  }

  await AuthToken.deleteMany({ email: normalizedEmail, role: effectiveRole, purpose });

  const otp = generateOTP();
  const hashedOTP = await bcrypt.hash(otp, 10);

  await AuthToken.create({
    email: normalizedEmail,
    otp: hashedOTP,
    type: 'otp',
    role: effectiveRole,
    purpose,
    attempts: 0,
    lockedUntil: null,
    expiresAt: new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000),
  });

  await sendOTPEmail(normalizedEmail, otp);

  return {
    success: true,
    message: 'Verification code sent to your email.',
    expiresIn: OTP_EXPIRY_MINUTES * 60,
  };
};

export const verifyOTP = async (email: string, otp: string, purpose: 'login' | 'signup', role: string) => {
  const normalizedEmail = email.toLowerCase().trim();
  const effectiveRole = ['student', 'professional', 'business'].includes(role) ? 'user' : role;

  const authToken = await AuthToken.findOne({ email: normalizedEmail, role: effectiveRole, purpose });
  if (!authToken) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  if (authToken.lockedUntil && authToken.lockedUntil > new Date()) {
    const remaining = Math.ceil((authToken.lockedUntil.getTime() - Date.now()) / 60000);
    throw new AppError(`Too many failed attempts. Try again in ${remaining} minutes.`, 429);
  }

  if (authToken.expiresAt < new Date()) {
    await AuthToken.deleteOne({ _id: authToken._id });
    throw new AppError('Verification code has expired. Please request a new one.', 400);
  }

  const isValid = await bcrypt.compare(otp, authToken.otp);
  if (!isValid) {
    authToken.attempts += 1;
    if (authToken.attempts >= OTP_MAX_ATTEMPTS) {
      authToken.lockedUntil = new Date(Date.now() + OTP_LOCKOUT_MINUTES * 60 * 1000);
      await authToken.save();
      throw new AppError(`Too many failed attempts. Try again in ${OTP_LOCKOUT_MINUTES} minutes.`, 429);
    }
    await authToken.save();
    const remaining = OTP_MAX_ATTEMPTS - authToken.attempts;
    throw new AppError(`Invalid verification code. ${remaining} attempts remaining.`, 400);
  }

  await AuthToken.deleteOne({ _id: authToken._id });

  const Model = getModelByRole(role);
  let account = await Model.findOne({ email: normalizedEmail });

  if (purpose === 'signup') {
    if (account) {
      throw new AppError('Account already exists. Please log in.', 409);
    }
    // For user signup, create account directly
    if (effectiveRole === 'user') {
      account = await User.create({
        email: normalizedEmail,
        userType: ['student', 'professional', 'business'].includes(role) ? role : 'student',
      });
    } else {
      throw new AppError('Use the dedicated signup endpoint for this role.', 400);
    }
  } else {
    if (!account) {
      throw new AppError('No account found. Please sign up first.', 404);
    }
    // For doer login, verify activation
    if (effectiveRole === 'doer' && !(account as any).isActivated) {
      throw new AppError('Your profile is under review. Please wait for approval.', 403);
    }
  }

  const tokenPayload = {
    sub: account._id.toString(),
    email: (account as any).email,
    role: effectiveRole,
  };

  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const refreshHash = await bcrypt.hash(refreshToken, 10);
  (account as any).refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  (account as any).lastLoginAt = new Date();
  await account.save();

  const userData = {
    id: account._id,
    email: (account as any).email,
    fullName: (account as any).fullName,
    avatarUrl: (account as any).avatarUrl,
    role: effectiveRole,
    userType: effectiveRole,
    onboardingCompleted: (account as any).onboardingCompleted ?? true,
  };

  return {
    accessToken,
    refreshToken,
    user: userData,
    profile: userData,
  };
};

/**
 * Doer signup: verify OTP + create Doer doc + AccessRequest.
 * Does NOT issue JWT tokens — doer must be approved by admin first.
 */
export const doerSignup = async (
  email: string,
  otp: string,
  fullName: string,
  metadata: {
    qualification: string;
    experienceLevel: string;
    skills: string[];
    bio?: string | null;
    bankName: string;
    accountNumber: string;
    ifscCode: string;
    upiId?: string | null;
  }
) => {
  const normalizedEmail = email.toLowerCase().trim();

  // Verify OTP
  const authToken = await AuthToken.findOne({ email: normalizedEmail, role: 'doer', purpose: 'signup' });
  if (!authToken) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  if (authToken.lockedUntil && authToken.lockedUntil > new Date()) {
    const remaining = Math.ceil((authToken.lockedUntil.getTime() - Date.now()) / 60000);
    throw new AppError(`Too many failed attempts. Try again in ${remaining} minutes.`, 429);
  }

  if (authToken.expiresAt < new Date()) {
    await AuthToken.deleteOne({ _id: authToken._id });
    throw new AppError('Verification code has expired. Please request a new one.', 400);
  }

  const isValid = await bcrypt.compare(otp, authToken.otp);
  if (!isValid) {
    authToken.attempts += 1;
    if (authToken.attempts >= OTP_MAX_ATTEMPTS) {
      authToken.lockedUntil = new Date(Date.now() + OTP_LOCKOUT_MINUTES * 60 * 1000);
      await authToken.save();
      throw new AppError(`Too many failed attempts. Try again in ${OTP_LOCKOUT_MINUTES} minutes.`, 429);
    }
    await authToken.save();
    const remaining = OTP_MAX_ATTEMPTS - authToken.attempts;
    throw new AppError(`Invalid verification code. ${remaining} attempts remaining.`, 400);
  }

  await AuthToken.deleteOne({ _id: authToken._id });

  // Check if doer already exists
  const existingDoer = await Doer.findOne({ email: normalizedEmail });
  if (existingDoer) {
    throw new AppError('An account with this email already exists.', 409);
  }

  // Create doer record directly (not activated — needs admin approval)
  await Doer.create({
    email: normalizedEmail,
    fullName,
    qualification: metadata.qualification,
    experienceLevel: metadata.experienceLevel,
    skills: metadata.skills || [],
    bio: metadata.bio || '',
    isActivated: false,
    isAccessGranted: false,
    trainingCompleted: false,
    bankDetails: {
      accountName: fullName,
      accountNumber: metadata.accountNumber,
      ifscCode: metadata.ifscCode,
      bankName: metadata.bankName,
      upiId: metadata.upiId || '',
      verified: false,
    },
  });

  // Create access request for admin review
  const existingRequest = await AccessRequest.findOne({ email: normalizedEmail, role: 'doer', status: 'pending' });
  if (!existingRequest) {
    await AccessRequest.create({
      email: normalizedEmail,
      role: 'doer',
      fullName,
      status: 'pending',
      metadata: {
        qualification: metadata.qualification,
        experienceLevel: metadata.experienceLevel,
        skills: metadata.skills,
        bio: metadata.bio || null,
        bankName: metadata.bankName,
        accountNumber: metadata.accountNumber,
        ifscCode: metadata.ifscCode,
        upiId: metadata.upiId || null,
      },
    });
  }

  return {
    success: true,
    message: 'Your profile has been submitted for review. You will be notified once approved.',
  };
};

/**
 * Supervisor signup: verify OTP + create AccessRequest (pending).
 * Does NOT issue JWT tokens or create Supervisor doc (admin must approve first).
 */
export const supervisorSignup = async (
  email: string,
  otp: string,
  fullName: string,
  metadata: {
    qualification: string;
    yearsOfExperience: number;
    expertiseAreas: string[];
    bio?: string | null;
    bankName: string;
    accountNumber: string;
    ifscCode: string;
    upiId?: string | null;
  }
) => {
  const normalizedEmail = email.toLowerCase().trim();

  const authToken = await AuthToken.findOne({ email: normalizedEmail, role: 'supervisor', purpose: 'signup' });
  if (!authToken) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  const isValid = await bcrypt.compare(otp, authToken.otp);
  if (!isValid) {
    throw new AppError('Invalid or expired verification code.', 400);
  }

  await AuthToken.deleteOne({ _id: authToken._id });

  // Check for existing pending request
  const existing = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor', status: 'pending' });
  if (existing) {
    return {
      success: true,
      message: 'Your application is already under review.',
    };
  }

  // Create access request
  await AccessRequest.create({
    email: normalizedEmail,
    role: 'supervisor',
    fullName,
    status: 'pending',
    metadata: {
      qualification: metadata.qualification,
      yearsOfExperience: metadata.yearsOfExperience,
      expertiseAreas: metadata.expertiseAreas,
      bio: metadata.bio || null,
      bankName: metadata.bankName,
      accountNumber: metadata.accountNumber,
      ifscCode: metadata.ifscCode,
      upiId: metadata.upiId || null,
    },
  });

  return {
    success: true,
    message: 'Your application has been submitted for review. You will be notified once approved.',
  };
};

export const refreshTokens = async (token: string) => {
  let decoded;
  try {
    decoded = verifyRefreshToken(token);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }

  const Model = getModelByRole(decoded.role);
  const account = await Model.findById(decoded.sub);
  if (!account) {
    throw new AppError('User not found', 404);
  }

  const accountAny = account as any;
  let tokenFound = false;
  let tokenIndex = -1;
  for (let i = 0; i < accountAny.refreshTokens.length; i++) {
    const match = await bcrypt.compare(token, accountAny.refreshTokens[i].token);
    if (match) {
      tokenFound = true;
      tokenIndex = i;
      break;
    }
  }

  if (!tokenFound) {
    throw new AppError('Refresh token revoked', 401);
  }

  accountAny.refreshTokens.splice(tokenIndex, 1);

  const tokenPayload = {
    sub: account._id.toString(),
    email: accountAny.email,
    role: decoded.role,
  };

  const newAccessToken = generateAccessToken(tokenPayload);
  const newRefreshToken = generateRefreshToken(tokenPayload);

  const refreshHash = await bcrypt.hash(newRefreshToken, 10);
  accountAny.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  await account.save();

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
};

export const logout = async (userId: string, role: string, refreshToken: string) => {
  const Model = getModelByRole(role);
  const account = await Model.findById(userId);
  if (!account) return;

  const accountAny = account as any;
  for (let i = 0; i < accountAny.refreshTokens.length; i++) {
    const match = await bcrypt.compare(refreshToken, accountAny.refreshTokens[i].token);
    if (match) {
      accountAny.refreshTokens.splice(i, 1);
      await account.save();
      break;
    }
  }
};
