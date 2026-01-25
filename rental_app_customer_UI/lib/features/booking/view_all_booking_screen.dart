import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/models/booking_model.dart';
import 'my_booking_card_screen.dart';
import '../../core/widgets/main_bottom_nav.dart';

class ViewAllBookingsScreen extends StatefulWidget {
  const ViewAllBookingsScreen({super.key});

  @override
  State<ViewAllBookingsScreen> createState() => _ViewAllBookingsScreenState();
}

class _ViewAllBookingsScreenState extends State<ViewAllBookingsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.loadMyBookings();
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    if (_selectedFilter == 'All') return bookings;
    return bookings.where((b) => b.status.name.toUpperCase() == _selectedFilter.toUpperCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Upcoming', 'Active', 'Completed', 'Cancelled'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _selectedFilter = filter),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.cardWhite,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Bookings list
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, bookingProvider, child) {
                if (bookingProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookingProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(bookingProvider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadBookings, child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                final filteredBookings = _filterBookings(bookingProvider.bookings);

                if (filteredBookings.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(context, filteredBookings[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: -1),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingDetailsScreen(booking: booking.toJson())),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: booking.carImageUrl != null
                  ? Image.network(
                      booking.carImageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 180,
                        color: AppColors.softBackground,
                        child: const Icon(Icons.car_rental, size: 50),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: AppColors.softBackground,
                      child: const Icon(Icons.car_rental, size: 50),
                    ),
            ),
            const SizedBox(height: 16),

            // Car Name
            Text(
              booking.carName ?? 'Car',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),

            // Booking Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Range
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(booking.pickupDate)} - ${_formatDate(booking.returnDate)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                  color: _getStatusColor(booking.status.name).withOpacity(0.1),                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(booking.status.name)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'UPCOMING':
        return AppColors.primary;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No bookings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
          const SizedBox(height: 8),
          const Text('Start booking your dream car today', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
