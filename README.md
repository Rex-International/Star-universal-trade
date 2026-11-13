> **Release status (22 October 2026):** This is a production candidate, not a certified production release. Static checks passed, but live Supabase/Cloudinary operations and RLS security have not been verified in a real browser. See `RELEASE_STATUS.md` for the required launch checks.

# SUT — Phase 3 Functional Refinement Test Build

This package preserves the reviewed SUT frontend and adds the first live Supabase integration.

## Configured
- Supabase browser client using the supplied Project URL and publishable key.
- Email/password sign-up and sign-in through Supabase Auth.
- Google OAuth button through Supabase Auth (Google provider must be enabled and redirect URLs configured in Supabase).
- Current session restore and sign-out.
- User identity and role reads from `profiles` and `user_roles`; the browser never grants itself admin/seller roles.
- Reads published products, active stores, active categories and product media from Supabase, when rows are available.
- The catalogue starts empty and displays a truthful empty state until live Supabase rows are available; demo products/stores/requests are not seeded in the frontend.

## Important remaining production work
- Secure seller activation (server-side/SQL function or trigger that adds the `seller` role safely). The UI deliberately does not fake seller/admin roles.
- Store creation and product publishing, including Cloudinary upload configuration.
- Public Request writes and seller responses.
- Admin moderation actions and a full RLS/security audit.
- Configure Google provider and authorized redirect URLs before Google sign-in will work.
- Deploy over HTTPS (Vercel recommended). `python -m http.server` is only for local UI testing.

## Supabase URL note
The Project URL used in the client is `https://zfujqsylxzpylxbmouuu.supabase.co`. Do not append `/rest/v1` to the project URL when calling `createClient`.

## Termux test
```bash
cd ~/sut-frontend-corrected/SUT_FRONTEND_REVIEW_PRODUCTION
python -m http.server 8081
```
Open `http://127.0.0.1:8081`. Sign-up/sign-in and database reads need internet access. For production OAuth redirects, configure the actual deployed domain in Supabase Auth URL Configuration.

## Security
The publishable key is intended for browser use. Never add a `service_role` or secret key to this folder, GitHub, or frontend code. Row Level Security (RLS) must remain enabled and correct on every exposed table.


## Auth redirect correction
- Google OAuth now redirects to the app URL without a hash fragment; this avoids conflict between OAuth callback data and the SPA's `#/...` router. The app returns to Account after a successful OAuth session is restored.
- If email/password sign-in reports `Invalid login credentials` immediately after sign-up, check whether Supabase requires email confirmation and confirm the account first.

## Phase 2 integration work included in this package
- Seller store creation writes to `stores` using the signed-in user's ID; the app detects seller workspace access from an owned store or an existing seller/admin role. This avoids granting a `seller` role from browser code.
- Public Request submission writes to `public_requests`; open requests are loaded from Supabase.
- Product submission creates a draft in `products`, uploads selected images to Cloudinary, creates `product_media` rows, and publishes the product only after those steps succeed.
- Seller dashboard lists published products belonging to the current store and removes hard-coded demo KPIs.
- Admin overview requests live row counts where the current RLS policy permits the query. It does not yet implement edit/delete/moderation actions.

## Cloudinary configuration and limits
The current client config uses cloud name `itmf5kh8`, unsigned preset `sut_product_images_compressed`, and folder `sut/products`. Product publishing accepts one image per product and does not perform browser-side image compression. The file chooser accepts common browser-recognized image MIME types plus Cloudinary-supported image input extensions including HEIC/HEIF, BMP, TIFF, GIF, SVG, PSD, AI/EPS, ICO, JPEG 2000, JXR/HD Photo, JXL, TGA and FLIF. Upload-only camera RAW/DNG formats are intentionally not accepted as product photos because Cloudinary documents that they cannot receive image transformations; this keeps product images deliverable in browsers. Cloudinary remains the final authority: formats not supported by the selected Cloudinary product environment or restricted by the upload preset/account will be rejected with the returned error.

There is no longer an application-level 8 MB cap. Files up to 100 MB use a standard upload; files larger than 100 MB use Cloudinary's chunked upload protocol. The actual maximum is still controlled by the Cloudinary plan/account Usage Limits and upload preset, and large uploads require a stable connection. Incoming transformation remains configured in the Cloudinary preset (`c_limit,w_1600,h_1600,q_auto:good`) and delivery URLs retain `f_auto,q_auto:good`. Transformations optimize the stored/delivered image after upload; they do not bypass Cloudinary's upload-size or account limits. Never put a Cloudinary API secret in frontend code.

## Honest test status
The JavaScript syntax check passed while building this archive. A live Supabase/Cloudinary transaction has not been run from this build environment. Test first with a non-critical account and a small image. If the Cloudinary preset or a database policy rejects a step, the UI reports the error and a product may remain as a draft; review it in Supabase before retrying.

## Still not complete
- Full admin moderation and category-management actions.
- Seller response workflow for public requests.
- Live notifications and notification read state.
- Full end-to-end Google OAuth test on the final deployed domain.
- Production security review and end-to-end mobile/browser testing.


