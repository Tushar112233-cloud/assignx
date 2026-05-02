import resend from '../config/resend';

export const sendOTPEmail = async (email: string, otp: string): Promise<void> => {
  const fromEmail = process.env.RESEND_FROM_EMAIL || 'AssignX <noreply@assignx.in>';

  // In dev mode, log OTP to file for easy access
  if (process.env.NODE_ENV !== 'production') {
    const fs = await import('fs');
    const os = await import('os');
    const path = await import('path');
    const logLine = `[DEV-OTP] ${new Date().toISOString()} | ${email} | OTP: ${otp}\n`;
    fs.appendFileSync(path.join(os.tmpdir(), 'api-server.log'), logLine);
    console.log(`[DEV-OTP] ${email} -> ${otp}`);
  }

  try {
    const result = await resend.emails.send({
      from: fromEmail,
      to: email,
      subject: 'Your AssignX verification code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #1a1a1a;">Your verification code</h2>
          <p style="color: #444; font-size: 15px;">Use the code below to verify your email. It expires in 10 minutes.</p>
          <div style="text-align: center; margin: 28px 0;">
            <div style="display: inline-block; background: #F7F9FF; border: 2px solid #5A7CFF; border-radius: 12px; padding: 16px 40px; letter-spacing: 8px; font-size: 32px; font-weight: 700; color: #1a1a1a;">
              ${otp}
            </div>
          </div>
          <p style="color: #888; font-size: 13px;">If you didn't request this code, you can safely ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;" />
          <p style="color: #aaa; font-size: 12px;">This is an automated message from AssignX.</p>
        </div>
      `,
    });

    if (result.error) {
      console.warn(`[EMAIL] OTP send failed for ${email}:`, result.error.message);
    } else {
      console.log(`[EMAIL] Sent OTP email to ${email} (id: ${result.data?.id})`);
    }
  } catch (err: any) {
    console.warn(`[EMAIL] Failed to send OTP to ${email}:`, err.message);
  }
};
