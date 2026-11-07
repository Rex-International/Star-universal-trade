# SUT Share Store + Admin Console refinement — 7 Nov 2026

## Share Store (Audiomack-style link)
- `Share Store` now creates a public `/api/store-share?id=<store-id>` URL.
- The Vercel serverless endpoint reads the public store record from Supabase and returns server-rendered Open Graph/Twitter metadata (store name, description, category cover image).
- A human visitor is redirected to the matching SUT hash route (`/#/store/<id>`).
- This rich preview cannot be verified on localhost because WhatsApp's crawler needs a public HTTPS endpoint. Test it after Vercel deployment using WhatsApp's own link preview.

## Get Store QR Code
- `Get Store QR Code` is a separate action from Share Store.
- It generates a QR at runtime pointing to the direct SUT store route and composes a branded portrait PNG poster with category cover, store name, category/location, description and QR.
- PNG export preserves the full poster dimensions (including the QR) rather than cropping it to a square.
- QR scan target on localhost will be a localhost URL; it becomes publicly reachable after deployment on Vercel. Test scanability and destination after deployment using a second device.

## Admin Console
- Existing Warn Seller flow remains in place: it resolves product -> store -> owner account and inserts an in-app warning into `sut_messages`.
- The UI reports success only after Supabase accepts the insert; failures are surfaced with the database error.
- Apply `supabase/migrations/20261025_sut_in_app_messaging.sql` in Supabase SQL Editor if not already applied. Admin `user_roles` policy must authorize the signed-in admin/superadmin.

## Scope protection
- Product Share and Buy for Me flows are not intentionally changed.
- No existing Supabase tables or records are deleted or renamed by this refinement.
- No change is made to the SUT_MASTER Google Sheet.
