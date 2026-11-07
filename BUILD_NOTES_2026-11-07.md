# SUT Build Notes — 7 November 2026

Base: `SUT_IQ200_REFINEMENT_FIX_2026-11-01-1.zip` supplied by the user.

## Implemented in this refinement
- Split seller store sharing into two distinct actions: **Share Store** and **Get Store QR Code**.
- Added Vercel serverless endpoint `api/store-share.js` for crawler-readable Open Graph/Twitter store metadata and browser redirect to the exact SUT store.
- `Share Store` now shares the metadata endpoint URL only (Audiomack-style link preview pattern); it no longer bundles the QR poster.
- `Get Store QR Code` separately generates a high-resolution QR and a branded portrait PNG poster.
- PNG export preserves the complete poster dimensions to avoid cropping the lower QR area.
- Kept existing Admin Console warning flow; it sends an in-app warning to the resolved store owner and reports database errors rather than claiming false delivery.
- Added setup/test instructions and release notes.

## Validation completed
- `node --check app.js` — PASS.
- `node --check api/store-share.js` — PASS.
- `vercel.json` JSON parse — PASS.
- Product Share and Buy for Me functions were not intentionally changed.
- ZIP archive integrity — checked after packaging.

## Not yet verified (requires live environment)
- WhatsApp Open Graph preview: requires deployment on public HTTPS Vercel URL and a real active store readable through Supabase public SELECT policy.
- QR scan destination on another phone: requires the deployed public HTTPS domain; localhost QR only resolves on the local device/network.
- Admin warning delivery: requires applying the in-app messaging SQL migration and verifying admin `user_roles` RLS policy plus seller inbox in the live Supabase project.
