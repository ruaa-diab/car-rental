import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'customer_details_screen.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({Key? key}) : super(key: key);

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _customers = [
    {
      'id': '1',
      'name': 'Ahmad Khalil',
      'email': 'ahmad.khalil@email.com',
      'phone': '+970 599 111 222',
      'totalBookings': 12,
      'activeBookings': 1,
      'totalSpent': 540.0,
      'joinDate': 'Dec 2023',
      'rating': 4.8,
      'avatar': 'A',
    },
    {
      'id': '2',
      'name': 'Sara Mohammed',
      'email': 'sara.m@email.com',
      'phone': '+970 599 222 333',
      'totalBookings': 8,
      'activeBookings': 0,
      'totalSpent': 360.0,
      'joinDate': 'Jan 2024',
      'rating': 4.9,
      'avatar': 'S',
    },
    {
      'id': '3',
      'name': 'Omar Hassan',
      'email': 'omar.hassan@email.com',
      'phone': '+970 599 333 444',
      'totalBookings': 15,
      'activeBookings': 2,
      'totalSpent': 675.0,
      'joinDate': 'Nov 2023',
      'rating': 4.7,
      'avatar': 'O',
    },
    {
      'id': '4',
      'name': 'Layla Ali',
      'email': 'layla.ali@email.com',
      'phone': '+970 599 444 555',
      'totalBookings': 6,
      'activeBookings': 1,
      'totalSpent': 270.0,
      'joinDate': 'Feb 2024',
      'rating': 5.0,
      'avatar': 'L',
    },
    {
      'id': '5',
      'name': 'Yousef Ibrahim',
      'email': 'yousef.i@email.com',
      'phone': '+970 599 555 666',
      'totalBookings': 20,
      'activeBookings': 0,
      'totalSpent': 900.0,
      'joinDate': 'Oct 2023',
      'rating': 4.6,
      'avatar': 'Y',
    },
  ];

  List<Map<String, dynamic>> get _filteredCustomers {
    return _customers.where((customer) {
      return customer['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer['phone'].toString().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: Column(
        children: [
          // Search
          _buildSearch(),

          // Stats Bar
          _buildStatsBar(),

          // Customers List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : _buildCustomersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search customers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.softBackground,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalCustomers = _customers.length;
    final activeCustomers = _customers.where((c) => c['activeBookings'] > 0).length;
    final totalRevenue = _customers.fold<double>(0, (sum, c) => sum + (c['totalSpent'] as double));

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalCustomers.toString(), AppColors.primary),
          _buildStatItem('Active', activeCustomers.toString(), AppColors.success),
          _buildStatItem('Revenue', '\$${totalRevenue.toStringAsFixed(0)}', AppColors.warning),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final hasActiveBooking = customer['activeBookings'] > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerDetailsScreen(customerId: customer['id']),
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
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  customer['avatar'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer['name'],
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (hasActiveBooking)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customer['email'],
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${customer['totalBookings']} Bookings',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.attach_money,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${customer['totalSpent']}',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${customer['rating']}',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
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
            'No customers found',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}