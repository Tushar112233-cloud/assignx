import bcrypt from 'bcryptjs';
import { AuthToken, Profile } from '../models';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from './jwt.service';
import { sendMagicLinkEmail } from './email.service';
import { AppError } from '../middleware/errorHandler';

import crypto from 'crypto';

const generateToken = (): string => {
  return crypto.randomBytes(32).toString('hex');
};

export const sendMagicLink = async (email: string, role?: string, callbackUrl?: string) => {
  const token = generateToken();
  const hashedToken = await bcrypt.hash(token, 10);
  const sessionId = crypto.randomBytes(16).toString('hex');

  // Remove old tokens for this email + role (keep other portal tokens alive)
  await AuthToken.deleteMany({ email, type: 'magic_link', role: role || '' });

  // Store new token (TTL 10 minutes)
  await AuthToken.create({
    email,
    otp: hashedToken,
    type: 'magic_link',
    role: role || '',
    sessionId,
    verified: false,
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  // Build verification URL (email link marks token as verified)
  const baseUrl = callbackUrl || `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/auth/verify`;
  const signInUrl = `${baseUrl}?email=${encodeURIComponent(email)}&token=${encodeURIComponent(token)}`;

  await sendMagicLinkEmail(email, signInUrl);

  return { success: true, message: 'Check your email for the sign-in link', sessionId };
};

export const verifyOTP = async (email: string, otp: string) => {
  // Find all magic link tokens for this email and match by bcrypt
  const authTokens = await AuthToken.find({ email, type: 'magic_link' });
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
    throw new AppError('Invalid or expired sign-in link', 400);
  }

  // Capture the role the user logged in with (keep token alive until TTL expires)
  const loginRole = matchedToken.role || '';

  // Find or create profile
  let profile = await Profile.findOne({ email });
  if (!profile) {
    profile = await Profile.create({ email, userType: loginRole || 'user' });
  }

  // Use the login role if provided and valid, otherwise fall back to profile's userType
  const effectiveRole = loginRole || profile.userType;

  // Generate tokens
  const tokenPayload = {
    sub: profile._id.toString(),
    email: profile.email,
    role: effectiveRole,
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
 * Mark a magic link token as verified (called when user clicks the email link).
 * Does NOT create a session — the original tab polls for verification.
 * Idempotent: returns success if already verified or already consumed.
 */
export const verifyMagicLink = async (email: string, token: string) => {
  // Find all magic link tokens for this email (could have doer + supervisor)
  const authTokens = await AuthToken.find({ email, type: 'magic_link' });

  if (authTokens.length === 0) {
    // Token was already consumed by the polling tab — still a success
    return { success: true, message: 'Email already verified! You can close this tab.' };
  }

  // Find the token whose hash matches (each portal has a different token)
  for (const authToken of authTokens) {
    const isValid = await bcrypt.compare(token, authToken.otp);
    if (isValid) {
      if (authToken.verified) {
        return { success: true, message: 'Email already verified! You can close this tab.' };
      }
      authToken.verified = true;
      await authToken.save();
      return { success: true, message: 'Email verified! You can close this tab.' };
    }
  }

  // No matching token found — could be expired or wrong link
  throw new AppError('Invalid or expired sign-in link.', 400);
};

/**
 * Check magic link verification status (polled from the original login tab).
 * Returns JWT tokens once the email link has been clicked.
 */
export const checkMagicLinkStatus = async (email: string, sessionId: string) => {
  const authToken = await AuthToken.findOne({ email, type: 'magic_link', sessionId });
  if (!authToken) {
    throw new AppError('No sign-in link found.', 400);
  }

  if (!authToken.verified) {
    return { status: 'pending' as const };
  }

  // Token is verified — generate JWT session
  const loginRole = authToken.role || '';

  // Clean up the used token
  await AuthToken.deleteOne({ _id: authToken._id });

  let profile = await Profile.findOne({ email });
  if (!profile) {
    profile = await Profile.create({ email, userType: loginRole || 'user' });
  }

  const effectiveRole = loginRole || profile.userType;

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
    status: 'verified' as const,
    accessToken,
    refreshToken,
    user: profileData,
    profile: profileData,
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
