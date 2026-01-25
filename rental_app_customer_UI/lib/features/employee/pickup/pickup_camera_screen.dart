import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'pickup_signature_screen.dart';

class PickupCameraScreen extends StatefulWidget {
  final int taskId;
  final Map<String, dynamic> inspectionData;

  const PickupCameraScreen({
    super.key,
    required this.taskId,
    required this.inspectionData,
  });

  @override
  State<PickupCameraScreen> createState() => _PickupCameraScreenState();
}

class _PickupCameraScreenState extends State<PickupCameraScreen> {
  final Map<String, String?> _photos = {
    'front': null,
    'back': null,
    'left': null,
    'right': null,
    'interior': null,
    'odometer': null,
  };

  final Map<String, String> _photoLabels = {
    'front': 'Front View',
    'back': 'Back View',
    'left': 'Left Side',
    'right': 'Right Side',
    'interior': 'Interior',
    'odometer': 'Odometer Reading',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Take Photos'),
        actions: [
          TextButton(
            onPressed: _canProceed() ? _onNext : null,
            child: Text(
              'Next',
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

            // Instructions
            _buildSectionTitle('Photo Requirements'),
            const SizedBox(height: 12),
            _buildInstructionsCard(),
            const SizedBox(height: 20),

            // Photo Grid
            _buildSectionTitle('Vehicle Photos (${_getCompletedCount()}/${_photos.length})'),
            const SizedBox(height: 12),
            _buildPhotoGrid(),
            const SizedBox(height: 20),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _canProceed() ? _onNext : null,
                icon: const Icon(Icons.edit, size: 24),
                label: const Text(
                  'Add Signature',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed() ? AppColors.primary : Colors.grey,
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
          _buildProgressLine(false),
          _buildProgressStep(3, 'Signature', false),
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
            child: isActive && number < 2
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
          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.camera_alt,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Vehicle Condition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Take clear photos of all required angles',
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

  // ==================== INSTRUCTIONS CARD ====================
  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tips for Better Photos:',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem('• Ensure good lighting'),
          _buildInstructionItem('• Capture the entire vehicle in frame'),
          _buildInstructionItem('• Focus on any existing damage'),
          _buildInstructionItem('• Keep camera steady'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ==================== PHOTO GRID ====================
  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photoKey = _photos.keys.elementAt(index);
        return _buildPhotoCard(photoKey);
      },
    );
  }

  Widget _buildPhotoCard(String photoKey) {
    final hasPhoto = _photos[photoKey] != null;
    final label = _photoLabels[photoKey]!;

    return GestureDetector(
      onTap: () => _takePhoto(photoKey),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto ? AppColors.success : AppColors.divider,
            width: hasPhoto ? 2 : 1,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasPhoto) ...[
              // Photo Preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      // Placeholder for actual photo
                      const Center(
                        child: Icon(
                          Icons.check_circle,
                          size: 48,
                          color: AppColors.success,
                        ),
                      ),
                      // Retake button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ] else ...[
              // Empty State
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to capture',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
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

  int _getCompletedCount() {
    return _photos.values.where((photo) => photo != null).length;
  }

  bool _canProceed() {
    // All photos must be taken
    return _photos.values.every((photo) => photo != null);
  }

  void _takePhoto(String photoKey) async {
    // Simulate taking a photo
    // في الواقع، استخدمي image_picker package
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Take ${_photoLabels[photoKey]}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Camera functionality requires image_picker package',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            SizedBox(height: 16),
            Text(
              'For demo purposes, we\'ll mark this photo as taken',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _photos[photoKey] = 'photo_${photoKey}_${DateTime.now().millisecondsSinceEpoch}';
              });
              Navigator.pop(context);
              _showSnackBar('Photo captured successfully');
            },
            child: const Text('Simulate Capture'),
          ),
        ],
      ),
    );
  }

  void _onNext() {
    if (_canProceed()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickupSignatureScreen(
            taskId: widget.taskId,
            inspectionData: widget.inspectionData,
            photos: _photos,
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