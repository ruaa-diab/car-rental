import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'This Year'];

  bool _isLoading = true;
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _revenueReport = {};
  Map<String, dynamic> _bookingStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final double number = (value is int) ? value.toDouble() : (value is double) ? value : double.tryParse(value.toString()) ?? 0;
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'This Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default: // This Month
          startDate = DateTime(now.year, now.month, 1);
      }

      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = now.toIso8601String().split('T')[0];

      final results = await Future.wait([
        ReportService.instance.getDashboardStats(),
        ReportService.instance.getRevenueReport(startDateStr, endDateStr),
        ReportService.instance.getBookingStats(),
      ]);

      if (mounted) {
        setState(() {
          _dashboardStats = results[0];
          _revenueReport = results[1];
          _bookingStats = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reports: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),

                    const SizedBox(height: 16),

                    // Revenue Card
                    _buildRevenueCard(),

                    const SizedBox(height: 16),

                    // Stats Grid
                    _buildStatsGrid(),

                    const SizedBox(height: 16),

                    // Top Cars
                    _buildTopCars(),

                    const SizedBox(height: 16),

                    // Top Customers
                    _buildTopCustomers(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      color: AppColors.cardWhite,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = period == _selectedPeriod;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success,
            AppColors.success.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Revenue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+15%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${_formatNumber(_revenueReport['totalRevenue'] ?? _dashboardStats['monthlyRevenue'] ?? 0)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'For $_selectedPeriod',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildStatCard(
            'Total Bookings',
            '${_bookingStats['total'] ?? 0}',
            Icons.event,
            AppColors.primary,
            '+${_bookingStats['thisMonth'] ?? 0}',
          ),
          _buildStatCard(
            'Active Cars',
            '${_dashboardStats['totalCars'] ?? 0}',
            Icons.directions_car,
            AppColors.info,
            '${_dashboardStats['activeBookings'] ?? 0} rented',
          ),
          _buildStatCard(
            'Total Customers',
            '${_dashboardStats['totalCustomers'] ?? 0}',
            Icons.people,
            AppColors.warning,
            '+${_bookingStats['thisWeek'] ?? 0} this week',
          ),
          _buildStatCard(
            'Completed',
            '${_bookingStats['completed'] ?? 0}',
            Icons.check_circle,
            AppColors.success,
            '${_bookingStats['upcoming'] ?? 0} upcoming',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCars() {
    final topCars = [
      {'name': 'Toyota Camry', 'bookings': 12, 'revenue': 540.0},
      {'name': 'Honda CR-V', 'bookings': 10, 'revenue': 550.0},
      {'name': 'Tesla Model 3', 'bookings': 8, 'revenue': 600.0},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Cars',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...topCars.asMap().entries.map((entry) {
            final index = entry.key;
            final car = entry.value;
            return Column(
              children: [
                _buildTopCarItem(
                  index + 1,
                  car['name'] as String,
                  car['bookings'] as int,
                  car['revenue'] as double,
                ),
                if (index < topCars.length - 1) ...[
                  const SizedBox(height: 12),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopCarItem(int rank, String name, int bookings, double revenue) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank == 1 ? AppColors.warning.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank == 1 ? AppColors.warning : AppColors.primary,
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
                name,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$bookings bookings',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        Text(
          '\$${revenue.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomers() {
    final topCustomers = [
      {'name': 'Ahmad Khalil', 'bookings': 12, 'spent': 540.0},
      {'name': 'Omar Hassan', 'bookings': 15, 'spent': 675.0},
      {'name': 'Yousef Ibrahim', 'bookings': 20, 'spent': 900.0},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Customers',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...topCustomers.asMap().entries.map((entry) {
            final index = entry.key;
            final customer = entry.value;
            return Column(
              children: [
                _buildTopCustomerItem(
                  index + 1,
                  customer['name'] as String,
                  customer['bookings'] as int,
                  customer['spent'] as double,
                ),
                if (index < topCustomers.length - 1) ...[
                  const SizedBox(height: 12),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopCustomerItem(int rank, String name, int bookings, double spent) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank == 1 ? AppColors.warning.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank == 1 ? AppColors.warning : AppColors.success,
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
                name,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$bookings bookings',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        Text(
          '\$${spent.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

}