# StoreMore - Inventory Management System

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

A comprehensive inventory management application built with Flutter and Firebase, designed to help businesses efficiently manage their products, generate bills, and analyze sales data with detailed reports and analytics.

## 📱 Features

### 🏪 **Product Management**
- **Add/Edit Products**: Complete product catalog with images, descriptions, pricing, and stock levels
- **Category Organization**: Organize products by categories for better management
- **Stock Tracking**: Real-time inventory monitoring with low-stock alerts
- **Image Upload**: Cloudinary integration for product image storage
- **Profit Analysis**: Automatic calculation of profit margins and percentages

### 🧾 **Billing System**
- **Quick Bill Generation**: Create bills with multiple products
- **Customer Information**: Store customer details and contact information
- **Tax & Discount Support**: Apply taxes and discounts to bills
- **PDF Generation**: Generate and print professional invoices
- **Cart Management**: Add/remove products with quantity adjustments

### 📊 **Analytics & Reports**
- **Sales Analytics**: Comprehensive sales data with time-based filtering
- **Visual Charts**: Interactive line charts and pie charts for data visualization
- **Top Products**: Identify best-selling products and categories
- **Profit Tracking**: Monitor profit margins and revenue trends
- **Time Intervals**: View reports for Today, This Week, This Month, or All Time
- **Category Analysis**: Sales breakdown by product categories

### 🔐 **User Management**
- **Firebase Authentication**: Secure user login and registration
- **User Profiles**: Manage user information and preferences
- **Session Management**: Persistent login sessions

### 📱 **Modern UI/UX**
- **Material Design 3**: Modern, intuitive interface
- **Responsive Design**: Optimized for various screen sizes
- **Dark/Light Theme**: Adaptive theming support
- **Smooth Animations**: Fluid transitions and interactions
- **Bottom Navigation**: Easy access to all major features

## 🏗️ Project Structure

```
lib/
├── config/
│   └── cloudinary_config.dart          # Cloudinary image upload configuration
├── models/
│   ├── bill.dart                       # Bill and BillItem data models
│   ├── product.dart                    # Product data model
│   ├── sale_record.dart                # Sales analytics data model
│   └── user.dart                       # User data model
├── providers/
│   ├── analytics_provider.dart         # Sales analytics state management
│   ├── auth_provider.dart              # Authentication state management
│   ├── billing_provider.dart           # Billing system state management
│   └── product_provider.dart           # Product management state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart           # User login interface
│   │   └── register_screen.dart        # User registration interface
│   ├── add_edit_product_screen.dart    # Product creation/editing
│   ├── billing_cart_screen.dart        # Shopping cart interface
│   ├── billing_screen.dart             # Main billing interface
│   ├── dashboard_screen.dart           # Main dashboard with overview
│   ├── history_screen.dart             # Transaction history
│   ├── low_stock_products_screen.dart  # Low stock alerts
│   ├── main_navigation.dart            # Bottom navigation wrapper
│   ├── products_screen.dart            # Product catalog
│   ├── profile_screen.dart             # User profile management
│   └── reports_screen.dart             # Analytics and reports
├── services/
│   ├── cloudinary_service.dart         # Image upload service
│   ├── firebase_service.dart           # Firebase operations
│   └── pdf_service.dart                # PDF generation service
├── widgets/
│   ├── custom_button.dart              # Reusable button component
│   ├── custom_text_field.dart          # Custom input field
│   ├── loading_widget.dart             # Loading indicator
│   └── ultra_simple_card.dart          # Stat card component
├── firebase_options.dart               # Firebase configuration
└── main.dart                           # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.9.0 or higher)
- **Dart SDK** (3.9.0 or higher)
- **Firebase Project** with Firestore, Authentication, and Storage enabled
- **Cloudinary Account** for image storage
- **Android Studio** or **VS Code** with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/storemore-inventory-manager.git
   cd storemore-inventory-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore Database, and Storage
   - Download `google-services.json` and place it in `android/app/`
   - Run `flutterfire configure` to set up Firebase for your project

4. **Cloudinary Setup**
   - Create a Cloudinary account at [Cloudinary](https://cloudinary.com/)
   - Update `lib/config/cloudinary_config.dart` with your credentials:
   ```dart
   class CloudinaryConfig {
     static const String cloudName = 'your_cloud_name';
     static const String apiKey = 'your_api_key';
     static const String apiSecret = 'your_api_secret';
   }
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Dashboard
- Overview of key metrics
- Quick access to main features
- Low stock alerts
- Sales summary

### Product Management
- Product catalog with search and filtering
- Add/edit products with image upload
- Stock level monitoring
- Category organization

### Billing System
- Shopping cart interface
- Customer information management
- Tax and discount calculations
- PDF invoice generation

### Analytics & Reports
- Interactive sales charts
- Time-based filtering (Today, Week, Month, All Time)
- Top products analysis
- Category-wise sales breakdown

## 🛠️ Technologies Used

### **Frontend**
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Material Design 3** - UI/UX design system

### **Backend & Services**
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Cloudinary** - Image management and optimization

### **State Management**
- **Provider** - State management solution

### **Charts & Visualization**
- **fl_chart** - Interactive charts and graphs

### **PDF Generation**
- **printing** - PDF creation and printing
- **pdf** - PDF document generation

### **Additional Packages**
- **image_picker** - Image selection from gallery/camera
- **shared_preferences** - Local data persistence
- **uuid** - Unique identifier generation
- **intl** - Internationalization and date formatting

## 🔧 Configuration

### Firebase Rules

Update your Firestore rules for security:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are readable by authenticated users
    match /products/{productId} {
      allow read, write: if request.auth != null;
    }
    
    // Bills are readable by authenticated users
    match /bills/{billId} {
      allow read, write: if request.auth != null;
    }
  }
}


```

## 📊 Key Features Explained

### **Inventory Management**
- Real-time stock tracking with automatic low-stock alerts
- Product categorization for better organization
- Image upload with Cloudinary integration
- Profit margin calculations

### **Billing System**
- Multi-product cart functionality
- Customer information storage
- Tax and discount calculations
- Professional PDF invoice generation

### **Analytics Dashboard**
- Interactive charts showing sales trends
- Time-based filtering (hourly, daily, weekly, monthly)
- Top-selling products identification
- Category-wise sales analysis
- Profit tracking and margin analysis

### **User Experience**
- Modern Material Design 3 interface
- Smooth animations and transitions
- Responsive design for various screen sizes
- Intuitive navigation with bottom tab bar

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Cloudinary for image management
- The open-source community for various packages

## 📞 Support

If you have any questions or need help with the project, please:

1. Check the [Issues](https://github.com/yourusername/storemore-inventory-manager/issues) page
2. Create a new issue if your problem isn't already addressed
3. Contact the maintainers

---

**StoreMore** - Making inventory management simple and efficient! 🚀