## Phase 3 changes in this build
- Removed hard-coded demo products, stores and public requests from initial state; marketplace starts empty until Supabase live data loads.
- Removed invented star ratings and demo statistics.
- Store contact accepts a phone number and normalizes Tanzanian local numbers to WhatsApp links.
- Store and product sharing now use a branded share card with SUT logo, title, description, direct link, Visit/View, Copy Link and Share actions.
- Seller dashboard includes product edit and unpublish actions. Unpublish uses the existing product `status` field rather than deleting records.
- Admin Console loads live product/store/report queues and attempts moderation updates through existing Supabase permissions. Database RLS remains authoritative; failed actions show errors rather than pretending success.
- Added description/metadata, Open Graph/Twitter metadata, apple touch icon and 192/512 PWA icon references; service-worker cache version was bumped.

## Important validation notes
This ZIP has been syntax-checked and structurally inspected, but it has not been tested against your live Supabase project in a real browser during this build. Admin actions depend on the existing RLS policies. No database schema or policy changes are included. The canonical URL in `index.html` is a placeholder-style production domain and must be replaced with the actual deployed SUT domain before launch.


## Phase 3 refinements included
- Store contact form accepts a phone number and creates a WhatsApp URL automatically (Tanzanian local numbers are normalized to +255).
- Product/store Contact actions resolve the relevant store contact URL instead of opening the SUT support number.
- Product and store sharing use a branded share card with SUT logo, product/store name, store description, Visit/View, Copy Link and Share actions. Product sharing attempts to include the product image on supported browsers.
- Store dashboard has live product edit and unpublish controls; unpublish changes the existing `status` field rather than deleting records.
- Hard-coded demo products, stores, requests, fake ratings and demo count blocks have been removed.
- Admin Console now has an additional password re-verification screen plus live product/store/report moderation queues. Actual writes still depend on the existing Supabase RLS policies and role permissions. The client-side password screen is an additional gate, not a replacement for database security.
- Added application/Apple mobile metadata, Open Graph and Twitter metadata, and separate 192px/512px SUT app icons with a refreshed PWA manifest and service-worker cache.
- Store name duplicate checking is performed against currently visible database rows; a true race-proof uniqueness guarantee requires a database constraint, which this build intentionally does not add.

## Validation status
`node --check app.js` passes and the PWA manifest parses as valid JSON. This package has not yet passed end-to-end tests against the live Supabase/Cloudinary services or a successful browser-based install test. Admin operations depend on the project's existing RLS policies. No database schema, records, or policies were changed by this ZIP. Before deployment, set absolute Open Graph image URLs and the actual canonical site URL once the production domain is known.


## Phase 3.1 refinements build (2026-10-21)

This refinement build adds the following frontend improvements while keeping the existing Supabase schema untouched:
- Product and store report entry points and report submission against the existing `reports` table (expects `reporter_id`, `target_type`, `target_id`, `reason`, `details`, `status`). If your actual table differs, submission will show a database error rather than pretending success.
- Public Request form now requires a WhatsApp contact and stores the normalized WhatsApp link in the existing description field to avoid a schema migration. Buyers see only their own open requests in the UI; sellers with a store can see open requests. Closing a request updates its status and is restricted in the UI to the request owner. RLS must enforce these rules server-side before public launch.
- Store phone input includes a country calling-code selector and normalizes phone numbers to a WhatsApp URL.
- Product admin queue has title/price edit, suspend/restore, and a warning-message composer. WhatsApp and email are opened as user-mediated external actions; they are not sent silently by SUT.
- Admin console shows live Supabase table counts and a message composer. In-app message delivery is NOT enabled unless a compatible secure `messages` table and RLS policies already exist. The composer reports this limitation.
- Removed fabricated notification examples. Notification screen supports deleting/clearing locally stored notifications; server-synced notifications still require a real notifications table and policies.
- Improved store share card hierarchy and plain standalone share URL so supported messaging apps can detect links. WhatsApp Status media behavior depends on the browser's native share support.
- Install App remains visible and gives the browser installation guidance when the install prompt is unavailable; it changes to an installed state when the browser fires `appinstalled`.

## Production blockers (must not be misrepresented)
This is a **refinement/test build, not yet certified production-ready**. Before launch, validate the actual database columns and RLS policies for `reports`, `public_requests`, `products`, and `stores`; enforce request visibility/closure rules in RLS; implement and test secure in-app messages and server-backed notifications; implement server-side bulk messaging/recipient resolution; verify Google OAuth redirects and Cloudinary preset; set the actual production canonical URL/Open Graph image; and run real-browser end-to-end tests. No database schema or policies are changed by this archive.

## Consolidated refinements — 27 October 2026
See `CHANGELOG_ALL_AGREED_IMPROVEMENTS_2026-10-27.md`. The notification soft-delete migration must be applied after the messaging migration. This archive is syntax-checked, but a live Supabase/RLS and mobile end-to-end test remains required before calling it fully production-verified.
