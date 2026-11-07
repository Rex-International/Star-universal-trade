# SUT frontend refinement build — 2026-11-01

Based exclusively on the accepted 2026-10-27 archive. The rejected 29-Oct unified-categories build was not used.

## Changes in this build
- Home page now places compact, horizontally scrollable photographic category cards above Popular Products.
- Added General and Services to the Home category rail and product filter; product upload category options include Services and General.
- Refined mobile bottom navigation with inline SVG icons and an unread Notifications badge.
- Notifications are marked read automatically when the inbox is opened (persistent Supabase update).
- Store onboarding requires a name, category, country, city and WhatsApp number.
- Store creation persists `category_name`; store cards and public store cover areas use category-specific photography.
- Store share payload now uses a branded category-cover SVG with a QR image pointing to the direct store URL, and keeps the direct URL in the share payload.
- Added one non-destructive SQL migration and a user action checklist.

## Verification performed
- `node --check app.js` passed.
- `node --check sw.js` passed.
- `manifest.webmanifest` parsed as valid JSON.
- No live Supabase credentials/session were available in this environment, so no real account, RLS, database write, public hosting, native share, QR scan, or cross-device test was performed.

## Important limitations
- Apply the supplied migration before deploying this frontend; otherwise store creation/query will fail because `category_name` does not yet exist.
- QR artwork uses the public QRServer image endpoint and needs internet access. Confirm it by scanning from a second device/browser.
- Store name/category editing UI is not included in this build yet.
- Admin warning/suspension delivery flow has not been modified or certified against the live schema.
- This is a tested static refinement candidate, not a production certification.
