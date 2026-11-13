SUT CAMERA / GALLERY + PREVIEW PERSISTENCE FIX — 2026-11-12

Changes based on the user's localhost test:
- Replaced the generic file-picker button with two explicit choices: Choose from Gallery and Take Photo.
- Gallery input uses accept=image/*; camera input uses accept=image/* and capture=environment.
- Either choice replaces the single selected product image.
- The selected File object and preview URL are retained in application state and preview is restored after app re-renders.
- Product publishing reads the retained File object, not only a DOM file input, so an incidental render cannot silently discard the selection.
- The selected image is cleared after successful publishing or when leaving Add Product.
- No browser-side image compression added. Cloudinary upload/transform logic and Supabase schema were not changed.

Note: Android's exact gallery/camera chooser UI is controlled by the browser and installed Android apps. SUT now provides explicit Gallery and Camera buttons; Gallery is filtered to images, and Camera requests the rear camera.
