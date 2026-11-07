# SUT Phase 3 — Refinement Build Status

Build date: 2026-10-23

## Included in this build
- Preserved the existing SUT Phase 3 frontend, Supabase configuration, PWA manifest, assets and service worker structure.
- Added an automatically generated, lightweight SVG Store Share Avatar using the store name/category, SUT visual identity, a visit-store call to action, and “Powered by Star Universal Trade”. This generation runs locally in the browser and does not call a paid AI API.
- Store share text now explicitly includes the direct store URL as ordinary text so compatible share targets can render it as a clickable link.
- Product sharing and Buy for Me logic were not intentionally changed.
- Install App button is visible in normal browser mode with a browser-menu fallback; it hides in standalone mode / after the browser reports installation.
- Bumped the service-worker cache identifier so updated frontend assets can replace older cached assets.

## Checks run in the build environment
- `node --check app.js` — passed.
- `node --check sw.js` — passed.
- `python -m json.tool manifest.webmanifest` — passed.

## Still requires live Supabase/browser verification before public production launch
These features depend on the actual Supabase schema, RLS policies, account roles and/or external provider permissions. They are **not certified as completed by these static checks**:
- Admin bulk recipient search/selection and automatic routing of messages to selected users/stores.
- Secure in-app messaging delivery. The current UI has previously reported that the `messages` table/schema or policies do not permit delivery. Do not treat a prepared draft as a delivered message.
- Automated WhatsApp bulk delivery requires an approved WhatsApp Business/API integration; opening `wa.me` is not the same as automatic delivery.
- Automated bulk email requires an email provider/server-side function and verified sender configuration.
- Seller suspension notices and enforcement across account/store/product permissions must be implemented and verified server-side; hiding buttons in frontend is not sufficient.
- Persistent website visit analytics/history requires a backend event store and appropriate insert/read policies. Existing admin counts are not historical traffic analytics.
- End-to-end testing of guest access, public requests, store creation, Cloudinary uploads, admin permissions and RLS.

## Safety notes
- No Supabase database tables or RLS policies were modified by this build.
- No service-role key or other secret was added.
- This archive is a **refinement test candidate**, not a claim of fully verified production readiness. Use a backup and test against the current project before deploying publicly.
