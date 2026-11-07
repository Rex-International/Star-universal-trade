# SUT IQ200 — Consolidated refinements (27 October 2026)

## Included in this ZIP
- Admin recipient audience choices now include All Users, Sellers Only, Buyers Only, All Stores, and Select Individually.
- Seller/buyer audience filtering reads the existing `user_roles` table and fails visibly if role data cannot be read; it does not fabricate audience membership.
- Live recipient search shows an explicit no-match message. Recipient selection still fills available phone/email fields from profile/store data.
- Product and store share dialog offers Download Promo Image, Share Image + Link, WhatsApp, Copy Link, and the direct listing link. Image download exports a real PNG through a canvas when the browser and image source permit; SVG fallback is available for the generated store promo image.
- Store sharing uses the first available product image for that store when possible, otherwise the SUT-branded store artwork.
- Public Request submission validates and normalizes the buyer WhatsApp contact before saving it with the request. Seller response uses that contact to open WhatsApp with a prefilled message referencing the request and store.
- In-app notifications have per-message Delete controls and unread-count badge in the menu. Deletion is a soft delete so it does not remove the original message row.
- Added additive migration `supabase/migrations/20261027_sut_notification_delete.sql` to add `deleted_at` and allow recipients to update their own read/deleted fields.

## Important integration notes
- Apply `20261025_sut_in_app_messaging.sql` first, then `20261027_sut_notification_delete.sql` in Supabase SQL Editor. These migrations are additive; they do not delete existing business data.
- Sellers Only / Buyers Only depends on the existing `public.user_roles(user_id, role)` records containing `seller` / `buyer`. If role records are missing or RLS denies access, the UI reports the lookup error rather than silently targeting the wrong people.
- Email addresses are populated only when available in the existing readable `profiles` data. Supabase Auth emails are not exposed to the browser unless the project deliberately provides them through a secure design.
- WhatsApp and email buttons open an external app/draft; the user must press Send. This is not bulk-delivery automation.
- Product/store link previews inside WhatsApp depend on the deployed domain and crawler-readable per-page Open Graph metadata. The current SPA alone cannot guarantee unique rich previews for each hash-routed listing. Server-side metadata/prerendering may still be required.
- This package has static checks only. It has not been live-tested against the user's Supabase project, RLS policies, WhatsApp, or the final deployed domain in this environment.
