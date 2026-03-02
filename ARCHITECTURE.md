# Architecture Documentation

## Overview

This EMI Locker application follows **Clean Architecture** principles with **MVVM** pattern, ensuring separation of concerns, testability, and maintainability.

## Architecture Layers

### 1. Domain Layer (`lib/domain/`)

**Purpose**: Contains business logic and entities independent of frameworks.

**Components**:
- **Entities**: Pure business objects (User, Emi, Payment, EmiScheduleItem)
- **Repository Interfaces**: Contracts for data access
- **Use Cases**: Business logic operations

**Key Principles**:
- No dependencies on external frameworks
- Pure Dart code
- Business rules validation

### 2. Data Layer (`lib/data/`)

**Purpose**: Implements data access and repository contracts.

**Components**:
- **Models**: Data transfer objects extending entities
- **Data Sources**: 
  - Remote: API client using Dio
  - Local: SharedPreferences and FlutterSecureStorage
- **Repository Implementations**: Concrete implementations of domain repositories

**Key Features**:
- Error handling and exception mapping
- Caching strategies
- Mock implementations for testing

### 3. Presentation Layer (`lib/presentation/`)

**Purpose**: UI and user interaction.

**Components**:
- **Screens**: Full-page UI components
- **ViewModels**: State management using ChangeNotifier
- **Widgets**: Reusable UI components

**Pattern**: MVVM (Model-View-ViewModel)
- View: Screens and Widgets
- ViewModel: Business logic and state
- Model: Domain entities

## Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↑        ↑
     └───────────┴────────┘
```

- Presentation depends on Domain
- Data depends on Domain
- Presentation does NOT depend on Data directly
- Domain has no dependencies

## State Management

Using **Provider** package with **ChangeNotifier**:
- ViewModels extend ChangeNotifier
- Screens consume ViewModels via Provider
- State changes trigger UI updates automatically

## Dependency Injection

Using **GetIt** for dependency injection:
- All dependencies registered in `injection_container.dart`
- Lazy singleton pattern for repositories
- Easy to mock for testing

## Error Handling

### Exception → Failure Mapping

1. **Data Layer**: Catches exceptions and converts to Failures
2. **Domain Layer**: Uses Failure objects (no exceptions)
3. **Presentation Layer**: Handles Failures and displays errors

### Error Types

- `ServerFailure`: API/server errors
- `NetworkFailure`: Network connectivity issues
- `CacheFailure`: Local storage errors
- `AuthFailure`: Authentication errors
- `ValidationFailure`: Input validation errors
- `DeviceControlFailure`: Device control operation errors

## Data Flow Example: Login

1. **User Action**: User enters credentials and taps login
2. **View**: LoginScreen calls `authViewModel.login()`
3. **ViewModel**: LoginUseCase is executed
4. **Use Case**: Calls AuthRepository.login()
5. **Repository**: 
   - Calls RemoteDataSource (API)
   - Saves token to LocalDataSource
   - Returns User entity
6. **ViewModel**: Updates state (isLoggedIn, user)
7. **View**: Rebuilds with new state, navigates to Dashboard

## Testing Strategy

### Unit Tests
- Use Cases: Test business logic
- ViewModels: Test state management
- Repositories: Test data transformation

### Integration Tests
- Repository implementations with mock data sources
- ViewModel integration with repositories

### Widget Tests
- Individual widgets
- Screen components

### Mock Data Sources
- `AuthRemoteDataSourceMock`: Mock authentication
- `EmiRemoteDataSourceMock`: Mock EMI data

## Code Organization Principles

1. **Single Responsibility**: Each class has one reason to change
2. **Open/Closed**: Open for extension, closed for modification
3. **Dependency Inversion**: Depend on abstractions, not concretions
4. **Interface Segregation**: Small, focused interfaces
5. **DRY**: Don't Repeat Yourself

## File Naming Conventions

- **Entities**: `snake_case.dart` (e.g., `user.dart`, `emi.dart`)
- **Models**: `snake_case_model.dart` (e.g., `user_model.dart`)
- **ViewModels**: `snake_case_view_model.dart` (e.g., `auth_view_model.dart`)
- **Screens**: `snake_case_screen.dart` (e.g., `login_screen.dart`)
- **Widgets**: `snake_case_widget.dart` (e.g., `loading_widget.dart`)

## Best Practices

1. **Immutability**: Entities and models are immutable
2. **Null Safety**: Full null safety throughout
3. **Type Safety**: Strong typing, avoid dynamic
4. **Error Handling**: Always handle errors gracefully
5. **Documentation**: Comment complex logic
6. **Constants**: Use constants for magic values
7. **Validation**: Validate inputs at boundaries

## Future Enhancements

1. **Caching Strategy**: Implement proper caching with TTL
2. **Offline Support**: Handle offline scenarios
3. **Real-time Updates**: WebSocket integration
4. **Analytics**: Add analytics tracking
5. **Crash Reporting**: Integrate crash reporting
6. **CI/CD**: Set up continuous integration
