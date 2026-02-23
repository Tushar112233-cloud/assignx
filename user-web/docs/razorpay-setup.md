# Razorpay Payment Integration - Setup Guide

**Status:** ✅ Configured for Testing
**Environment:** Test Mode
**Last Updated:** 2026-01-02

---

## 🔑 Credentials (Test Mode)

Currently configured with **Razorpay Test API** credentials for development and testing:

```env
RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf
RAZORPAY_KEY_SECRET=p2ZIwNBpnf1Gh7icvCm6oicD
NEXT_PUBLIC_RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf
```

**⚠️ Important:**
- These are **TEST credentials** - they will NOT process real payments
- Use test card numbers from [Razorpay Test Cards](https://razorpay.com/docs/payments/payments/test-card-details/)
- Switch to **LIVE credentials** before production deployment

---

## 📱 Platform Configuration

### Web App (user-web) - Next.js

**Configuration File:** [.env.local](../.env.local)

```env
# Server-side secret (DO NOT expose to client)
RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf
RAZORPAY_KEY_SECRET=p2ZIwNBpnf1Gh7icvCm6oicD

# Client-side public key
NEXT_PUBLIC_RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf
```

**Usage in Code:**

```typescript
// Server-side (API routes, server actions)
import { env } from "@/lib/env"
const keyId = env.RAZORPAY_KEY_ID
const keySecret = env.RAZORPAY_KEY_SECRET

// Client-side (components)
import { clientEnv } from "@/lib/env"
const keyId = clientEnv.NEXT_PUBLIC_RAZORPAY_KEY_ID
```

**Key Files:**
- [lib/env.ts](../lib/env.ts) - Environment variable validation
- [app/api/payments/create-order/route.ts](../app/api/payments/create-order/route.ts) - Order creation API
- [app/api/payments/verify/route.ts](../app/api/payments/verify/route.ts) - Payment verification API
- [components/payments/razorpay-checkout.tsx](../components/payments/razorpay-checkout.tsx) - Checkout component

### Mobile App (user_app) - Flutter

**Configuration File:** [lib/core/config/razorpay_config.dart](../../user_app/lib/core/config/razorpay_config.dart)

```dart
class RazorpayConfig {
  static const String testApiKey = 'rzp_test_Rv45IObrwfKRyf';
  static const String testKeySecret = 'p2ZIwNBpnf1Gh7icvCm6oicD';
  static const bool isTestMode = true;
}
```

**Build with Custom Keys:**
```bash
flutter run \
  --dart-define=RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf \
  --dart-define=RAZORPAY_KEY_SECRET=p2ZIwNBpnf1Gh7icvCm6oicD \
  --dart-define=RAZORPAY_TEST_MODE=true
```

**Key Files:**
- [lib/core/config/razorpay_config.dart](../../user_app/lib/core/config/razorpay_config.dart) - Configuration
- [lib/core/services/payment_service.dart](../../user_app/lib/core/services/payment_service.dart) - Payment service

---

## 🧪 Testing Payments

### Test Card Details

**Successful Payment:**
```
Card Number: 4111 1111 1111 1111
CVV: Any 3 digits
Expiry: Any future date
Name: Any name
```

**Failed Payment:**
```
Card Number: 4000 0000 0000 0002
CVV: Any 3 digits
Expiry: Any future date
```

**More Test Cards:** https://razorpay.com/docs/payments/payments/test-card-details/

### Test UPI IDs

- **Success:** `success@razorpay`
- **Failure:** `failure@razorpay`

### Test Wallets

All test wallets will show a success screen without actual deduction.

---

## 🔄 Payment Flow

### Web Application

1. **Create Order** (Server-side):
   ```typescript
   POST /api/payments/create-order
   {
     "amount": 10000, // in paise (₹100)
     "currency": "INR"
   }
   ```

2. **Initialize Razorpay Checkout** (Client-side):
   ```typescript
   const options = {
     key: NEXT_PUBLIC_RAZORPAY_KEY_ID,
     amount: order.amount,
     order_id: order.id,
     name: "AssignX",
     description: "Payment for assignment",
     handler: function(response) {
       // Verify payment
     }
   }
   const razorpay = new window.Razorpay(options)
   razorpay.open()
   ```

3. **Verify Payment** (Server-side):
   ```typescript
   POST /api/payments/verify
   {
     "razorpay_order_id": "order_xxx",
     "razorpay_payment_id": "pay_xxx",
     "razorpay_signature": "xxx"
   }
   ```

### Mobile Application

1. **Create Order** via API call to backend
2. **Open Razorpay Checkout**:
   ```dart
   final options = RazorpayConfig.createCheckoutOptions(
     amountInPaise: 10000,
     orderId: order.id,
     name: userName,
     email: userEmail,
   );
   razorpay.open(options);
   ```
3. **Handle Success/Failure** in event listeners
4. **Verify Payment** via backend API

---

## 🔐 Security Best Practices

### ✅ DO

- ✅ **Always verify payment signatures** on the server
- ✅ **Never trust client-side payment success**
- ✅ **Store `RAZORPAY_KEY_SECRET` only on server**
- ✅ **Use HTTPS in production**
- ✅ **Validate order amounts on server before creating**
- ✅ **Log all payment events for auditing**

### ❌ DON'T

- ❌ **Never expose `RAZORPAY_KEY_SECRET` to client**
- ❌ **Don't trust payment_id alone for verification**
- ❌ **Don't skip signature verification**
- ❌ **Don't hardcode amounts in client-side code**

---

## 🚀 Production Deployment

### Before Going Live

1. **Switch to Live Credentials:**
   ```env
   # Replace test keys with live keys
   RAZORPAY_KEY_ID=rzp_live_XXXXXXXXXX
   RAZORPAY_KEY_SECRET=XXXXXXXXXXXXXXXXXX
   NEXT_PUBLIC_RAZORPAY_KEY_ID=rzp_live_XXXXXXXXXX
   ```

2. **Update Flutter App:**
   ```dart
   static const String testApiKey = 'rzp_live_XXXXXXXXXX';
   static const bool isTestMode = false;
   ```

3. **Enable Razorpay Features:**
   - Enable production payment methods in dashboard
   - Configure webhooks for payment status updates
   - Set up settlement accounts

4. **Testing Checklist:**
   - [ ] Test order creation
   - [ ] Test successful payment
   - [ ] Test failed payment
   - [ ] Test payment verification
   - [ ] Test webhook handling
   - [ ] Test refund flow (if applicable)

---

## 📊 Razorpay Dashboard

**Test Dashboard:** https://dashboard.razorpay.com/app/dashboard

**Key Sections:**
- **Transactions** - View all test payments
- **Orders** - View created orders
- **Customers** - Customer details
- **Reports** - Payment analytics
- **Settings** - API keys, webhooks, etc.

---

## 🔗 API Endpoints

### User-Web Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/payments/create-order` | POST | Create Razorpay order |
| `/api/payments/verify` | POST | Verify payment signature |
| `/api/payments/methods` | GET | Get saved payment methods |
| `/api/payments/customers` | POST | Create Razorpay customer |

---

## 🐛 Troubleshooting

### Common Issues

**1. "Invalid Key ID"**
- Check that `RAZORPAY_KEY_ID` matches the format `rzp_test_*` or `rzp_live_*`
- Verify the key is active in Razorpay dashboard

**2. "Signature Verification Failed"**
- Ensure `RAZORPAY_KEY_SECRET` is correct
- Check that the signature is being calculated correctly
- Verify order_id, payment_id match

**3. "Amount Mismatch"**
- Razorpay expects amount in **paise** (₹1 = 100 paise)
- Always multiply rupee amount by 100

**4. "Order Already Paid"**
- Each order can only be paid once
- Create a new order for retry attempts

---

## 📚 Documentation

- **Razorpay Docs:** https://razorpay.com/docs/
- **Payment Gateway API:** https://razorpay.com/docs/api/
- **Test Credentials:** https://razorpay.com/docs/payments/payments/test-card-details/
- **Webhooks:** https://razorpay.com/docs/webhooks/

---

## ✅ Current Status

| Feature | Status | Notes |
|---------|--------|-------|
| Test Credentials | ✅ Configured | Both web & mobile |
| Order Creation | ✅ Working | API endpoint ready |
| Payment Verification | ✅ Working | Signature validation |
| Checkout UI | ✅ Working | Web & mobile |
| Webhooks | ⚠️ TODO | For production |
| Refunds | ⚠️ TODO | If needed |

---

**Last Configuration Update:** 2026-01-02
**Configured By:** Claude Code
**Environment:** Test Mode (Development)
