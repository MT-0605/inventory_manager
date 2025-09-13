# Inventory Manager & Billing System

A comprehensive Flutter application for managing inventory and generating bills with Firebase integration.

## Features

### 🔐 Authentication
- Firebase Authentication for secure login/signup
- User profile management
- Session persistence

### 📦 Product Management
- Add, edit, delete products
- Product categories and search
- Stock quantity tracking
- Low stock alerts
- Product images support

### 🧾 Billing System
- Shopping cart functionality
- Customer information management
- Tax and discount calculations
- PDF bill generation and printing
- Automatic stock updates on sale

### 📊 Analytics & Reports
- Sales analytics dashboard
- Revenue and profit tracking
- Top selling products
- Sales by category
- Daily, weekly, and monthly trends
- Interactive charts and graphs

### 🎨 Modern UI/UX
- Material 3 design
- Responsive layout
- Dark/light theme support
- Intuitive navigation
- Loading states and error handling

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Firebase** - Backend services
  - Authentication
  - Firestore (NoSQL database)
  - Storage (for product images)
- **Provider** - State management
- **PDF Generation** - Bill printing
- **Charts** - Analytics visualization

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project setup
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd inventorymanager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Storage (optional)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective platform folders

4. **Update Firebase Configuration**
   - Open `lib/firebase_options.dart`
   - Replace placeholder values with your actual Firebase configuration

5. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

6. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/                 # Data models
│   ├── product.dart
│   ├── bill.dart
│   ├── sale_record.dart
│   └── user.dart
├── providers/              # State management
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── billing_provider.dart
│   └── analytics_provider.dart
├── screens/                # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── products_screen.dart
│   ├── add_edit_product_screen.dart
│   ├── billing_screen.dart
│   ├── billing_cart_screen.dart
│   ├── reports_screen.dart
│   ├── profile_screen.dart
│   └── main_navigation.dart
├── services/               # External services
│   ├── firebase_service.dart
│   └── pdf_service.dart
├── widgets/                # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── product_card.dart
│   └── loading_widget.dart
├── firebase_options.dart   # Firebase configuration
└── main.dart              # App entry point
```

## Key Features Implementation

### Product Management
- CRUD operations with Firestore
- Image upload to Firebase Storage
- Category-based filtering
- Search functionality
- Low stock alerts

### Billing System
- Shopping cart with quantity management
- Customer information collection
- Tax and discount calculations
- PDF generation with professional layout
- Automatic stock deduction

### Analytics Dashboard
- Real-time sales data
- Interactive charts using fl_chart
- Multiple time period views
- Top products and categories
- Revenue and profit tracking

## Firebase Security Rules

The application includes Firestore security rules that ensure:
- Users can only access their own data
- Authenticated users can manage products, bills, and sales
- Data integrity and security

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.2
  provider: ^6.1.2
  printing: ^5.13.2
  pdf: ^3.11.1
  fl_chart: ^0.69.0
  intl: ^0.19.0
  image_picker: ^1.1.2
  shared_preferences: ^2.3.2
  uuid: ^4.5.1
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.

## Screenshots

[Add screenshots of the application here]

## Roadmap

- [ ] Offline support
- [ ] Multi-language support
- [ ] Advanced reporting features
- [ ] Barcode scanning
- [ ] Supplier management
- [ ] Purchase orders
- [ ] Advanced user roles
- [ ] Data export/import
- [ ] Push notifications
- [ ] Cloud backup