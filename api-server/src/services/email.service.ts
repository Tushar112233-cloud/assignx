import resend from '../config/resend';

export const sendMagicLinkEmail = async (email: string, otp: string): Promise<void> => {
  const fromEmail = process.env.RESEND_FROM_EMAIL || 'AssignX <noreply@assignx.com>';

  try {
    const result = await resend.emails.send({
      from: fromEmail,
      to: email,
      subject: 'Your AssignX Login Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #1a1a1a;">Welcome to AssignX</h2>
          <p>Your verification code is:</p>
          <div style="background: #f5f5f5; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #1a1a1a;">${otp}</span>
          </div>
          <p style="color: #666; font-size: 14px;">This code expires in 10 minutes. Do not share it with anyone.</p>
        </div>
      `,
    });

    if (result.error) {
      console.warn(`[EMAIL] Resend failed for ${email}:`, result.error.message);
      console.warn(`[EMAIL] OTP for ${email}: ${otp} (logged because email delivery failed)`);
    } else {
      console.log(`[EMAIL] Sent OTP email to ${email} (id: ${result.data?.id})`);
    }
  } catch (err: any) {
    console.warn(`[EMAIL] Failed to send to ${email}:`, err.message);
    console.warn(`[EMAIL] OTP for ${email}: ${otp} (logged because email delivery failed)`);
  }
};
