import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../dashboard/employee_dashboard_screen.dart';



class PickupConfirmationScreen extends StatefulWidget {
  final int taskId;
  final Map<String, dynamic> inspectionData;
  final Map<String, String?> photos;
  final List<Offset?> employeeSignature;
  final List<Offset?> customerSignature;

  const PickupConfirmationScreen({
    Key? key,
    required this.taskId,
    required this.inspectionData,
    required this.photos,
    required this.employeeSignature,
    required this.customerSignature,
  }) : super(key: key);

  @override
  State<PickupConfirmationScreen> createState() => _PickupConfirmationScreenState();
}

class _PickupConfirmationScreenState extends State<PickupConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent going back
      child: Scaffold(
        backgroundColor: AppColors.softBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Success Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Pickup Completed!',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.success,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'All documents and signatures have been collected',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Summary Card
                _buildSummaryCard(),

                const SizedBox(height: 24),

                // Task Details Card
                _buildTaskDetailsCard(),

                const SizedBox(height: 24),

                // Completion Time
                _buildCompletionTimeCard(),

                const SizedBox(height: 40),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SUMMARY CARD ====================
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem(
            icon: Icons.assignment_turned_in,
            label: 'Inspection',
            value: 'Completed',
            color: AppColors.success,
          ),
          const Divider(height: 24),
          _buildSummaryItem(
            icon: Icons.camera_alt,
            label: 'Photos',
            value: '${widget.photos.length} images',
            color: AppColors.info,
          ),
          const Divider(height: 24),
          _buildSummaryItem(
            icon: Icons.draw,
            label: 'Signatures',
            value: '2 signatures',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: color, size: 28),
      ],
    );
  }

  // ==================== TASK DETAILS CARD ====================
  Widget _buildTaskDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Task #${widget.taskId}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Vehicle', 'Toyota RAV4 (ABC-123)'),
          const SizedBox(height: 8),
          _buildDetailRow('Customer', 'Ahmad Khalil'),
          const SizedBox(height: 8),
          _buildDetailRow('Location', 'Al-Masyoun, Ramallah'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== COMPLETION TIME CARD ====================
  Widget _buildCompletionTimeCard() {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: AppColors.info, size: 20),
          const SizedBox(width: 8),
          Text(
            'Completed at $timeString',
            style: AppTextStyles.body.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Back to Dashboard
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _goToDashboard,
            icon: const Icon(Icons.home, size: 24),
            label: const Text(
              'Back to Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // View Details
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _viewDetails,
            icon: const Icon(Icons.receipt_long, size: 24),
            label: const Text(
              'View Full Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HELPERS ====================
  void _goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeDashboardScreen(),
      ),
      (route) => false,
    );
  }

  void _viewDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Report'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Task ID: ${widget.taskId}'),
              const SizedBox(height: 8),
              Text('Odometer: ${widget.inspectionData['odometer']} km'),
              Text('Fuel Level: ${widget.inspectionData['fuelLevel']}'),
              const SizedBox(height: 8),
              Text('Photos: ${widget.photos.length} images'),
              Text('Signatures: 2 (Employee & Customer)'),
              const SizedBox(height: 16),
              Text(
                'All data has been saved successfully.',
                style: TextStyle(color: AppColors.success),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}