# SUT Phase 3 — Header and Store Sharing refinement

## Changes in this archive
- Removed the Wishlist shortcut from the top header; the wishlist feature and product-level wishlist controls remain available.
- Kept the SUT name and icon visible in the header and compacted the Install App control for small screens.
- Kept Dark Mode and Menu controls visible outside the side menu on mobile layouts.
- Kept Install App's existing installability/installed-state behavior.
- Improved the store-share text to include an explicit `VISIT STORE` URL and made the image-file conversion use the store's generated SVG data URL directly before attempting image sharing.
- Updated the service-worker cache name so a newly deployed version can replace the previous cached shell.
- Product sharing and Buy for Me business logic were not intentionally changed.

## Checks completed
- `node --check app.js` passed.
- `node --check sw.js` passed.
- `python -m json.tool manifest.webmanifest` passed.
- ZIP contents and required app files were checked after packaging.

## Important limitations
This is a tested static refinement build, not a certification of end-to-end production readiness. The browser's Web Share implementation may refuse to attach files on some devices/targets; the share text always includes the direct store link. Automated WhatsApp/email bulk sending, database-backed in-app messaging, seller suspension enforcement and historical traffic analytics still require compatible Supabase schema/policies and/or server-side services and live testing. No database schema, RLS policy, or secret was changed in this archive.

- Updated the home page Shop by category cards to use full-bleed photographic images (remote Unsplash image URLs), readable dark overlays, category labels and responsive sizing; no cartoon illustrations are used in these category cards.
- Category photos require an internet connection and depend on the remote image host being reachable.
