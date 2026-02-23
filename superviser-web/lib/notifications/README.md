# Push Notifications Setup Guide

This guide explains how to set up Web Push notifications for the supervisor web application.

## Prerequisites

- Modern browser (Chrome, Firefox, Edge, Safari 16+)
- HTTPS enabled (required for Service Workers and Push API)
- Node.js installed

## Setup Steps

### 1. Generate VAPID Keys

VAPID (Voluntary Application Server Identification) keys are used to authenticate push notifications.

```bash
# Install web-push globally (if not already installed)
npm install -g web-push

# Generate VAPID keys
npx web-push generate-vapid-keys
```

This will output:

```
=======================================

Public Key:
BNxX...your_public_key_here...ABC

Private Key:
xyz...your_private_key_here...789

=======================================
```

### 2. Configure Environment Variables

Add the generated keys to your `.env.local` file:

```env
# Public key (used in client-side code)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=BNxX...your_public_key_here...ABC

# Private key (used in server-side code for sending notifications)
VAPID_PRIVATE_KEY=xyz...your_private_key_here...789

# Contact email (required by Web Push spec)
VAPID_EMAIL=mailto:your-email@example.com
```

⚠️ **Important**: Never commit your private key to version control!

### 3. Create Database Table

Run the following SQL migration to create the push subscriptions table:

```sql
CREATE TABLE IF NOT EXISTS supervisor_push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supervisor_id UUID NOT NULL REFERENCES supervisors(id) ON DELETE CASCADE,
  endpoint TEXT NOT NULL,
  p256dh_key TEXT NOT NULL,
  auth_key TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(supervisor_id)
);

-- Create index for faster lookups
CREATE INDEX idx_supervisor_push_subscriptions_supervisor_id
ON supervisor_push_subscriptions(supervisor_id);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_supervisor_push_subscriptions_updated_at
  BEFORE UPDATE ON supervisor_push_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 4. Restart Development Server

After adding environment variables, restart your Next.js development server:

```bash
npm run dev
```

### 5. Enable Notifications

1. Navigate to `/dashboard/notifications` in your browser
2. Click "Enable Push Notifications"
3. Grant permission when prompted by the browser
4. Click "Send Test Notification" to verify it's working

## How It Works

### Client-Side Flow

1. User clicks "Enable Push Notifications"
2. App requests notification permission from browser
3. Service Worker registers (`/sw.js`)
4. Push subscription is created with VAPID public key
5. Subscription data is saved to Supabase database

### Server-Side Flow (Sending Notifications)

1. Event occurs (new project, payment, QC submission)
2. Server retrieves supervisor's push subscription from database
3. Server uses web-push library to send notification:

```typescript
import webPush from 'web-push'

webPush.setVapidDetails(
  process.env.VAPID_EMAIL,
  process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
)

await webPush.sendNotification(
  subscription,
  JSON.stringify({
    title: 'New Project',
    body: 'A new project has been submitted',
    icon: '/icon-192x192.png',
    data: { url: '/dashboard' }
  })
)
```

### Notification Types

The system supports these notification types:

- `project_submitted` - New project submission
- `payment_received` - Payment confirmed
- `work_submitted` - Doer submitted work for QC
- `new_message` - New chat message
- `qc_approved` - QC approved
- `qc_rejected` - QC rejected
- `payout_processed` - Payout completed

## Browser Support

| Browser | Version | Support |
|---------|---------|---------|
| Chrome  | 50+     | ✅ Full |
| Firefox | 44+     | ✅ Full |
| Edge    | 79+     | ✅ Full |
| Safari  | 16+     | ✅ Full |
| Opera   | 37+     | ✅ Full |

## Troubleshooting

### "Push notifications are not supported"

- Ensure you're using HTTPS (required for Service Workers)
- Update your browser to the latest version
- Check that Service Workers are enabled in browser settings

### "Notification permission denied"

- User needs to manually enable notifications in browser settings
- On Chrome: Settings > Privacy and Security > Site Settings > Notifications
- On Firefox: Page Info > Permissions > Receive Notifications

### "VAPID keys not configured"

- Ensure `.env.local` file exists with VAPID keys
- Restart the Next.js development server
- Verify environment variables are loaded: `console.log(process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY)`

### Service Worker not updating

- Hard refresh the page (Ctrl+Shift+R / Cmd+Shift+R)
- Clear browser cache and Service Worker in DevTools
- Update SW_VERSION in `/sw.js` to force cache invalidation

## Testing

### Test Notifications in Development

1. Enable notifications in `/dashboard/notifications`
2. Click "Send Test Notification"
3. Verify notification appears in system tray

### Test with Real Events

1. Create a test project in user app
2. Verify supervisor receives "New Project" notification
3. Submit work for QC as a doer
4. Verify supervisor receives "Work Submitted" notification

### Test Background Notifications

1. Enable notifications
2. Close the browser tab
3. Trigger an event (new project, payment)
4. Verify notification still appears in system tray

## Security Notes

- **Private Key**: Never expose your VAPID private key in client-side code
- **HTTPS Only**: Push notifications only work over HTTPS
- **User Permission**: Always request permission before subscribing
- **Subscription Cleanup**: Remove subscriptions when user logs out or disables notifications

## Additional Resources

- [Web Push Notifications Guide](https://web.dev/push-notifications-overview/)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Push API](https://developer.mozilla.org/en-US/docs/Web/API/Push_API)
- [web-push Library](https://github.com/web-push-libs/web-push)
