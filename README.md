# Star Universal Trade

A premium international e-commerce marketplace by Rex International connecting buyers and sellers worldwide.

## Features

- **Buyer Marketplace**: Browse and purchase products from sellers worldwide
- **Seller Dashboard**: Create and manage product listings, track sales
- **Messaging System**: Direct communication between buyers and sellers
- **Wishlist**: Save favorite products for later
- **Notifications**: Real-time order and message notifications
- **Multi-language Support**: English, Swahili, French, Arabic
- **Dark Mode**: Built-in dark theme support
- **Responsive Design**: Optimized for mobile, tablet, and desktop

## Technology Stack

- **Frontend**: Vanilla JavaScript, HTML5, Tailwind CSS
- **Authentication**: Firebase Auth
- **Database**: Supabase (PostgreSQL)
- **Storage**: Firebase Storage
- **Internationalization**: Custom i18n system

## Setup Instructions

### Prerequisites

- Node.js 16+ (for development server)
- Firebase project with authentication enabled
- Supabase project with appropriate tables and RLS policies

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Rex-International/Star-universal-trade.git
cd Star-universal-trade
```

2. Create a `.env` file from the template:
```bash
cp .env.example .env
```

3. Add your Firebase and Supabase credentials to `.env`

4. Start the development server:
```bash
npm run dev
```

5. Open your browser and navigate to `http://localhost:3000`

### Production Build

For production deployment:
```bash
npm run build
```

The application is a static HTML file and requires no build compilation. Deploy `index.html` to your hosting service.

## Environment Variables

Create a `.env` file with the following variables:

```
FIREBASE_API_KEY=<your_api_key>
FIREBASE_AUTH_DOMAIN=<your_auth_domain>
FIREBASE_PROJECT_ID=<your_project_id>
FIREBASE_STORAGE_BUCKET=<your_storage_bucket>
SUPABASE_URL=<your_supabase_url>
SUPABASE_KEY=<your_supabase_key>
```

## Database Schema

The application uses the following Supabase tables:

- `profiles` - User profiles and account information
- `stores` - Seller store information
- `products` - Product listings
- `product_media` - Product images and media
- `categories` - Product categories
- `favorites` - User wishlists
- `conversations` - Messaging conversations
- `messages` - Individual messages
- `orders` - Purchase orders
- `reviews` - Product and seller reviews
- `notifications` - User notifications
- `reports` - Content reports
- `public_orders` - Public buying requests
- `public_order_responses` - Seller responses to buying requests

## Security

- Never commit `.env` files with credentials
- Use environment variables for all sensitive configuration
- Ensure Firestore and Storage rules are properly configured
- Enable RLS (Row Level Security) on all Supabase tables
- Regularly rotate API keys

## Deployment

### Vercel

1. Connect your GitHub repository to Vercel
2. Set environment variables in Vercel project settings
3. Deploy - Vercel will automatically detect and serve the static HTML

### Other Platforms

The application is a static HTML file with client-side JavaScript:
- Upload `index.html` to any static hosting service
- Ensure CORS is configured correctly for Firebase and Supabase
- Set environment variables in your hosting platform

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## Support

- WhatsApp: +255 744 379 008
- Email: Staruniversaltrade@gmail.com
- Instagram: @STAR_UNIVERSAL_TRADE

## License

Unlicensed - Proprietary

## Copyright

© 2026 Star Universal Trade · Rex International
