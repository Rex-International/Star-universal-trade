# SUT refinement — Admin in-app messaging, Store Sharing, Public Request

## Included
- Adds a dedicated `sut_messages` inbox table migration with recipient-only reads, admin-only inserts based on the existing `user_roles` table, and recipient read-status updates.
- Admin Console sends an in-app message row to each selected user (one message per recipient); it no longer inserts a single `recipient_id = null` draft into a guessed `messages` table.
- The Notifications page loads the signed-in user's in-app inbox and supports marking a message read.
- Store promotion download attempts a PNG export from the generated SVG preview, instead of naming an SVG file as though it were a gallery-ready image. If PNG conversion fails, it supplies an SVG fallback.
- Public Request response now opens WhatsApp directly with a prefilled response and store link, without prompting for a response first. It reports missing/invalid buyer contact rather than silently opening a popup.

## Required Supabase step for in-app messages
1. Open Supabase Dashboard → SQL Editor.
2. Run the full file `supabase/migrations/20261025_sut_in_app_messaging.sql`.
3. Confirm your `user_roles` table has the expected `user_id` and `role` columns and the current admin account has role `admin` or `superadmin`.
4. Reload the SUT site, sign in as an admin, open Admin Console, load recipients, select user recipients and send a test message to your own account.
5. Open Notifications under that account and confirm the message appears and can be marked read.

## Important constraints
- Browser-only code cannot safely bypass RLS. The SQL migration is required; frontend changes alone cannot enable secure messaging.
- The current Admin Console supports sending in-app messages to selected user records. Stores are audience records, not separate inbox accounts; select the store owner/user record to deliver to an account.
- This client sends one insert per selected recipient. Very large bulk announcements should later use a server-side Edge Function/queue to avoid browser request limits.
- WhatsApp opens a prefilled message; the user still presses Send. No external delivery is falsely reported as completed.
- Public Request WhatsApp routing requires the buyer's phone number to be saved in the request description using the existing `WhatsApp contact: https://wa.me/...` format. Requests posted before that contact was saved may require the buyer to update/repost the request.
- This package has passed JavaScript syntax and ZIP integrity checks, but live Supabase RLS, browser gallery download, and WhatsApp handoff still require testing on the actual project/device.
