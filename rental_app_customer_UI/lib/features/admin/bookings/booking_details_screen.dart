import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailsScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final booking = {
      'id': bookingId,
      'customer': 'Ahmad Khalil',
      'customerPhone': '+970 599 111 222',
      'car': 'Toyota Camry 2024',
      'plateNumber': 'ABC-1234',
      'startDate': 'Jan 10, 2026',
      'endDate': 'Jan 15, 2026',
      'days': 5,
      'status': 'Active',
      'pricePerDay': 45.0,
      'totalAmount': 225.0,
      'pickupLocation': 'Nablus Center',
      'returnLocation': 'Nablus Center',
      'pickupTime': '10:00 AM',
      'returnTime': '10:00 AM',
      'employee': 'Khaled Ahmad',
    };

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: _buildAppBar(context, booking),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Banner
            _buildStatusBanner(booking),

            const SizedBox(height: 16),

            // Booking Info
            _buildBookingInfo(booking),

            const SizedBox(height: 16),

            // Customer Info
            _buildCustomerInfo(booking),

            const SizedBox(height: 16),

            // Car Info
            _buildCarInfo(booking),

            const SizedBox(height: 16),

            // Dates & Location
            _buildDatesAndLocation(booking),

            const SizedBox(height: 16),

            // Pricing
            _buildPricing(booking),

            const SizedBox(height: 16),

            // Actions
            _buildActions(context, booking),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Map<String, dynamic> booking) {
    return AppBar(
      title: Text(booking['id']),
    );
  }

  Widget _buildStatusBanner(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'Active':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'Pending':
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        break;
      case 'Completed':
        statusColor = AppColors.info;
        statusIcon = Icons.done_all;
        break;
      case 'Cancelled':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            'Booking $status',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo(Map<String, dynamic> booking) {
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
            'Booking Information',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Booking ID', booking['id']),
          _buildDivider(),
          _buildInfoRow('Duration', '${booking['days']} Days'),
          _buildDivider(),
          _buildInfoRow('Assigned Employee', booking['employee']),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(Map<String, dynamic> booking) {
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
            'Customer Information',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', booking['customer']),
          _buildDivider(),
          _buildInfoRow('Phone', booking['customerPhone']),
        ],
      ),
    );
  }

  Widget _buildCarInfo(Map<String, dynamic> booking) {
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
            'Car Information',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Car', booking['car']),
          _buildDivider(),
          _buildInfoRow('Plate Number', booking['plateNumber']),
        ],
      ),
    );
  }

  Widget _buildDatesAndLocation(Map<String, dynamic> booking) {
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
            'Dates & Location',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Pickup Date', '${booking['startDate']} at ${booking['pickupTime']}'),
          _buildDivider(),
          _buildInfoRow('Return Date', '${booking['endDate']} at ${booking['returnTime']}'),
          _buildDivider(),
          _buildInfoRow('Pickup Location', booking['pickupLocation']),
          _buildDivider(),
          _buildInfoRow('Return Location', booking['returnLocation']),
        ],
      ),
    );
  }

  Widget _buildPricing(Map<String, dynamic> booking) {
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
            'Pricing',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Price per Day', '\$${booking['pricePerDay']}'),
          _buildDivider(),
          _buildInfoRow('Number of Days', '${booking['days']}'),
          _buildDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${booking['totalAmount']}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> booking) {
    final status = booking['status'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (status == 'Pending') ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showSnackBar(context, 'Booking approved', AppColors.success);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Approve Booking'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  _showCancelDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel Booking'),
              ),
            ),
          ],
          if (status == 'Active') ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showSnackBar(context, 'Booking completed', AppColors.info);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Complete Booking'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.divider);
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Booking cancelled', AppColors.error);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: color,
      ),
    );
  }
}