import bcrypt from 'bcryptjs';
import { AuthToken, Profile } from '../models';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from './jwt.service';
import { sendMagicLinkEmail } from './email.service';
import { AppError } from '../middleware/errorHandler';

const generateOTP = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export const sendMagicLink = async (email: string) => {
  const otp = generateOTP();
  const hashedOtp = await bcrypt.hash(otp, 10);

  // Remove old tokens for this email
  await AuthToken.deleteMany({ email });

  // Store new token (TTL 10 minutes)
  await AuthToken.create({
    email,
    otp: hashedOtp,
    type: 'magic_link',
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  await sendMagicLinkEmail(email, otp);

  return { success: true, message: 'Check your email for the verification code' };
};

export const verifyOTP = async (email: string, otp: string) => {
  const authToken = await AuthToken.findOne({ email, type: 'magic_link' });
  if (!authToken) {
    throw new AppError('No verification code found. Please request a new one.', 400);
  }

  const isValid = await bcrypt.compare(otp, authToken.otp);
  if (!isValid) {
    throw new AppError('Invalid verification code', 400);
  }

  // Delete used token
  await AuthToken.deleteOne({ _id: authToken._id });

  // Find or create profile
  let profile = await Profile.findOne({ email });
  if (!profile) {
    profile = await Profile.create({ email, userType: 'user' });
  }

  // Generate tokens
  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.userType,
  };

  const accessToken = generateAccessToken(tokenPayload);
  const refreshToken = generateRefreshToken(tokenPayload);

  // Store refresh token hash
  const refreshHash = await bcrypt.hash(refreshToken, 10);
  profile.refreshTokens.push({
    token: refreshHash,
    expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  });
  profile.lastLoginAt = new Date();
  await profile.save();

  return {
    accessToken,
    refreshToken,
    profile: {
      id: profile._id,
      email: profile.email,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      userType: profile.userType,
      onboardingCompleted: profile.onboardingCompleted,
    },
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

  // Verify refresh token exists in stored hashes
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

  // Remove old token
  profile.refreshTokens.splice(tokenIndex, 1);

  // Generate new tokens
  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: profile.userType,
  };

  const newAccessToken = generateAccessToken(tokenPayload);
  const newRefreshToken = generateRefreshToken(tokenPayload);

  // Store new refresh token hash
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

  // Remove matching refresh token
  for (let i = 0; i < profile.refreshTokens.length; i++) {
    const match = await bcrypt.compare(refreshToken, profile.refreshTokens[i].token);
    if (match) {
      profile.refreshTokens.splice(i, 1);
      await profile.save();
      break;
    }
  }
};
