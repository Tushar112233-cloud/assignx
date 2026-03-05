import bcrypt from 'bcryptjs';
import { AuthToken, Profile, Doer, Supervisor } from '../models';
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

export const checkAccount = async (email: string) => {
  const profile = await Profile.findOne({ email: email.toLowerCase().trim() });
  return { exists: !!profile };
};

export const sendOTP = async (email: string, purpose: 'login' | 'signup', role?: string) => {
  const normalizedEmail = email.toLowerCase().trim();

  const profile = await Profile.findOne({ email: normalizedEmail });

  if (purpose === 'login' && !profile) {
    throw new AppError('No account found for this email. Please sign up first.', 404);
  }

  // For doer login, check activation status
  if (purpose === 'login' && role === 'doer' && profile) {
    const doer = await Doer.findOne({ profileId: profile._id });
    if (doer && !doer.isActivated) {
      throw new AppError('Your profile is under review. Please wait for approval.', 403);
    }
  }

  // Supervisor login: profile must exist, supervisor record must exist
  if (purpose === 'login' && role === 'supervisor' && profile) {
    const supervisor = await Supervisor.findOne({ profileId: profile._id });
    if (!supervisor) {
      throw new AppError('Your supervisor account is not set up yet. Please wait for approval.', 403);
    }
  }

  if (purpose === 'signup') {
    if (role === 'doer') {
      const existingProfile = await Profile.findOne({ email: normalizedEmail });
      if (existingProfile && existingProfile.userType === 'doer') {
        const doer = await Doer.findOne({ profileId: existingProfile._id });
        if (doer) {
          throw new AppError('An account with this email already exists. Please login instead.', 409);
        }
      }
    }
    if (role === 'supervisor') {
      const existingRequest = await AccessRequest.findOne({ email: normalizedEmail, role: 'supervisor', status: 'pending' });
      if (existingRequest) {
        throw new AppError('You already have a pending application. Please wait for approval.', 409);
      }
      const existingProfile = await Profile.findOne({ email: normalizedEmail, userType: 'supervisor' });
      if (existingProfile) {
        const supervisor = await Supervisor.findOne({ profileId: existingProfile._id });
        if (supervisor) {
          throw new AppError('An account with this email already exists. Please login instead.', 409);
        }
      }
    }
  }

  const recentToken = await AuthToken.findOne({
    email: normalizedEmail,
    purpose,
  }).sort({ createdAt: -1 });

  if (recentToken) {
    const elapsed = Date.now() - recentToken.createdAt.getTime();
    if (elapsed < OTP_RESEND_COOLDOWN_SECONDS * 1000) {
      const remaining = Math.ceil((OTP_RESEND_COOLDOWN_SECONDS * 1000 - elapsed) / 1000);
      throw new AppError(`Please wait ${remaining} seconds before requesting a new code.`, 429);
    }
  }

  await AuthToken.deleteMany({ email: normalizedEmail, purpose });

  const otp = generateOTP();
  const hashedOTP = await bcrypt.hash(otp, 10);

  await AuthToken.create({
    email: normalizedEmail,
    otp: hashedOTP,
    type: 'otp',
    role: role || '',
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

export const verifyOTP = async (email: string, otp: string, purpose: 'login' | 'signup', role?: string) => {
  const normalizedEmail = email.toLowerCase().trim();

  const authToken = await AuthToken.findOne({ email: normalizedEmail, purpose });
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

  let profile = await Profile.findOne({ email: normalizedEmail });

  if (purpose === 'signup') {
    if (profile) {
      throw new AppError('Account already exists. Please log in.', 409);
    }
    const userType = role || 'user';
    profile = await Profile.create({
      email: normalizedEmail,
      userType,
    });
  } else {
    if (!profile) {
      throw new AppError('No account found. Please sign up first.', 404);
    }
    // For doer login, verify activation
    if (role === 'doer') {
      const doer = await Doer.findOne({ profileId: profile._id });
      if (doer && !doer.isActivated) {
        throw new AppError('Your profile is under review. Please wait for approval.', 403);
      }
    }
  }

  const effectiveRole = role || profile.userType;
  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: effectiveRole,
  };

  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  const refreshHash = await bcrypt.hash(refreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  profile.lastLoginAt = new Date();
  await profile.save();

  const profileData = {
    id: profile._id,
    email: profile.email,
    fullName: profile.fullName,
    avatarUrl: profile.avatarUrl,
    userType: effectiveRole,
    onboardingCompleted: profile.onboardingCompleted,
  };

  return {
    accessToken,
    refreshToken,
    user: profileData,
    profile: profileData,
  };
};

/**
 * Doer signup: verify OTP + create Profile + Doer + AccessRequest.
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

  // Verify OTP (signup purpose)
  const authToken = await AuthToken.findOne({ email: normalizedEmail, purpose: 'signup' });
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

  // OTP is valid — clean up
  await AuthToken.deleteOne({ _id: authToken._id });

  // Create or find profile
  let profile = await Profile.findOne({ email: normalizedEmail });
  if (profile) {
    const existingDoer = await Doer.findOne({ profileId: profile._id });
    if (existingDoer) {
      throw new AppError('An account with this email already exists.', 409);
    }
    // Update existing profile to doer type
    profile.userType = 'doer';
    profile.fullName = fullName;
    await profile.save();
  } else {
    profile = await Profile.create({
      email: normalizedEmail,
      fullName,
      userType: 'doer',
      onboardingCompleted: false,
    });
  }

  // Create doer record (not activated — needs admin approval)
  await Doer.create({
    profileId: profile._id,
    qualification: metadata.qualification,
    experienceLevel: metadata.experienceLevel,
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
 * Verify OTP for supervisor signup — creates AccessRequest (pending).
 * Does NOT issue JWT tokens or create Profile (admin must approve first).
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
  // Find and verify OTP
  const authTokens = await AuthToken.find({ email, type: 'otp_signup' });
  if (authTokens.length === 0) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  let matchedToken = null;
  for (const at of authTokens) {
    const isValid = await bcrypt.compare(otp, at.otp);
    if (isValid) {
      matchedToken = at;
      break;
    }
  }

  if (!matchedToken) {
    throw new AppError('Invalid or expired verification code.', 400);
  }

  // Clean up used token
  await AuthToken.deleteOne({ _id: matchedToken._id });

  // Check for existing pending request
  const existing = await AccessRequest.findOne({ email, role: 'supervisor', status: 'pending' });
  if (existing) {
    return {
      success: true,
      message: 'Your application is already under review.',
    };
  }

  // Create access request
  await AccessRequest.create({
    email,
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

export const refreshTokens = async (refreshToken: string) => {
  let decoded;
  try {
    decoded = verifyRefreshToken(refreshToken);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }

  const profile = await Profile.findById(decoded.sub);
  if (!profile) {
    throw new AppError('User not found', 404);
  }

  let tokenFound = false;
  let tokenIndex = -1;
  for (let i = 0; i < profile.refreshTokens.length; i++) {
    const match = await bcrypt.compare(refreshToken, profile.refreshTokens[i].token);
    if (match) {
      tokenFound = true;
      tokenIndex = i;
      break;
    }
  }

  if (!tokenFound) {
    throw new AppError('Refresh token revoked', 401);
  }

  profile.refreshTokens.splice(tokenIndex, 1);

  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.userType,
  };

  const newAccessToken = generateAccessToken(tokenPayload);
  const newRefreshToken = generateRefreshToken(tokenPayload);

  const refreshHash = await bcrypt.hash(newRefreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  await profile.save();

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
};

export const logout = async (profileId: string, refreshToken: string) => {
  const profile = await Profile.findById(profileId);
  if (!profile) return;

  for (let i = 0; i < profile.refreshTokens.length; i++) {
    const match = await bcrypt.compare(refreshToken, profile.refreshTokens[i].token);
    if (match) {
      profile.refreshTokens.splice(i, 1);
      await profile.save();
      break;
    }
  }
};
