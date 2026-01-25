import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'booking_details_screen.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({Key? key}) : super(key: key);

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'BK-001',
      'customer': 'Ahmad Khalil',
      'car': 'Toyota Camry',
      'startDate': 'Jan 10, 2026',
      'endDate': 'Jan 15, 2026',
      'status': 'Active',
      'amount': 225.0,
      'pickupLocation': 'Nablus Center',
      'returnLocation': 'Nablus Center',
    },
    {
      'id': 'BK-002',
      'customer': 'Sara Mohammed',
      'car': 'Honda CR-V',
      'startDate': 'Jan 15, 2026',
      'endDate': 'Jan 20, 2026',
      'status': 'Pending',
      'amount': 275.0,
      'pickupLocation': 'Ramallah Office',
      'returnLocation': 'Ramallah Office',
    },
    {
      'id': 'BK-003',
      'customer': 'Omar Hassan',
      'car': 'Tesla Model 3',
      'startDate': 'Dec 20, 2025',
      'endDate': 'Dec 25, 2025',
      'status': 'Completed',
      'amount': 375.0,
      'pickupLocation': 'Airport',
      'returnLocation': 'Nablus Center',
    },
    {
      'id': 'BK-004',
      'customer': 'Layla Ali',
      'car': 'BMW X5',
      'startDate': 'Jan 5, 2026',
      'endDate': 'Jan 8, 2026',
      'status': 'Completed',
      'amount': 285.0,
      'pickupLocation': 'Nablus Center',
      'returnLocation': 'Nablus Center',
    },
    {
      'id': 'BK-005',
      'customer': 'Yousef Ibrahim',
      'car': 'Mercedes E-Class',
      'startDate': 'Jan 12, 2026',
      'endDate': 'Jan 13, 2026',
      'status': 'Cancelled',
      'amount': 85.0,
      'pickupLocation': 'Ramallah Office',
      'returnLocation': 'Ramallah Office',
    },
  ];

  List<Map<String, dynamic>> get _filteredBookings {
    return _bookings.where((booking) {
      final matchesSearch = booking['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking['car'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' || booking['status'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Bookings'),
      ),
      body: Column(
        children: [
          // Search and Filter
          _buildSearchAndFilter(),

          // Stats Bar
          _buildStatsBar(),

          // Bookings List
          Expanded(
            child: _filteredBookings.isEmpty
                ? _buildEmptyState()
                : _buildBookingsList(),
          ),
        ],
      ),
            bottomNavigationBar: const AdminBottomNav(currentIndex: 2),

    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search bookings...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.softBackground,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Active'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Completed'),
                _buildFilterChip('Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: AppColors.softBackground,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalBookings = _bookings.length;
    final activeBookings = _bookings.where((b) => b['status'] == 'Active').length;
    final pendingBookings = _bookings.where((b) => b['status'] == 'Pending').length;
    final totalRevenue = _bookings
        .where((b) => b['status'] != 'Cancelled')
        .fold<double>(0, (sum, b) => sum + (b['amount'] as double));

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalBookings.toString(), AppColors.primary),
          _buildStatItem('Active', activeBookings.toString(), AppColors.success),
          _buildStatItem('Pending', pendingBookings.toString(), AppColors.warning),
          _buildStatItem('Revenue', '\$${totalRevenue.toStringAsFixed(0)}', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = _filteredBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    switch (status) {
      case 'Active':
        statusColor = AppColors.success;
        break;
      case 'Pending':
        statusColor = AppColors.warning;
        break;
      case 'Completed':
        statusColor = AppColors.info;
        break;
      case 'Cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(bookingId: booking['id'] as String),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['id'],
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer & Car
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  booking['customer'],
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  booking['car'],
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${booking['startDate']} - ${booking['endDate']}',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
                const Spacer(),
                Text(
                  '\$${booking['amount']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
