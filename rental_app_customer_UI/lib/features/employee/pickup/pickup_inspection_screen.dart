import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'pickup_camera_screen.dart';


class PickupInspectionScreen extends StatefulWidget {
  final int taskId;

  const PickupInspectionScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<PickupInspectionScreen> createState() => _PickupInspectionScreenState();
}

class _PickupInspectionScreenState extends State<PickupInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Data
  final TextEditingController _odometerController = TextEditingController();
  String _fuelLevel = '50%';
  
  // Exterior Condition
  String _frontCondition = 'Good';
  String _backCondition = 'Good';
  String _leftCondition = 'Good';
  String _rightCondition = 'Good';
  String _roofCondition = 'Good';
  
  // Interior Condition
  String _seatsCondition = 'Good';
  String _dashboardCondition = 'Good';
  String _floorCondition = 'Good';
  String _trunkCondition = 'Good';
  
  // Features Check
  bool _lightsWorking = true;
  bool _acWorking = true;
  bool _allKeysPresent = true;
  bool _documentsPresent = true;
  
  // Documents Verification
  bool _customerIdVerified = false;
  bool _licenseVerified = false;
  
  final List<String> conditionOptions = ['Excellent', 'Good', 'Fair', 'Damaged'];
  final List<String> fuelOptions = ['0%', '25%', '50%', '75%', '100%'];

  @override
  void dispose() {
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Vehicle Inspection'),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 24),

              // Vehicle Info Card
              _buildVehicleInfoCard(),
              const SizedBox(height: 20),

              // Odometer & Fuel
              _buildSectionTitle('Odometer & Fuel Level'),
              const SizedBox(height: 12),
              _buildOdometerFuelCard(),
              const SizedBox(height: 20),

              // Exterior Condition
              _buildSectionTitle('Exterior Condition'),
              const SizedBox(height: 12),
              _buildExteriorCard(),
              const SizedBox(height: 20),

              // Interior Condition
              _buildSectionTitle('Interior Condition'),
              const SizedBox(height: 12),
              _buildInteriorCard(),
              const SizedBox(height: 20),

              // Features Check
              _buildSectionTitle('Features Check'),
              const SizedBox(height: 12),
              _buildFeaturesCard(),
              const SizedBox(height: 20),

              // Documents Verification
              _buildSectionTitle('Documents Verification'),
              const SizedBox(height: 12),
              _buildDocumentsCard(),
              const SizedBox(height: 20),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _canProceed() ? _onNext : null,
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text(
                    'Take Photos',
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
          _buildProgressLine(false),
          _buildProgressStep(2, 'Photos', false),
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
            child: Text(
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

  // ==================== VEHICLE INFO CARD ====================
  Widget _buildVehicleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_car,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toyota RAV4 2023',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ABC-123 • White • SUV',
                  style: TextStyle(
                    fontSize: 14,
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

  // ==================== ODOMETER & FUEL CARD ====================
  Widget _buildOdometerFuelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Odometer
          TextFormField(
            controller: _odometerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Odometer Reading (km)',
              prefixIcon: Icon(Icons.speed, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.softBackground,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter odometer reading';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Fuel Level
          DropdownButtonFormField<String>(
            value: _fuelLevel,
            decoration: InputDecoration(
              labelText: 'Fuel Level',
              prefixIcon: Icon(Icons.local_gas_station, color: AppColors.warning),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.softBackground,
            ),
            items: fuelOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _fuelLevel = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  // ==================== EXTERIOR CARD ====================
  Widget _buildExteriorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildConditionRow('Front', _frontCondition, (value) {
            setState(() => _frontCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Back', _backCondition, (value) {
            setState(() => _backCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Left Side', _leftCondition, (value) {
            setState(() => _leftCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Right Side', _rightCondition, (value) {
            setState(() => _rightCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Roof', _roofCondition, (value) {
            setState(() => _roofCondition = value!);
          }),
        ],
      ),
    );
  }

  // ==================== INTERIOR CARD ====================
  Widget _buildInteriorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildConditionRow('Seats', _seatsCondition, (value) {
            setState(() => _seatsCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Dashboard', _dashboardCondition, (value) {
            setState(() => _dashboardCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Floor', _floorCondition, (value) {
            setState(() => _floorCondition = value!);
          }),
          const Divider(),
          _buildConditionRow('Trunk', _trunkCondition, (value) {
            setState(() => _trunkCondition = value!);
          }),
        ],
      ),
    );
  }

  // ==================== FEATURES CARD ====================
  Widget _buildFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCheckboxRow('Lights Working', _lightsWorking, (value) {
            setState(() => _lightsWorking = value!);
          }),
          _buildCheckboxRow('A/C Working', _acWorking, (value) {
            setState(() => _acWorking = value!);
          }),
          _buildCheckboxRow('All Keys Present', _allKeysPresent, (value) {
            setState(() => _allKeysPresent = value!);
          }),
          _buildCheckboxRow('Documents Present', _documentsPresent, (value) {
            setState(() => _documentsPresent = value!);
          }),
        ],
      ),
    );
  }

  // ==================== DOCUMENTS CARD ====================
  Widget _buildDocumentsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCheckboxRow('Customer ID Verified', _customerIdVerified, (value) {
            setState(() => _customerIdVerified = value!);
          }),
          _buildCheckboxRow('Driving License Verified', _licenseVerified, (value) {
            setState(() => _licenseVerified = value!);
          }),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
    );
  }

  Widget _buildConditionRow(
    String label,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: conditionOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      _getConditionIcon(option),
                      size: 16,
                      color: _getConditionColor(option),
                    ),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
            underline: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  IconData _getConditionIcon(String condition) {
    switch (condition) {
      case 'Excellent':
        return Icons.check_circle;
      case 'Good':
        return Icons.check_circle_outline;
      case 'Fair':
        return Icons.warning;
      case 'Damaged':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.info;
      case 'Fair':
        return AppColors.warning;
      case 'Damaged':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  bool _canProceed() {
    return _odometerController.text.isNotEmpty &&
           _customerIdVerified &&
           _licenseVerified;
  }

  void _onNext() {
    if (_formKey.currentState!.validate() && _canProceed()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickupCameraScreen(
            taskId: widget.taskId,
            inspectionData: {
              'odometer': _odometerController.text,
              'fuelLevel': _fuelLevel,
              'exterior': {
                'front': _frontCondition,
                'back': _backCondition,
                'left': _leftCondition,
                'right': _rightCondition,
                'roof': _roofCondition,
              },
              'interior': {
                'seats': _seatsCondition,
                'dashboard': _dashboardCondition,
                'floor': _floorCondition,
                'trunk': _trunkCondition,
              },
              'features': {
                'lights': _lightsWorking,
                'ac': _acWorking,
                'keys': _allKeysPresent,
                'documents': _documentsPresent,
              },
              'verification': {
                'customerId': _customerIdVerified,
                'license': _licenseVerified,
              },
            },
          ),
        ),
      );
    }
  }
}