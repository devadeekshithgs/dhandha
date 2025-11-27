# Dhandha - Flutter POS System

A comprehensive Point of Sale (POS) system built with Flutter for managing inventory, sales, customers, billing, and more.

## Project Status

**Migrating from Dreamflow to GitHub** - The project is being transitioned to GitHub for version control and collaboration.

## Completed ✅

### Core Files
- [x] `lib/main.dart` - Application entry point
- [x] `lib/theme.dart` - Theme configuration
- [x] `pubspec.yaml` - Project dependencies
- [x] `analysis_options.yaml` - Flutter lints configuration
- [x] `.metadata` - Flutter project metadata
- [x] `.flutter-plugins-dependencies` - Flutter plugins

### Folders & Services
- [x] `lib/services/` - API and business logic services
  - `expense_service.dart`
  - `ledger_service.dart`
  - `product_service.dart`
  - `purchase_service.dart`
  - `sale_service.dart`
  - `settings_service.dart`
  - `storage_service.dart`
  - `vendor_service.dart`

### Models (Partially Complete)
- [x] `lib/models/customer.dart`
- [x] `lib/models/expense.dart`
- [x] `lib/models/product.dart`

### Platform Configuration
- [x] `ios/` - iOS-specific configuration (Podfile, etc.)
- [x] `android/` - Android-specific configuration
- [x] `web/` - Web assets

## To Be Added ⏳

### Models (Missing 7 files)
- [ ] `lib/models/ledger_entry.dart` - Ledger entry model
- [ ] `lib/models/purchase_item.dart` - Purchase item model
- [ ] `lib/models/purchase_order.dart` - Purchase order model
- [ ] `lib/models/sale.dart` - Sale model
- [ ] `lib/models/sale_item.dart` - Sale item model
- [ ] `lib/models/settings.dart` - Settings model
- [ ] `lib/models/vendor.dart` - Vendor model

### Providers (New Folder)
- [ ] `lib/providers/cart_provider.dart` - Cart state management

### Screens (New Folder - 8 files)
- [ ] `lib/screens/billing_screen.dart`
- [ ] `lib/screens/customers_screen.dart`
- [ ] `lib/screens/dashboard_screen.dart`
- [ ] `lib/screens/inventory_screen.dart`
- [ ] `lib/screens/main_shell.dart`
- [ ] `lib/screens/payment_screen.dart`
- [ ] `lib/screens/purchase_orders_screen.dart`
- [ ] `lib/screens/settings_screen.dart`

### Widgets (New Folder - 3+ files)
- [ ] `lib/widgets/cart_item_card.dart`
- [ ] `lib/widgets/cart_summary_bottom_sheet.dart`
- [ ] `lib/widgets/product_search_bar.dart`
- [ ] Additional reusable UI widgets

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/devadeekshithgs/dhandha.git
   cd dhandha
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
dhandha/
├── lib/
│   ├── models/          # Data models (WIP)
│   ├── providers/       # State management (TODO)
│   ├── screens/         # UI screens (TODO)
│   ├── services/        # Business logic & API (✓)
│   ├── widgets/         # Reusable components (TODO)
│   ├── main.dart        # Entry point (✓)
│   └── theme.dart       # Theme config (✓)
├── ios/                 # iOS configuration
├── android/             # Android configuration  
├── web/                 # Web assets
├── pubspec.yaml         # Dependencies
└── README.md            # This file
```

## Next Steps

1. Sync all model files from Dreamflow to GitHub
2. Create providers folder with state management
3. Add all UI screens
4. Add reusable widget components
5. Set up CI/CD workflows
6. Publish to app stores

## Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **GetX/Riverpod** - State management (to be determined)
- **Hive/SQLite** - Local database

## Contributing

Contributions are welcome! Please follow the project structure and coding standards.

## License

MIT License - feel free to use this project for your own purposes.
