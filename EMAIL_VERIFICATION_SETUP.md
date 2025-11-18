# Email Verification Code System - Setup Guide

## ✅ Current Status

**The verification code system is ALREADY FULLY IMPLEMENTED!**

Your application includes:
- ✓ 6-digit alphanumeric verification codes (e.g., "A1B2C3")
- ✓ 2-hour expiration time
- ✓ Professional email templates (HTML + text)
- ✓ Frontend verification form with resend option
- ✓ Backend API endpoints for verify & resend
- ✓ Magic links that auto-fill codes from email

## How It Works

1. **User registers** with email and password
2. **Backend generates** a 6-digit verification code
3. **Email is sent** with the code and a magic link
4. **Frontend switches** to verification mode automatically
5. **User enters code** or clicks the magic link
6. **Account is activated** and user is logged in

## 🔧 To Enable Real Emails

You just need to configure valid SMTP credentials. Choose one option:

### Option 1: Gmail (Free, Easy Setup)

1. Enable 2-factor authentication on your Google account
2. Generate an App Password: https://myaccount.google.com/apppasswords
3. Update Heroku configuration:

```bash
heroku config:set \
  SMTP_USERNAME=your-email@gmail.com \
  SMTP_PASSWORD=your-16-digit-app-password \
  --app tft-smartcomp
```

**Note:** `SMTP_ADDRESS` and `SMTP_PORT` are already configured correctly.

### Option 2: SendGrid (Free Tier: 100 emails/day)

1. Sign up at https://sendgrid.com/
2. Create an API key from Settings → API Keys
3. Update Heroku configuration:

```bash
heroku config:set \
  SMTP_ADDRESS=smtp.sendgrid.net \
  SMTP_PORT=587 \
  SMTP_USERNAME=apikey \
  SMTP_PASSWORD=SG.your-sendgrid-api-key \
  --app tft-smartcomp
```

### Option 3: Mailgun (Free Tier: 1000 emails/month)

1. Sign up at https://mailgun.com/
2. Get SMTP credentials from Sending → Domain Settings → SMTP
3. Update Heroku configuration:

```bash
heroku config:set \
  SMTP_ADDRESS=smtp.mailgun.org \
  SMTP_PORT=587 \
  SMTP_USERNAME=postmaster@your-domain.mailgun.org \
  SMTP_PASSWORD=your-mailgun-password \
  --app tft-smartcomp
```

## 🧪 Testing Locally

1. Create a `.env` file in `ruby_backend/tft_team_builder/`:

```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

2. Start the backend server:

```bash
cd ruby_backend/tft_team_builder
bin/rails server
```

3. Start the frontend:

```bash
cd frontend/tft-builder
npm run dev
```

4. Test registration at http://localhost:5173/login?mode=register

## 📧 Email Template Preview

When a user registers, they receive an email containing:

**Subject:** Verify your TFT Smart Hub account

**Body:**
```
Confirm your TFT Smart Hub account

Hello [User],

Thanks for signing up for TFT Smart Hub! Use the verification code below to confirm your email address:

     A1B2C3

You can also click the button below to open the verification screen with your code prefilled:

     [Verify my email]

The code will expire in 2 hours. If you didn't create an account, you can safely ignore this email.

— The TFT Smart Hub team
```

## 🔍 Troubleshooting

### Email not sending?

1. Check Heroku logs:
```bash
heroku logs --tail --app tft-smartcomp
```

2. Verify SMTP configuration:
```bash
heroku config --app tft-smartcomp | grep SMTP
```

### Gmail "Less secure app" error?

- Gmail requires App Passwords (not your regular password)
- Must have 2-factor authentication enabled
- Generate at: https://myaccount.google.com/apppasswords

### Code expired?

- Codes expire after 2 hours
- User can click "Resend verification email" to get a new code
- Each new code invalidates the previous one

## 📂 Implementation Files

If you want to customize the system:

- **Backend Model:** `ruby_backend/tft_team_builder/app/models/user.rb`
- **Backend Controller:** `ruby_backend/tft_team_builder/app/controllers/api/auth_controller.rb`
- **Email Mailer:** `ruby_backend/tft_team_builder/app/mailers/user_mailer.rb`
- **Email Template (HTML):** `ruby_backend/tft_team_builder/app/views/user_mailer/verification_email.html.erb`
- **Email Template (Text):** `ruby_backend/tft_team_builder/app/views/user_mailer/verification_email.text.erb`
- **Frontend Form:** `frontend/tft-builder/src/pages/LoginPage.vue`
- **Auth Store:** `frontend/tft-builder/src/stores/authStore.js`

## 🎯 Summary

**You don't need to implement anything - it's already done!** Just configure valid SMTP credentials using one of the options above, and users will receive real verification codes via email.
