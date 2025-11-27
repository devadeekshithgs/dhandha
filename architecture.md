# Dhandha - Architecture Blueprint

## Product Philosophy
**Target Users**: Tier 2/3 India Kirana Store Owners (Low Tech Literacy)
**Core Principle**: Offline-First, Zero Server Cost, Speed <3s Checkout

## Tech Stack
- **Local Database**: Hive (Offline-First)
- **Backup**: Google Drive JSON Export
- **State Management**: Provider
- **Navigation**: GoRouter

## Data Models (lib/models/)

### 1. Product
- id (String, UUID)
- name (String)
- normalizedName (String, for Hinglish search)
- barcode (String?, indexed)
- imagePath (String?, local asset)
- category (String)
- locationRack (String?, e.g., "A1")
- locationShelf (String?, e.g., "Top")
- stockQty (double, supports decimals)
- unit (enum: kg, pc, ltr, gm)
- isLoose (bool)
- mrp (double)
- sellingPrice (double)
- costPrice (double)
- lowStockThreshold (double)
- expiryDate (DateTime?)
- createdAt (DateTime)
- updatedAt (DateTime)

### 2. Customer
- id (String, UUID)
- name (String)
- phone (String, unique)
- creditLimit (double)
- currentOutstanding (double, calculated)
- lastPaymentDate (DateTime?)
- createdAt (DateTime)
- updatedAt (DateTime)

### 3. Sale (Transaction)
- id (String, UUID)
- billNo (String, human-readable, e.g., "BILL-001")
- timestamp (DateTime)
- customerId (String?, nullable for walk-in)
- totalAmount (double)
- totalSavings (double, MRP - Selling Price)
- paymentMode (enum: CASH, UPI, UDHAAR, SPLIT)
- cashAmount (double)
- upiAmount (double)
- udhaarAmount (double)
- status (enum: COMPLETED, HELD)
- createdAt (DateTime)
- updatedAt (DateTime)

### 4. SaleItem
- id (String, UUID)
- saleId (String, FK)
- productId (String, FK)
- productName (String, snapshot)
- qty (double)
- unitPriceSnapshot (double)
- mrpSnapshot (double)
- totalPrice (double, calculated)
- totalSavings (double, calculated)

### 5. LedgerEntry (Khata)
- id (String, UUID)
- entityType (enum: CUSTOMER, VENDOR)
- entityId (String)
- entityName (String, snapshot)
- type (enum: SALE, PAYMENT, DEPOSIT, PURCHASE)
- amount (double)
- balanceAfter (double)
- timestamp (DateTime)
- notes (String?)
- createdAt (DateTime)

### 6. Vendor
- id (String, UUID)
- name (String)
- gstin (String?)
- phone (String)
- balancePayable (double)
- createdAt (DateTime)
- updatedAt (DateTime)

### 7. Expense
- id (String, UUID)
- category (String, e.g., Rent, Electricity)
- amount (double)
- date (DateTime)
- receiptImagePath (String?)
- notes (String?)
- createdAt (DateTime)

### 8. Settings
- shopName (String)
- ownerName (String)
- ownerPhone (String)
- upiId (String?)
- gstNumber (String?)
- address (String?)
- lastBackupTime (DateTime?)
- autoBackupEnabled (bool, default: true)

## Service Classes (lib/services/)

### 1. ProductService
- CRUD operations for products
- Smart search with Hinglish support (normalized names)
- Low stock alerts
- Expiry alerts
- Sample data generation

### 2. CustomerService
- CRUD operations for customers
- Outstanding balance calculation
- Credit limit checks
- Sample data generation

### 3. SaleService
- Create/complete sales
- Hold/resume cart
- Generate bill numbers
- Daily sales reports
- Sample data generation

### 4. LedgerService
- Record all financial transactions
- Entity-wise ledger view
- Balance calculations

### 5. VendorService
- CRUD operations for vendors
- Sample data generation

### 6. ExpenseService
- CRUD operations for expenses
- Category-wise expense tracking
- Sample data generation

### 7. SettingsService
- App configuration
- Backup/restore operations

### 8. StorageService
- Hive box initialization
- Data persistence layer
- Backup JSON generation

## Screen Structure (lib/screens/)

### 1. BillingScreen (Home)
- Smart search bar with debounce
- Cart items list with stepper
- Bottom summary (Qty, Savings, Total)
- Hold/Resume cart buttons
- "Proceed to Pay" button

### 2. PaymentScreen
- Payment mode selection (Cash/UPI/Udhaar/Split)
- Amount input
- Customer selection (for Udhaar)
- Print/Share bill

### 3. DashboardScreen
- Top 3 cards: Cash, Profit, Pending Udhaar
- Action needed (Low stock, Expiry alerts)
- Sales vs Expenses graph

### 4. InventoryScreen
- Product cards with search
- Low stock indicators
- Add/Edit product
- Category filter

### 5. CustomersScreen (Khata)
- Customer list with outstanding
- Add payment
- View ledger

### 6. ReportsScreen
- Sales report (daily/weekly/monthly)
- Expense report
- Profit/Loss report

### 7. SettingsScreen
- Shop profile
- Backup/Restore
- About

## UI/UX Design Principles

### Color Semantics
- **Green**: Cash, In-Stock, Savings, Positive Balance
- **Red**: Udhaar/Credit, Expense, Low Stock, Debt
- **Blue**: UPI, Digital Payments, Neutral Actions
- **Slate/Gray**: Background, Text

### Thumb Zone Optimization
- Primary actions (Add, Save, Pay) in bottom 30% of screen
- FAB for quick actions
- Bottom navigation for primary tabs

### Visual Hierarchy
- Large, bold numbers for totals
- Strike-through for MRP
- Prominent "You Save" text in green
- Color-coded status indicators

## Smart Search Algorithm
1. Normalize query (remove vowels, double letters)
2. Exact barcode match (if numeric)
3. Fuzzy match using Levenshtein distance
4. Prioritize high-velocity items

## Offline Sync Strategy
1. All operations write to local Hive DB first
2. Background sync checks connectivity
3. Generate daily backup JSON
4. Upload to user's Google Drive (Dhandha_Backups folder)
5. Manual restore option

## Implementation Phases

### Phase 1: Foundation ✓
- Data models
- Service classes with sample data
- Theme & color semantics

### Phase 2: Billing Flow ✓
- BillingScreen
- Smart search
- Cart management
- PaymentScreen

### Phase 3: Management ✓
- Dashboard
- Inventory
- Customers/Khata

### Phase 4: Reports & Settings ✓
- Reports screen
- Settings & backup
- Debugging & polish
