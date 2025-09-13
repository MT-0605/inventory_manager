import 'package:flutter/foundation.dart';
import '../models/sale_record.dart';
import '../models/bill.dart';
import '../services/firebase_service.dart';

/// Analytics provider for managing sales data and reports
class AnalyticsProvider with ChangeNotifier {
  List<SaleRecord> _salesRecords = [];
  List<Bill> _recentBills = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SaleRecord> get salesRecords => _salesRecords;
  List<Bill> get recentBills => _recentBills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize and load analytics data
  Future<void> init() async {
    await loadSalesRecords();
    await loadRecentBills();
  }

  /// Load sales records from Firestore
  Future<void> loadSalesRecords() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await FirebaseService.salesCollection
          .orderBy('saleDate', descending: true)
          .get();

      _salesRecords = querySnapshot.docs
          .map((doc) => SaleRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      _setError('Failed to load sales records: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent bills
  Future<void> loadRecentBills() async {
    try {
      final querySnapshot = await FirebaseService.billsCollection
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _recentBills = querySnapshot.docs
          .map((doc) => Bill.fromFirestore(doc))
          .toList();
    } catch (e) {
      _setError('Failed to load recent bills: $e');
    }
  }

  /// Get sales records for a specific date range
  List<SaleRecord> getSalesForDateRange(DateTime startDate, DateTime endDate) {
    return _salesRecords.where((record) {
      return record.saleDate.isAfter(startDate) &&
          record.saleDate.isBefore(endDate);
    }).toList();
  }

  /// Get total sales amount
  double get totalSalesAmount {
    return _salesRecords.fold(0.0, (sum, record) => sum + record.totalAmount);
  }

  /// Get total profit
  double get totalProfit {
    return _salesRecords.fold(0.0, (sum, record) => sum + record.profit);
  }

  /// Get total items sold
  int get totalItemsSold {
    return _salesRecords.fold(0, (sum, record) => sum + record.quantitySold);
  }

  /// Get total number of sales
  int get totalSales => _salesRecords.length;

  /// Get sales for today
  List<SaleRecord> get todaySales {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSalesForDateRange(startOfDay, endOfDay);
  }

  /// Get today's sales amount
  double get todaySalesAmount {
    return todaySales.fold(0.0, (sum, record) => sum + record.totalAmount);
  }

  /// Get today's profit
  double get todayProfit {
    return todaySales.fold(0.0, (sum, record) => sum + record.profit);
  }

  /// Get sales for this week
  List<SaleRecord> get thisWeekSales {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return getSalesForDateRange(startOfWeekDay, now);
  }

  /// Get this week's sales amount
  double get thisWeekSalesAmount {
    return thisWeekSales.fold(0.0, (sum, record) => sum + record.totalAmount);
  }

  /// Get sales for this month
  List<SaleRecord> get thisMonthSales {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getSalesForDateRange(startOfMonth, now);
  }

  /// Get this month's sales amount
  double get thisMonthSalesAmount {
    return thisMonthSales.fold(0.0, (sum, record) => sum + record.totalAmount);
  }

  /// Get top selling products
  List<Map<String, dynamic>> get topSellingProducts {
    final Map<String, Map<String, dynamic>> productSales = {};

    for (final record in _salesRecords) {
      if (productSales.containsKey(record.productId)) {
        productSales[record.productId]!['quantity'] += record.quantitySold;
        productSales[record.productId]!['amount'] += record.totalAmount;
      } else {
        productSales[record.productId] = {
          'productId': record.productId,
          'productName': record.productName,
          'category': record.category,
          'quantity': record.quantitySold,
          'amount': record.totalAmount,
        };
      }
    }

    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    return sortedProducts.take(10).toList();
  }

  /// Get sales by category
  Map<String, double> get salesByCategory {
    final Map<String, double> categorySales = {};

    for (final record in _salesRecords) {
      categorySales[record.category] =
          (categorySales[record.category] ?? 0) + record.totalAmount;
    }

    return categorySales;
  }

  /// Get daily sales data for charts (last 30 days)
  List<Map<String, dynamic>> get dailySalesData {
    final Map<String, Map<String, dynamic>> dailyData = {};
    final now = DateTime.now();

    // Initialize last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailyData[dateKey] = {
        'date': date,
        'sales': 0.0,
        'profit': 0.0,
        'items': 0,
      };
    }

    // Add actual sales data
    for (final record in _salesRecords) {
      final dateKey =
          '${record.saleDate.year}-${record.saleDate.month.toString().padLeft(2, '0')}-${record.saleDate.day.toString().padLeft(2, '0')}';
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey]!['sales'] += record.totalAmount;
        dailyData[dateKey]!['profit'] += record.profit;
        dailyData[dateKey]!['items'] += record.quantitySold;
      }
    }

    return dailyData.values.toList()..sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
  }

  /// Get monthly sales data for charts (last 12 months)
  List<Map<String, dynamic>> get monthlySalesData {
    final Map<String, Map<String, dynamic>> monthlyData = {};
    final now = DateTime.now();

    // Initialize last 12 months
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyData[monthKey] = {
        'month': date,
        'sales': 0.0,
        'profit': 0.0,
        'items': 0,
      };
    }

    // Add actual sales data
    for (final record in _salesRecords) {
      final monthKey =
          '${record.saleDate.year}-${record.saleDate.month.toString().padLeft(2, '0')}';
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey]!['sales'] += record.totalAmount;
        monthlyData[monthKey]!['profit'] += record.profit;
        monthlyData[monthKey]!['items'] += record.quantitySold;
      }
    }

    return monthlyData.values.toList()..sort(
      (a, b) => (a['month'] as DateTime).compareTo(b['month'] as DateTime),
    );
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
