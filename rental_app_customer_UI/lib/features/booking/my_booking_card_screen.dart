import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../core/providers/booking_provider.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final pricePerDay = (booking['pricePerDay'] ?? booking['totalPrice'] ?? 0).toDouble();
    final totalDays = booking['totalDays'] ?? 1;
    final totalPrice = booking['totalPrice'] ?? (pricePerDay * totalDays);
    final insurance = 25.0;
    final grandTotal = totalPrice + insurance;
    
    final carImage = booking['carImageUrl'] ?? booking['carImage'] ?? '';
    final isNetworkImage = carImage.toString().startsWith('http');

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
        title: const Text('Booking Details', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Booking Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(booking['status'] ?? 'UPCOMING').withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor(booking['status'] ?? 'UPCOMING').withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(booking['status'] ?? 'UPCOMING'), color: _getStatusColor(booking['status'] ?? 'UPCOMING'), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['status'] ?? 'UPCOMING', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _getStatusColor(booking['status'] ?? 'UPCOMING'))),
                        const SizedBox(height: 4),
                        Text(_getStatusMessage(booking['status'] ?? 'UPCOMING'), style: TextStyle(fontSize: 13, color: _getStatusColor(booking['status'] ?? 'UPCOMING'))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Car Information Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isNetworkImage
                            ? Image.network(carImage, width: 100, height: 70, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 100, height: 70, color: AppColors.softBackground, child: const Icon(Icons.car_rental)))
                            : carImage.isNotEmpty
                                ? Image.asset(carImage, width: 100, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 100, height: 70, color: AppColors.softBackground, child: const Icon(Icons.car_rental)))
                                : Container(width: 100, height: 70, color: AppColors.softBackground, child: const Icon(Icons.car_rental)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking['carName'] ?? 'Car', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                            const SizedBox(height: 4),
                            Text(booking['carType'] ?? 'Luxury', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pickup Details
            _buildDetailCard(
              context,
              title: 'Pick-up',
              icon: Icons.calendar_today,
              iconColor: AppColors.primary,
              details: [
                _DetailRow(icon: Icons.event, label: 'Date', value: _formatDateValue(booking['pickupDate'])),
                _DetailRow(icon: Icons.access_time, label: 'Time', value: booking['pickupTime'] ?? 'N/A'),
                _DetailRow(icon: Icons.location_on, label: 'Location', value: booking['pickupBranchName'] ?? booking['pickupLocation'] ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 16),

            // Return Details
            _buildDetailCard(
              context,
              title: 'Return',
              icon: Icons.event_available,
              iconColor: Colors.orange,
              details: [
                _DetailRow(icon: Icons.event, label: 'Date', value: _formatDateValue(booking['returnDate'])),
                _DetailRow(icon: Icons.access_time, label: 'Time', value: booking['returnTime'] ?? 'N/A'),
                _DetailRow(icon: Icons.location_on, label: 'Location', value: booking['returnBranchName'] ?? booking['returnLocation'] ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 16),

            // Payment Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  _buildPriceRow('Rental ($totalDays days)', '\$${totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Insurance', '\$${insurance.toStringAsFixed(2)}'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                  _buildPriceRow('Total', '\$${grandTotal.toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            if ((booking['status'] ?? 'UPCOMING').toString().toUpperCase() == 'UPCOMING')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: -1),
    );
  }

  String _formatDateValue(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    if (dateValue is DateTime) {
      return '${dateValue.day.toString().padLeft(2, '0')}/${dateValue.month.toString().padLeft(2, '0')}/${dateValue.year}';
    }
    return dateValue.toString();
  }

  Widget _buildDetailCard(BuildContext context, {required String title, required IconData icon, required Color iconColor, required List<_DetailRow> details}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
            ],
          ),
          const SizedBox(height: 16),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(detail.icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(detail.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                  ],
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500, color: isTotal ? AppColors.primaryText : AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600, color: isTotal ? AppColors.primary : AppColors.primaryText)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return Colors.green;
      case 'UPCOMING': return AppColors.primary;
      case 'COMPLETED': return Colors.grey;
      case 'CANCELLED': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return Icons.directions_car;
      case 'UPCOMING': return Icons.schedule;
      case 'COMPLETED': return Icons.check_circle;
      case 'CANCELLED': return Icons.cancel;
      default: return Icons.info;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return 'Your rental is currently active';
      case 'UPCOMING': return 'Your booking is confirmed';
      case 'COMPLETED': return 'Thank you for renting with us';
      case 'CANCELLED': return 'This booking has been cancelled';
      default: return '';
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep It')),
          ElevatedButton(
            onPressed: () async {
              final bookingId = booking['id'];
              if (bookingId != null) {
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                final success = await bookingProvider.cancelBooking(bookingId);
                Navigator.pop(context); // Close dialog
                if (success) {
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled successfully'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(bookingProvider.error ?? 'Failed to cancel booking'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;

  _DetailRow({required this.icon, required this.label, required this.value});
}
