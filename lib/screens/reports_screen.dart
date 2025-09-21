import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../providers/billing_provider.dart';
import '../models/sale_record.dart';
import '../widgets/loading_widget.dart';
import '../widgets/ultra_simple_card.dart';

/// Reports screen showing analytics and charts
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Today';

  DateTimeRange _getSelectedRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: now);
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return DateTimeRange(start: start, end: now);
      case 'This Month':
        final start = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: start, end: now);
      case 'All Time':
      default:
        final start = DateTime(2000, 1, 1);
        return DateTimeRange(start: start, end: now);
    }
  }

  List<SaleRecord> _filteredSales(AnalyticsProvider analyticsProvider) {
    final range = _getSelectedRange();
    return analyticsProvider.salesRecords.where((SaleRecord r) {
      final d = r.saleDate;
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();
  }

  double _sumSalesAmount(List<SaleRecord> sales) =>
      sales.fold(0.0, (double sum, SaleRecord r) => sum + r.totalAmount);

  double _sumProfit(List<SaleRecord> sales) =>
      sales.fold(0.0, (double sum, SaleRecord r) => sum + r.profit);

  int _sumItemsSold(List<SaleRecord> sales) =>
      sales.fold(0, (int sum, SaleRecord r) => sum + r.quantitySold);

  int _countOrders(List<SaleRecord> sales) =>
      sales.map((SaleRecord r) => r.billId).toSet().length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsProvider>().init();
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, child) {
          if (analyticsProvider.isLoading) {
            return const LoadingWidget(message: 'Loading analytics...');
          }

          final filtered = _filteredSales(analyticsProvider);
          final totalSalesAmount = _sumSalesAmount(filtered);
          final totalProfit = _sumProfit(filtered);
          final totalItems = _sumItemsSold(filtered);
          final totalOrders = _countOrders(filtered);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                _buildPeriodSelector(),
                const SizedBox(height: 16),

                // Summary cards
                _buildSummaryCards(
                  context,
                  totalSalesAmount,
                  totalProfit,
                  totalItems,
                  totalOrders,
                ),
                const SizedBox(height: 24),

                // Sales chart
                _buildSalesChart(context, analyticsProvider),
                const SizedBox(height: 24),

                // Top products
                _buildTopProducts(context, filtered),
                const SizedBox(height: 24),

                // Category sales
                _buildCategorySales(context, filtered),
                const SizedBox(height: 24),

              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh reports when a bill is generated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final billing = context.read<BillingProvider?>();
      billing?.addAfterGenerateListener(() {
        if (mounted) context.read<AnalyticsProvider>().init();
      });
    });
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'Period: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Today', 'This Week', 'This Month', 'All Time']
                    .map(
                      (period) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(period),
                          selected: _selectedPeriod == period,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    double totalSalesAmount,
    double totalProfit,
    int totalItems,
    int totalOrders,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2, // Adjusted for larger cards
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        UltraSimpleStatCard(
          title: 'Total Sales',
          value: '₹${totalSalesAmount.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        UltraSimpleStatCard(
          title: 'Total Profit',
          value: '₹${totalProfit.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.blue,
        ),
        UltraSimpleStatCard(
          title: 'Items Sold',
          value: '$totalItems',
          icon: Icons.inventory,
          color: Colors.orange,
        ),
        UltraSimpleStatCard(
          title: 'Total Orders',
          value: '$totalOrders',
          icon: Icons.receipt_long,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSalesChart(
      BuildContext context,
      AnalyticsProvider analyticsProvider,
      ) {
    final filtered = _filteredSales(analyticsProvider);

    // Generate data based on selected period
    List<Map<String, dynamic>> chartData = [];

    switch (_selectedPeriod) {
      case 'Today':
      // Show hourly data for today
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        for (int hour = 0; hour < 24; hour++) {
          final hourStart = startOfDay.add(Duration(hours: hour));
          final hourEnd = hourStart.add(const Duration(hours: 1));

          final hourSales = filtered
              .where((r) => r.saleDate.isAfter(hourStart) && r.saleDate.isBefore(hourEnd))
              .fold(0.0, (sum, r) => sum + r.totalAmount);

          chartData.add({
            'label': '${hour.toString().padLeft(2, '0')}:00',
            'value': hourSales,
            'date': hourStart,
          });
        }
        break;

      case 'This Week':
      case 'This Month':
      default:
      // Show daily data for week/month/all time
        final range = _getSelectedRange();
        final daysDifference = range.end.difference(range.start).inDays;
        final maxDays = daysDifference > 30 ? 30 : daysDifference; // Limit to 30 days for readability

        for (int i = 0; i <= maxDays; i++) {
          final currentDay = DateTime(
            range.start.year,
            range.start.month,
            range.start.day,
          ).add(Duration(days: i));

          if (currentDay.isAfter(range.end)) break;

          final dayEnd = DateTime(
            currentDay.year,
            currentDay.month,
            currentDay.day,
            23,
            59,
            59,
          );

          final daySales = filtered
              .where((r) =>
          r.saleDate.isAfter(currentDay.subtract(const Duration(seconds: 1))) &&
              r.saleDate.isBefore(dayEnd.add(const Duration(seconds: 1))))
              .fold(0.0, (sum, r) => sum + r.totalAmount);

          chartData.add({
            'label': '${currentDay.day}/${currentDay.month}',
            'value': daySales,
            'date': currentDay,
          });
        }
        break;
    }

    // Find max value for Y-axis scaling
    final maxValue = chartData.isEmpty ? 100.0 :
    chartData.map((d) => d['value'] as double).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend - $_selectedPeriod',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chartData.isEmpty
                  ? Center(
                child: Text(
                  'No sales data available for this period',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
                  : LineChart(
                LineChartData(
                  maxY: maxValue > 0 ? maxValue * 1.2 : 100,
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue > 0 ? maxValue / 5 : 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: maxValue > 0 ? maxValue / 4 : 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: chartData.length > 10 ? (chartData.length / 6).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            return Text(
                              chartData[index]['label'] as String,
                              style: const TextStyle(fontSize: 9),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['value'] as double,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: chartData.length <= 15, // Show dots only for smaller datasets
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(
    BuildContext context,
    List<SaleRecord> filteredSales,
  ) {
    final Map<String, Map<String, dynamic>> productSales = {};
    for (final r in filteredSales) {
      if (productSales.containsKey(r.productId)) {
        productSales[r.productId]!['quantity'] += r.quantitySold;
        productSales[r.productId]!['amount'] += r.totalAmount;
      } else {
        productSales[r.productId] = {
          'productId': r.productId,
          'productName': r.productName,
          'category': r.category,
          'quantity': r.quantitySold,
          'amount': r.totalAmount,
        };
      }
    }
    final topProducts = productSales.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
    final topFive = topProducts.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (topFive.isEmpty)
              Center(
                child: Text(
                  'No sales data available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...topFive.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final product = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['productName'] as String,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${product['quantity']} sold • ₹${(product['amount'] as double).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySales(
      BuildContext context,
      List<SaleRecord> filteredSales,
      ) {
    final Map<String, double> categorySales = {};
    for (final r in filteredSales) {
      categorySales[r.category] = (categorySales[r.category] ?? 0) + r.totalAmount;
    }
    final entries = categorySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Highest first

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Center(
                child: Text(
                  'No category data available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: entries.take(8).toList().map((entry) {
                          final percentage = (entry.value / entries.fold(0.0, (sum, e) => sum + e.value)) * 100;
                          return PieChartSectionData(
                            color: _getCategoryColor(entry.key),
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Color legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: entries.take(8).toList().map((entry) {
                      final percentage = (entry.value / entries.fold(0.0, (sum, e) => sum + e.value)) * 100;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }



  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }
}
