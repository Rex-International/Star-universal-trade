# SUT — Before testing

## Localhost (Termux)
1. Extract this ZIP and serve `SUT_FRONTEND_REVIEW_PRODUCTION` using a local HTTP server.
2. Open the local site and sign in with a seller account that owns a store.
3. Open Seller Dashboard. Confirm there are two separate actions: **Share Store** and **Get Store QR Code**.
4. Test Get Store QR Code: generate the poster, inspect that the complete QR is visible, download PNG, and open the PNG in Gallery.
5. Test Product Share and Buy for Me to ensure their existing behaviour is unchanged.
6. Sign in as an authorized admin, open Admin Console > Product moderation > Warn seller. Confirm the warning is inserted into the seller's in-app inbox. Do not count a toast as proof; verify the seller inbox.

## Vercel deployment checks (required for public sharing)
1. Deploy the project root containing `index.html`, `api/store-share.js`, and `vercel.json`.
2. Confirm the deployment's `/api/store-share?id=<REAL_STORE_UUID>` URL returns HTML with `og:title`, `og:description`, and `og:image` for that store.
3. Send the **Share Store** link to WhatsApp. Confirm WhatsApp displays the store cover, name and description; tap it and confirm it opens the exact store.
4. Generate **Get Store QR Code** on the deployed site, download the PNG, and scan it using a second phone. Confirm it opens that exact public store.
5. If the API endpoint returns 404/503, check Vercel Function deployment logs and the Supabase public SELECT policy for active stores.

## Important
- A localhost QR can only point to the local development address and will not open on a different phone. The QR image itself can still be checked for scan readability locally, but destination testing requires the deployed public HTTPS domain.
- WhatsApp link previews require the public Vercel HTTPS endpoint; Python localhost server cannot provide the crawler-readable Open Graph page.
