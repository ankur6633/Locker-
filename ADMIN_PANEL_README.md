# EMI Locker Admin Panel

A comprehensive Flutter Web Admin Panel for managing EMI Locker application without backend. All data is stored locally using Hive.

## Features

### ✅ Complete Admin Panel Features

1. **Dashboard**
   - Real-time statistics
   - Total users, active users
   - Total EMI records
   - Locked devices count
   - Overdue EMI tracking
   - Financial summaries (Total EMI, Paid, Remaining)

2. **User Management**
   - Add new users with form validation
   - View all users with details
   - Toggle user active/inactive status
   - Delete users
   - User-EMI relationship tracking

3. **EMI Management**
   - Create EMI with automatic calculation
   - EMI calculation using standard formula
   - View all EMI records
   - Expandable EMI details
   - Process payments
   - Lock/Unlock devices per EMI

4. **Lock Control**
   - Split view: Locked vs Unlocked devices
   - One-click lock/unlock
   - Visual status indicators
   - Device status management

## Architecture

### Data Layer
- **Hive Storage**: Local NoSQL database
- **Models**: `HiveUserModel`, `HiveEmiModel`
- **Service**: `AdminDataService` - Handles all CRUD operations

### Business Logic
- **EMI Calculator**: `EmiCalculatorService`
  - Standard EMI formula: `EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]`
  - Interest calculation
  - Schedule generation

### Presentation Layer
- **State Management**: Provider
- **ViewModels**:
  - `AdminDashboardViewModel`
  - `AdminUsersViewModel`
  - `AdminEmiViewModel`

### UI Components
- **Sidebar Navigation**: Professional admin sidebar
- **Responsive Design**: Desktop-optimized layout
- **Material 3**: Modern design system
- **Cards & Lists**: Clean data presentation

## File Structure

```
lib/admin/
├── models/
│   ├── hive_user_model.dart
│   └── hive_emi_model.dart
├── services/
│   ├── admin_data_service.dart
│   └── emi_calculator_service.dart
├── viewmodels/
│   ├── admin_dashboard_viewmodel.dart
│   ├── admin_users_viewmodel.dart
│   └── admin_emi_viewmodel.dart
├── screens/
│   ├── admin_main_screen.dart
│   ├── admin_dashboard_screen.dart
│   ├── admin_users_screen.dart
│   ├── admin_add_user_dialog.dart
│   ├── admin_emi_screen.dart
│   ├── admin_create_emi_dialog.dart
│   └── admin_lock_control_screen.dart
└── admin_app.dart
```

## Running the Admin Panel

### Option 1: Separate Entry Point (Recommended for Web)

```bash
# Run admin panel
flutter run -d chrome --target=lib/admin_main.dart
```

### Option 2: Modify main.dart

You can modify `main.dart` to detect platform and show admin panel on web:

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    // Run admin panel on web
    runApp(const AdminApp());
  } else {
    // Run mobile app
    await init();
    runApp(const MyApp());
  }
}
```

## Usage

### Adding a User

1. Navigate to **Users** section
2. Click **Add User** button
3. Fill in:
   - Full Name
   - Email
   - Phone Number
4. Click **Add User**

### Creating EMI

1. Navigate to **EMI Management** section
2. Click **Create EMI** button
3. Select a user
4. Enter:
   - Principal Amount
   - Annual Interest Rate (%)
   - Tenure (Months)
   - Start Date
5. Click **Create EMI**

The system automatically calculates:
- EMI Amount
- Total Interest
- Total Amount
- End Date
- Next Due Date

### Locking/Unlocking Devices

1. Navigate to **Lock Control** section
2. View locked/unlocked devices in split view
3. Click **Lock** or **Unlock** button
4. Confirm the action

### Processing Payments

1. Navigate to **EMI Management** section
2. Expand an EMI record
3. Click **Process Payment**
4. Enter payment amount
5. Click **Process**

The system automatically updates:
- Remaining amount
- Next due date
- EMI status
- Lock status (if fully paid)

## EMI Calculation Formula

The EMI is calculated using the standard formula:

```
EMI = [P × R × (1+R)^N] / [(1+R)^N - 1]

Where:
P = Principal Amount
R = Monthly Interest Rate (Annual Rate / 12 / 100)
N = Number of Months
```

## Data Persistence

All data is stored locally using Hive:
- **Users Box**: `admin_users`
- **EMI Box**: `admin_emi`

Data persists across app restarts and is stored in browser's IndexedDB (web) or device storage (mobile).

## Responsive Design

The admin panel is optimized for desktop:
- **Large screens (>1400px)**: 4-column grid
- **Medium screens (1000-1400px)**: 3-column grid
- **Small screens (600-1000px)**: 2-column grid
- **Mobile (<600px)**: 1-column grid

## Features Summary

✅ **No Backend Required** - Everything stored locally  
✅ **Provider State Management** - Reactive UI updates  
✅ **Hive Storage** - Fast local database  
✅ **EMI Calculation** - Accurate financial calculations  
✅ **Lock/Unlock Simulation** - Device control management  
✅ **Dashboard Summary** - Real-time statistics  
✅ **Sidebar Navigation** - Professional admin UI  
✅ **Responsive Design** - Desktop-optimized  
✅ **Form Validation** - Input validation  
✅ **Error Handling** - User-friendly error messages  

## Future Enhancements

- Export data to CSV/Excel
- Import users from CSV
- Advanced filtering and search
- Payment history tracking
- Email notifications simulation
- Reports generation
- Data backup/restore

## Notes

- The admin panel uses TypeAdapters for Hive models (no code generation required)
- All calculations are done client-side
- Data is stored in browser's IndexedDB when running on web
- The panel is designed for desktop use but works on mobile with responsive layout
