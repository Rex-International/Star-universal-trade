# SUT Frontend Review — Before Database Integration

## Source basis
This build incorporates the user's 1st Test Analysis (14 points), supplied Privacy Policy and Terms notes, supplied SUT logo, and previously agreed SUT frontend scope. Features not called out for removal are preserved.

## Brand
- Star Universal Trade (SUT)
- Header uses the circular SUT emblem only.
- Website wordmark: STAR = gold, UNIVERSAL = blue, TRADE = gold.
- Footer uses the supplied full logo.
- Rex International Technologies is the parent/company name.
- Premium navy / blue / gold direction.
- Light and dark modes.

## Analysis refinements implemented
- Clear menu with role-aware visibility: guests/buyers do not see Store Dashboard; sellers do.
- Seller onboarding and one-account buyer/seller role switching in review mode.
- Store Dashboard with product management entry and shareable store link.
- Search bar, category filter, location filter and Advanced Search.
- Public Request and Create Request.
- Product cards include Buy for me, wishlist and product detail actions.
- Product detail includes seller, location, contact, store link and a share dialog with Copy Link or native Share.
- Store direct links use the same share dialog, so Copy Link and native Share are available for every store.
- Buy for me opens Public Request directly; it does not redirect to WhatsApp. The request review includes the exact product image, direct product link and a short buy-for-me message template.
- Notifications page.
- Help Centre.
- English, Swahili, French, Arabic and Chinese language selector; English is default.
- Light / Dark mode.
- Mobile navigation and hamburger side menu.
- Google Login UI placement preserved for later real OAuth integration.
- Splash screen on refresh.
- Social Commerce has been removed completely from the frontend navigation and route surface.
- Footer contains About, Media, Contact and Help, plus legal/contact channels.
- Privacy Policy and Terms presented professionally from the supplied handwritten general content.

## Database boundary
No Supabase, Cloudinary, OAuth secrets or production database writes are included. Local demo state is stored only in browser localStorage for review interactions.

## Later production integration
Planned stack: Vercel + GitHub, Supabase Auth/PostgreSQL, Cloudinary media. Production integration must preserve this UI/functionality and replace local demo actions with secure backend operations.


## Supabase integration status (Phase 1)
- Added Supabase JS browser client configuration with public publishable key.
- Implemented email/password Auth, session restoration and sign-out.
- Added Google OAuth invocation; provider configuration remains a dashboard step.
- Added reads for published products, active stores, active categories and product media.
- User roles are read from `user_roles`; client-side role simulation has been removed.
- Seller activation, writes, media uploads and admin actions remain incomplete and must be implemented and tested before public production launch.

## Supabase integration status (Phase 2 implementation pass)
- Added store creation against `stores`, owned-store lookup, and seller dashboard based on actual store data.
- Added Public Request inserts and loading of open requests.
- Added product draft creation, unsigned Cloudinary image upload, `product_media` insert, and publish-after-success flow.
- Removed hard-coded seller dashboard KPIs; admin overview now queries visible database counts.
- This is an implementation pass, not a claim of completed live acceptance testing. Verify Cloudinary preset settings and test the end-to-end writes with a test account before public launch.
- Admin moderation actions, seller responses, notifications, and complete production security testing remain outstanding.
