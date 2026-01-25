import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'pickup_confirmation_screen.dart';

class PickupSignatureScreen extends StatefulWidget {
  final int taskId;
  final Map<String, dynamic> inspectionData;
  final Map<String, String?> photos;

  const PickupSignatureScreen({
    Key? key,
    required this.taskId,
    required this.inspectionData,
    required this.photos,
  }) : super(key: key);

  @override
  State<PickupSignatureScreen> createState() => _PickupSignatureScreenState();
}

class _PickupSignatureScreenState extends State<PickupSignatureScreen> {
  final List<Offset?> _employeeSignaturePoints = [];
  final List<Offset?> _customerSignaturePoints = [];
  
  bool _employeeSignatureDone = false;
  bool _customerSignatureDone = false;
  
  String _currentSignatureType = 'employee'; // 'employee' or 'customer'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Signatures'),
        actions: [
          TextButton(
            onPressed: _canProceed() ? _onComplete : null,
            child: Text(
              'Complete',
              style: TextStyle(
                color: _canProceed() ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 24),

            // Info Card
            _buildInfoCard(),
            const SizedBox(height: 20),

            // Employee Signature
            _buildSectionTitle('Employee Signature'),
            const SizedBox(height: 12),
            _buildSignatureCard(
              type: 'employee',
              isDone: _employeeSignatureDone,
              signaturePoints: _employeeSignaturePoints,
            ),
            const SizedBox(height: 20),

            // Customer Signature
            _buildSectionTitle('Customer Signature'),
            const SizedBox(height: 12),
            _buildSignatureCard(
              type: 'customer',
              isDone: _customerSignatureDone,
              signaturePoints: _customerSignaturePoints,
            ),
            const SizedBox(height: 20),

            // Agreement Text
            _buildAgreementCard(),
            const SizedBox(height: 20),

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _canProceed() ? _onComplete : null,
                icon: const Icon(Icons.check_circle, size: 24),
                label: const Text(
                  'Complete Pickup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed() ? AppColors.success : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== PROGRESS INDICATOR ====================
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildProgressStep(1, 'Inspection', true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'Photos', true),
          _buildProgressLine(true),
          _buildProgressStep(3, 'Signature', true),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive && number < 3
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppColors.primary : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }

  // ==================== INFO CARD ====================
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.draw,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Step',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Both signatures required to complete',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SIGNATURE CARD ====================
  Widget _buildSignatureCard({
    required String type,
    required bool isDone,
    required List<Offset?> signaturePoints,
  }) {
    final isEmployee = type == 'employee';
    final name = isEmployee ? 'Khaled Ahmad' : 'Ahmad Khalil';
    final role = isEmployee ? 'Employee' : 'Customer';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppColors.success : AppColors.divider,
          width: isDone ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDone 
                  ? AppColors.success.withOpacity(0.1) 
                  : AppColors.softBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  color: isDone ? AppColors.success : AppColors.textSecondary,
                  size: 24,
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
                        role,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (!isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Signature Canvas
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _currentSignatureType = type;
                if (isEmployee) {
                  _employeeSignaturePoints.add(details.localPosition);
                } else {
                  _customerSignaturePoints.add(details.localPosition);
                }
              });
            },
            onPanUpdate: (details) {
              setState(() {
                if (isEmployee) {
                  _employeeSignaturePoints.add(details.localPosition);
                } else {
                  _customerSignaturePoints.add(details.localPosition);
                }
              });
            },
            onPanEnd: (details) {
              setState(() {
                if (isEmployee) {
                  _employeeSignaturePoints.add(null);
                } else {
                  _customerSignaturePoints.add(null);
                }
              });
            },
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.divider,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Placeholder Text
                  if (signaturePoints.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.gesture,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign here',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Signature Canvas
                  CustomPaint(
                    painter: SignaturePainter(signaturePoints),
                    size: Size.infinite,
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                // Clear Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: signaturePoints.isNotEmpty
                        ? () => _clearSignature(type)
                        : null,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Done Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: signaturePoints.length > 10
                        ? () => _confirmSignature(type)
                        : null,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signaturePoints.length > 10
                          ? AppColors.success
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AGREEMENT CARD ====================
  Widget _buildAgreementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Agreement',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'By signing above, both parties confirm that:',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          _buildAgreementItem('• Vehicle inspection has been completed'),
          _buildAgreementItem('• All photos have been taken and verified'),
          _buildAgreementItem('• Vehicle condition is as documented'),
          _buildAgreementItem('• All documents have been verified'),
          _buildAgreementItem('• Terms and conditions are accepted'),
        ],
      ),
    );
  }

  Widget _buildAgreementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall,
      ),
    );
  }

  // ==================== HELPERS ====================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
    );
  }

  void _clearSignature(String type) {
    setState(() {
      if (type == 'employee') {
        _employeeSignaturePoints.clear();
        _employeeSignatureDone = false;
      } else {
        _customerSignaturePoints.clear();
        _customerSignatureDone = false;
      }
    });
  }

  void _confirmSignature(String type) {
    setState(() {
      if (type == 'employee') {
        _employeeSignatureDone = true;
      } else {
        _customerSignatureDone = true;
      }
    });
    
    _showSnackBar('${type == 'employee' ? 'Employee' : 'Customer'} signature confirmed');
  }

  bool _canProceed() {
    return _employeeSignatureDone && _customerSignatureDone;
  }

  void _onComplete() {
    if (_canProceed()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PickupConfirmationScreen(
            taskId: widget.taskId,
            inspectionData: widget.inspectionData,
            photos: widget.photos,
            employeeSignature: _employeeSignaturePoints,
            customerSignature: _customerSignaturePoints,
          ),
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// ==================== SIGNATURE PAINTER ====================
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}