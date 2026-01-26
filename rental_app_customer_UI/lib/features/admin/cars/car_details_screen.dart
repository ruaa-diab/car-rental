import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/car_service.dart';
import 'edit_car_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  Map<String, dynamic>? _car;
  bool _isLoading = true;
  String? _error;

  bool _hasChanges = false; // 👈 track if anything changed

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  Future<void> _loadCar() async {
    try {
      final id = int.tryParse(widget.carId);
      if (id == null) {
        setState(() {
          _error = 'Invalid car id';
          _isLoading = false;
        });
        return;
      }

      final car = await CarService.instance.getCarById(id);
      setState(() {
        _car = car;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------- STATUS HELPERS ----------

  String _getStatus(Map<String, dynamic> car) {
    // نقرأ من active أو isActive
    final isActive = (car['isActive'] ?? car['active']) == true;
    final availableQty = (car['availableQuantity'] ?? 0) as int;

    if (!isActive) return 'Maintenance';
    if (availableQty == 0) return 'Rented';
    return 'Available';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return AppColors.success;
      case 'Rented':
        return AppColors.warning;
      case 'Maintenance':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  // ---------- CHANGE STATUS ACTION ----------

  void _onChangeStatusPressed() {
    if (_car == null) return;

    final currentStatus = _getStatus(_car!);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Car Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStatusOption('Available', currentStatus),
              _buildStatusOption('Rented', currentStatus),
              _buildStatusOption('Maintenance', currentStatus),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(String status, String currentStatus) {
    final isSelected = status == currentStatus;
    return ListTile(
      leading: Icon(
        status == 'Available'
            ? Icons.check_circle
            : status == 'Rented'
                ? Icons.directions_car
                : Icons.build,
        color: _getStatusColor(status),
      ),
      title: Text(status),
      trailing: isSelected
          ? const Icon(Icons.done, color: AppColors.primary)
          : null,
      onTap: () async {
        Navigator.pop(context); // close sheet
        await _updateStatus(status);
      },
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_car == null) return;

    final id = _car!['id'] ?? int.tryParse(widget.carId);
    if (id == null) {
      _showSnackBar(context, 'Invalid car id');
      return;
    }

    // نأخذ نسخة قابلة للتعديل من البيانات الحالية
    final updated = Map<String, dynamic>.from(_car!);

    bool active;
    int availableQty;

    final totalQty =
        (updated['totalQuantity'] ?? updated['availableQuantity'] ?? 1) as int;

    switch (newStatus) {
      case 'Available':
        active = true;
        availableQty = totalQty > 0 ? totalQty : 1;
        break;
      case 'Rented':
        active = true;
        availableQty = 0;
        break;
      case 'Maintenance':
        active = false;
        // نترك الكمية كما هي، فقط نوقف السيارة
        availableQty = (updated['availableQuantity'] ?? 0) as int;
        break;
      default:
        active = true;
        availableQty = (updated['availableQuantity'] ?? 0) as int;
    }

    updated['active'] = active;
    updated['isActive'] = active; // احتياط
    updated['availableQuantity'] = availableQty;

    try {
      await CarService.instance.updateCar(id as int, updated);
      setState(() {
        _car = updated;
        _hasChanges = true; // 👈 اعتبره تعديل
      });
      _showSnackBar(context, 'Status updated to $newStatus');
    } catch (e) {
      _showSnackBar(context, 'Failed to update status: $e');
    }
  }

  // ---------- DISPLAY HELPERS ----------

  String _getFuelDisplay(String? fuel) {
    switch (fuel) {
      case 'PETROL':
        return 'Petrol';
      case 'DIESEL':
        return 'Diesel';
      case 'ELECTRIC':
        return 'Electric';
      case 'HYBRID':
        return 'Hybrid';
      default:
        return fuel ?? '-';
    }
  }

  String _getTransmissionDisplay(String? transmission) {
    if (transmission == null) return '-';
    return transmission.toUpperCase() == 'AUTOMATIC' ? 'Automatic' : 'Manual';
  }

  String _getTypeDisplay(String? type) {
    switch (type) {
      case 'SEDAN':
        return 'Sedan';
      case 'SUV':
        return 'SUV';
      case 'SPORT':
        return 'Sport';
      case 'ELECTRIC':
        return 'Electric';
      case 'LUXURY':
        return 'Luxury';
      case 'COMPACT':
        return 'Compact';
      case 'VAN':
        return 'Van';
      default:
        return type ?? '-';
    }
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _car == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Car Details')),
        body: Center(
          child: Text(
            _error ?? 'Car not found',
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    final car = _car!;
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: _buildAppBar(context, car),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarImage(car),
            _buildCarInfo(car),
            _buildSpecifications(car),
            _buildFeatures(car),
            _buildActions(context, car),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, Map<String, dynamic> car) {
    final brand = (car['brand'] ?? '') as String;
    final model = (car['model'] ?? '') as String;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // نرجع النتيجة للقائمة: هل صار تغييرات؟
          Navigator.pop(context, _hasChanges);
        },
      ),
      title: Text('$brand $model'),
      
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditCarScreen(carId: widget.carId),
              ),
            ).then((value) {
              if (value == true) {
                // تم حفظ التعديل من شاشة EditCar
                setState(() {
                  _hasChanges = true;
                });
                _loadCar(); // نعيد تحميل بيانات السيارة
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildCarImage(Map<String, dynamic> car) {
    final status = _getStatus(car);
    final statusColor = _getStatusColor(status);
    final imageUrl = (car['imageUrl'] ?? '') as String?;

    Widget imageWidget;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.contain,
      );
    } else {
      imageWidget = const Text(
        '🚗',
        style: TextStyle(fontSize: 120),
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          Center(child: imageWidget),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfo(Map<String, dynamic> car) {
    final brand = (car['brand'] ?? '') as String;
    final model = (car['model'] ?? '') as String;
    final price = (car['pricePerDay'] ?? 0).toString();
    final year = (car['year'] ?? '').toString();
    final color = (car['color'] ?? '—').toString();
    final plate = (car['licensePlate'] ?? '—').toString();

    return Container(
      margin: const EdgeInsets.all(16),
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
          // Brand & Model
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$brand $model',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
              ),
              Text(
                '\$$price/day',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoRow(Icons.calendar_today, 'Year', year),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.palette, 'Color', color),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.confirmation_number, 'Plate', plate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: AppTextStyles.caption.copyWith(fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications(Map<String, dynamic> car) {
    final type = _getTypeDisplay(car['type'] as String?);
    final transmission = _getTransmissionDisplay(car['transmission'] as String?);
    final fuel = _getFuelDisplay(car['fuel'] as String?);
    final seats = (car['seats'] ?? 4).toString();

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
            'Specifications',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSpecCard(
                  Icons.category,
                  'Category',
                  type,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecCard(
                  Icons.settings,
                  'Transmission',
                  transmission,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSpecCard(
                  Icons.local_gas_station,
                  'Fuel Type',
                  fuel,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecCard(
                  Icons.airline_seat_recline_normal,
                  'Seats',
                  '$seats Seats',
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(Map<String, dynamic> car) {
    final raw = car['features'];
    final List<String> features =
        raw is List ? raw.map((e) => e.toString()).toList() : const [];

    return Container(
      margin: const EdgeInsets.all(16),
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
            'Features',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (features.isEmpty)
            Text(
              'No extra features',
              style: AppTextStyles.caption,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        feature,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> car) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _onChangeStatusPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Change Status'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Car'),
        content: const Text('Are you sure you want to delete this car?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final id = _car?['id'] ?? int.tryParse(widget.carId);
                if (id == null) {
                  _showSnackBar(context, 'Invalid car id');
                  Navigator.pop(dialogContext);
                  return;
                }
                await CarService.instance.deleteCar(id as int);
                Navigator.pop(dialogContext); // close dialog
                Navigator.pop(context, true); // go back & refresh list
              } catch (e) {
                Navigator.pop(dialogContext);
                _showSnackBar(context, 'Failed to delete: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
