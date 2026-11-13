# SUT Cloudinary image input expansion — 12 November 2026

Base: `SUT_CLOUDINARY_SINGLE_IMAGE_NO_BROWSER_COMPRESSION_TEST.zip`.

Changes:
- Expanded the product image chooser to common browser image MIME types and Cloudinary-supported image input extensions, including HEIC/HEIF, TIFF, BMP, GIF, SVG, PSD, AI/EPS and additional transformable formats. Upload-only camera RAW/DNG formats are deliberately excluded because Cloudinary cannot apply image transformations to them, which would make them unsuitable as browser-displayed product photos.
- Removed the frontend 8 MB size rejection.
- Added chunked Cloudinary uploads for files larger than 100 MB (20 MB chunks); ordinary files continue to use the direct unsigned upload endpoint.
- Preserved one image per product, replacement-on-new-selection, no browser compression, the existing Cloudinary cloud/preset/folder and delivery transformation, and the draft-then-publish flow.
- Changed preview to use an object URL rather than loading the full image into a base64 data URL. If the browser cannot preview a format, the UI explains that upload may still proceed.
- Improved upload error messages to surface Cloudinary's JSON error or `X-Cld-Error` response header.
- Bumped the service worker cache version to v6 to avoid serving the previous upload code.

Important limits:
- This removes the SUT-side 8 MB cap, not Cloudinary's account-level upload limit. Cloudinary plan/account limits and preset restrictions still apply.
- Cloudinary's format support varies by input format and transformation support. Cloudinary is the final validator.
- This archive has passed local static/syntax checks only. A live Cloudinary upload and Supabase publish transaction have not been run here.
