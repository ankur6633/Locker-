import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../models/hive_user_model.dart';
import '../models/hive_emi_model.dart';
import 'emi_calculator_service.dart';

/// Service for managing admin data using Hive
class AdminDataService {
  static const String _usersBoxName = 'admin_users';
  static const String _emiBoxName = 'admin_emi';

  Box<HiveUserModel>? _usersBox;
  Box<HiveEmiModel>? _emiBox;
  bool _isInitialized = false;

  /// Initialize Hive boxes
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
    } catch (e) {
      // Already initialized, continue
    }
    
    // Register adapters - Using TypeAdapters instead of generated adapters for now
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(_HiveUserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(_HiveEmiModelAdapter());
    }

    // Open boxes
    if (!Hive.isBoxOpen(_usersBoxName)) {
      _usersBox = await Hive.openBox<HiveUserModel>(_usersBoxName);
    } else {
      _usersBox = Hive.box<HiveUserModel>(_usersBoxName);
    }
    
    if (!Hive.isBoxOpen(_emiBoxName)) {
      _emiBox = await Hive.openBox<HiveEmiModel>(_emiBoxName);
    } else {
      _emiBox = Hive.box<HiveEmiModel>(_emiBoxName);
    }
    
    _isInitialized = true;
  }

  // ============ User Operations ============

  /// Add a new user
  Future<String> addUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (_usersBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = HiveUserModel(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      password: password,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await _usersBox!.put(userId, user);
    return userId;
  }

  /// Verify user login credentials
  HiveUserModel? verifyUserLogin(String emailOrMobile, String password) {
    if (_usersBox == null) {
      return null;
    }
    try {
      final user = _usersBox!.values.firstWhere(
        (u) => (u.email == emailOrMobile || u.phone == emailOrMobile) && 
               u.password == password && 
               u.isActive,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Get all users
  List<HiveUserModel> getAllUsers() {
    if (_usersBox == null) {
      return [];
    }
    return _usersBox!.values.toList();
  }

  /// Get user by ID
  HiveUserModel? getUserById(String userId) {
    if (_usersBox == null) {
      return null;
    }
    return _usersBox!.get(userId);
  }

  /// Update user
  Future<void> updateUser(HiveUserModel user) async {
    if (_usersBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    await _usersBox!.put(user.id, user);
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    if (_usersBox == null || _emiBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    // Also delete associated EMI
    final emis = _emiBox!.values.where((emi) => emi.userId == userId).toList();
    for (final emi in emis) {
      await _emiBox!.delete(emi.id);
    }
    await _usersBox!.delete(userId);
  }

  /// Lock/Unlock device by email
  Future<void> lockDeviceByEmail(String email, bool lock) async {
    if (_usersBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    try {
      final user = _usersBox!.values.firstWhere((u) => u.email == email);
      user.deviceLockedByAdmin = lock;
      await updateUser(user);
      
      // Also lock/unlock associated EMI if exists
      if (user.emiId != null) {
        final emi = getEmiById(user.emiId!);
        if (emi != null) {
          await toggleEmiLock(emi.id, lock);
        }
      }
    } catch (e) {
      throw StateError('User with email $email not found');
    }
  }

  /// Lock/Unlock device by email OR mobile number
  Future<void> lockDeviceByEmailOrMobile(String emailOrMobile, bool lock) async {
    if (_usersBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    try {
      final user = _usersBox!.values.firstWhere(
        (u) => u.email == emailOrMobile || u.phone == emailOrMobile,
      );
      user.deviceLockedByAdmin = lock;
      await updateUser(user);
      
      // Also lock/unlock associated EMI if exists
      if (user.emiId != null) {
        final emi = getEmiById(user.emiId!);
        if (emi != null) {
          await toggleEmiLock(emi.id, lock);
        }
      }
    } catch (e) {
      throw StateError('User with email or mobile $emailOrMobile not found');
    }
  }

  /// Get user by email
  HiveUserModel? getUserByEmail(String email) {
    if (_usersBox == null) {
      return null;
    }
    try {
      return _usersBox!.values.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Get user by email OR mobile number
  HiveUserModel? getUserByEmailOrMobile(String emailOrMobile) {
    if (_usersBox == null) {
      return null;
    }
    try {
      return _usersBox!.values.firstWhere(
        (u) => u.email == emailOrMobile || u.phone == emailOrMobile,
      );
    } catch (e) {
      return null;
    }
  }

  // ============ EMI Operations ============

  /// Create EMI for a user
  Future<String> createEmi({
    required String userId,
    required double principalAmount,
    required double annualInterestRate,
    required int tenureMonths,
    required DateTime startDate,
  }) async {
    if (_emiBox == null || _usersBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    final emiId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Calculate EMI
    final emiAmount = EmiCalculatorService.calculateEmi(
      principalAmount: principalAmount,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
    );

    final totalInterest = EmiCalculatorService.calculateTotalInterest(
      principalAmount: principalAmount,
      emiAmount: emiAmount,
      tenureMonths: tenureMonths,
    );

    final totalAmount = EmiCalculatorService.calculateTotalAmount(
      principalAmount: principalAmount,
      emiAmount: emiAmount,
      tenureMonths: tenureMonths,
    );

    final endDate = DateTime(
      startDate.year,
      startDate.month + tenureMonths,
      startDate.day,
    );

    final nextDueDate = DateTime(
      startDate.year,
      startDate.month + 1,
      startDate.day,
    );

    final emi = HiveEmiModel(
      id: emiId,
      userId: userId,
      totalAmount: totalAmount,
      principalAmount: principalAmount,
      interestAmount: totalInterest,
      emiAmount: emiAmount,
      remainingAmount: totalAmount,
      tenureMonths: tenureMonths,
      interestRate: annualInterestRate,
      startDate: startDate,
      endDate: endDate,
      nextDueDate: nextDueDate,
      status: 'upcoming',
      isLocked: false,
      createdAt: DateTime.now(),
    );

    await _emiBox!.put(emiId, emi);

    // Update user's EMI reference
    final user = getUserById(userId);
    if (user != null) {
      user.emiId = emiId;
      await updateUser(user);
    }

    return emiId;
  }

  /// Get all EMI records
  List<HiveEmiModel> getAllEmis() {
    if (_emiBox == null) {
      return [];
    }
    return _emiBox!.values.toList();
  }

  /// Get EMI by ID
  HiveEmiModel? getEmiById(String emiId) {
    if (_emiBox == null) {
      return null;
    }
    return _emiBox!.get(emiId);
  }

  /// Get EMI by User ID
  HiveEmiModel? getEmiByUserId(String userId) {
    if (_emiBox == null) {
      return null;
    }
    try {
      return _emiBox!.values.firstWhere(
        (emi) => emi.userId == userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update EMI
  Future<void> updateEmi(HiveEmiModel emi) async {
    if (_emiBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    await _emiBox!.put(emi.id, emi);
  }

  /// Lock/Unlock EMI
  Future<void> toggleEmiLock(String emiId, bool lock) async {
    if (_emiBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    final emi = getEmiById(emiId);
    if (emi != null) {
      emi.isLocked = lock;
      if (lock) {
        emi.status = 'overdue';
        final daysOverdue = DateTime.now().difference(emi.nextDueDate).inDays;
        emi.daysOverdue = daysOverdue > 0 ? daysOverdue : 0;
      } else {
        // When unlocking, check if still overdue
        final now = DateTime.now();
        if (emi.nextDueDate.isAfter(now)) {
          emi.status = 'pending';
          emi.daysOverdue = null;
        }
      }
      await updateEmi(emi);
    }
  }

  /// Process payment for EMI
  Future<void> processPayment({
    required String emiId,
    required double amount,
  }) async {
    if (_emiBox == null) {
      throw StateError('Hive box not initialized. Call init() first.');
    }
    final emi = getEmiById(emiId);
    if (emi != null) {
      emi.remainingAmount = EmiCalculatorService.calculateRemainingAmount(
        totalAmount: emi.totalAmount,
        paidAmount: emi.totalAmount - emi.remainingAmount + amount,
      );

      // Update next due date
      emi.nextDueDate = DateTime(
        emi.nextDueDate.year,
        emi.nextDueDate.month + 1,
        emi.nextDueDate.day,
      );

      // Update status
      if (emi.remainingAmount <= 0) {
        emi.status = 'paid';
        emi.isLocked = false;
      } else {
        final now = DateTime.now();
        if (emi.nextDueDate.isBefore(now)) {
          emi.status = 'overdue';
          emi.daysOverdue = now.difference(emi.nextDueDate).inDays;
        } else {
          emi.status = 'pending';
        }
      }

      await updateEmi(emi);
    }
  }

  /// Get dashboard statistics
  Map<String, dynamic> getDashboardStats() {
    final users = getAllUsers();
    final emis = getAllEmis();

    final activeUsers = users.where((u) => u.isActive).length;
    final lockedEmis = emis.where((e) => e.isLocked).length;
    final overdueEmis = emis.where((e) => e.status == 'overdue').length;
    final totalEmiAmount = emis.fold<double>(0, (sum, e) => sum + e.totalAmount);
    final totalRemaining = emis.fold<double>(0, (sum, e) => sum + e.remainingAmount);
    final totalPaid = totalEmiAmount - totalRemaining;

    return {
      'totalUsers': users.length,
      'activeUsers': activeUsers,
      'totalEmis': emis.length,
      'lockedEmis': lockedEmis,
      'overdueEmis': overdueEmis,
      'totalEmiAmount': totalEmiAmount,
      'totalPaid': totalPaid,
      'totalRemaining': totalRemaining,
    };
  }
}

// TypeAdapters for Hive models
class _HiveUserModelAdapter extends TypeAdapter<HiveUserModel> {
  @override
  final int typeId = 0;

  @override
  HiveUserModel read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      // Handle DateTime parsing
      if (key == 'createdAt' && value is String) {
        map[key] = DateTime.parse(value);
      } else {
        map[key] = value;
      }
    }
    return HiveUserModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, HiveUserModel obj) {
    final json = obj.toJson();
    writer.writeByte(json.length);
    json.forEach((key, value) {
      writer.writeString(key);
      if (value is DateTime) {
        writer.write(value.toIso8601String());
      } else {
        writer.write(value);
      }
    });
  }
}

class _HiveEmiModelAdapter extends TypeAdapter<HiveEmiModel> {
  @override
  final int typeId = 1;

  @override
  HiveEmiModel read(BinaryReader reader) {
    final map = <String, dynamic>{};
    final numOfFields = reader.readByte();
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readString();
      final value = reader.read();
      // Handle DateTime parsing
      if ((key == 'startDate' || key == 'endDate' || key == 'nextDueDate' || key == 'createdAt') && value is String) {
        map[key] = DateTime.parse(value);
      } else {
        map[key] = value;
      }
    }
    return HiveEmiModel.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, HiveEmiModel obj) {
    final json = obj.toJson();
    writer.writeByte(json.length);
    json.forEach((key, value) {
      writer.writeString(key);
      if (value is DateTime) {
        writer.write(value.toIso8601String());
      } else {
        writer.write(value);
      }
    });
  }
}
