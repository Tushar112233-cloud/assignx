import resend from '../config/resend';

export const sendMagicLinkEmail = async (email: string, signInUrl: string): Promise<void> => {
  const fromEmail = process.env.RESEND_FROM_EMAIL || 'AssignX <noreply@assignx.in>';

  try {
    const result = await resend.emails.send({
      from: fromEmail,
      to: email,
      subject: 'Sign in to AssignX',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #1a1a1a;">Sign in to AssignX</h2>
          <p style="color: #444; font-size: 15px;">Click the button below to sign in to your account. This link expires in 10 minutes.</p>
          <div style="text-align: center; margin: 28px 0;">
            <a href="${signInUrl}" style="display: inline-block; background: #5A7CFF; color: #ffffff; font-size: 16px; font-weight: 600; text-decoration: none; padding: 14px 40px; border-radius: 10px;">
              Sign in to AssignX
            </a>
          </div>
          <p style="color: #888; font-size: 13px;">If the button doesn't work, copy and paste this link into your browser:</p>
          <p style="color: #5A7CFF; font-size: 13px; word-break: break-all;">${signInUrl}</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;" />
          <p style="color: #aaa; font-size: 12px;">If you didn't request this email, you can safely ignore it.</p>
        </div>
      `,
    });

    if (result.error) {
      console.warn(`[EMAIL] Resend failed for ${email}:`, result.error.message);
    } else {
      console.log(`[EMAIL] Sent magic link email to ${email} (id: ${result.data?.id})`);
    }
  } catch (err: any) {
    console.warn(`[EMAIL] Failed to send to ${email}:`, err.message);
  }
};
