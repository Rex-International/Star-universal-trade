# Star Universal Trade — IQ200 Rebuild

Fresh static SPA marketplace for Vercel + Supabase.

## Features
- Email/password + Google authentication
- Buyer/seller profiles and stores
- Product publishing with gallery/camera capture, preview and progress
- Supabase Storage image uploads with verified public URLs
- Multi-currency product prices and browse min/max currency filters
- Category artwork
- Product detail, seller contact (WhatsApp/call/SMS), share
- Store browsing, storefronts, location and social links
- Follow stores and notifications
- Public Buying Requests with budget, currency, contact and seller notifications
- Seller responses and chat
- Delivery availability and delivery status
- Text, image and short audio messages
- Responsive mobile-first UI

## Deploy
1. Run the SQL migration in `supabase/migrations/001_iq200.sql` in Supabase SQL Editor.
2. Set the Supabase URL and publishable key in `index.html` or replace the placeholders using your deployment configuration.
3. `npm run build`.
4. Vercel: Framework = Other, Build Command = `npm run build`, Output Directory = `dist`.
5. Supabase Auth → URL Configuration: Site URL = your production domain; add the same domain plus `/**` to Redirect URLs.
