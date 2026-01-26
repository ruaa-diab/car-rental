import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/car_service.dart';

class EditCarScreen extends StatefulWidget {
  final String carId;

  const EditCarScreen({super.key, required this.carId});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  String _selectedCategory = 'Sedan';
  String _selectedTransmission = 'Automatic';
  String _selectedFuelType = 'Gasoline';
  String _selectedSeats = '5';
  String _selectedStatus = 'Available';

  final List<String> _categories = ['Sedan', 'SUV', 'Luxury', 'Electric', 'Sports'];
  final List<String> _transmissions = ['Automatic', 'Manual'];
  final List<String> _fuelTypes = ['Gasoline', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _seats = ['2', '4', '5', '7', '8'];
  final List<String> _statuses = ['Available', 'Rented', 'Maintenance'];

  final List<String> _features = [];
  final List<String> _availableFeatures = [
    'GPS',
    'Bluetooth',
    'Backup Camera',
    'USB Ports',
    'Sunroof',
    'Leather Seats',
    'Cruise Control',
    'Apple CarPlay',
  ];

  Map<String, dynamic>? _car;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
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
      _car = car;

      final brand = (car['brand'] ?? '').toString();
      final model = (car['model'] ?? '').toString();
      final year = (car['year'] ?? '').toString();
      final color = (car['color'] ?? '').toString();
      final plate = (car['licensePlate'] ?? car['plateNumber'] ?? '').toString();
      final price = (car['pricePerDay'] ?? '').toString();
      final mileage = (car['mileage'] ?? '').toString();

      _brandController.text = brand;
      _modelController.text = model;
      _yearController.text = year;
      _colorController.text = color;
      _plateNumberController.text = plate;
      _priceController.text = price;
      _mileageController.text = mileage;

      // Type → Category select
      final typeRaw = (car['type'] ?? '').toString().toUpperCase();
      _selectedCategory = _mapTypeToCategory(typeRaw);

      // Transmission
      final transRaw = (car['transmission'] ?? '').toString().toUpperCase();
      _selectedTransmission =
          transRaw == 'AUTOMATIC' ? 'Automatic' : 'Manual';

      // Fuel
      final fuelRaw = (car['fuel'] ?? '').toString().toUpperCase();
      _selectedFuelType = _mapFuelToUi(fuelRaw);

      // Seats
      final seats = (car['seats'] ?? 4).toString();
      if (_seats.contains(seats)) {
        _selectedSeats = seats;
      } else {
        _selectedSeats = '4';
      }

      // Status: from active + availableQuantity
      final isActive = (car['isActive'] ?? car['active']) == true;
      final availableQty = (car['availableQuantity'] ?? 0) as int;

      if (!isActive) {
        _selectedStatus = 'Maintenance';
      } else if (availableQty == 0) {
        _selectedStatus = 'Rented';
      } else {
        _selectedStatus = 'Available';
      }

      // Features (if backend returns them)
      final rawFeatures = car['features'];
      if (rawFeatures is List) {
        _features.clear();
        _features.addAll(rawFeatures.map((e) => e.toString()));
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _mapTypeToCategory(String type) {
    switch (type) {
      case 'SEDAN':
        return 'Sedan';
      case 'SUV':
        return 'SUV';
      case 'LUXURY':
        return 'Luxury';
      case 'ELECTRIC':
        return 'Electric';
      case 'SPORT':
      case 'SPORTS':
        return 'Sports';
      default:
        return 'Sedan';
    }
  }

  String _mapCategoryToType(String category) {
    switch (category) {
      case 'Sedan':
        return 'SEDAN';
      case 'SUV':
        return 'SUV';
      case 'Luxury':
        return 'LUXURY';
      case 'Electric':
        return 'ELECTRIC';
      case 'Sports':
        return 'SPORT';
      default:
        return 'SEDAN';
    }
  }

  String _mapFuelToUi(String fuel) {
    switch (fuel) {
      case 'PETROL':
        return 'Gasoline';
      case 'DIESEL':
        return 'Diesel';
      case 'ELECTRIC':
        return 'Electric';
      case 'HYBRID':
        return 'Hybrid';
      default:
        return 'Gasoline';
    }
  }

  String _mapFuelToBackend(String uiFuel) {
    switch (uiFuel) {
      case 'Gasoline':
        return 'PETROL';
      case 'Diesel':
        return 'DIESEL';
      case 'Electric':
        return 'ELECTRIC';
      case 'Hybrid':
        return 'HYBRID';
      default:
        return 'PETROL';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Car')),
        body: Center(
          child: Text(_error!, style: AppTextStyles.body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Edit Car'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 12),
              _buildBasicInfoCard(),
              const SizedBox(height: 24),

              _buildSectionTitle('Specifications'),
              const SizedBox(height: 12),
              _buildSpecificationsCard(),
              const SizedBox(height: 24),

              _buildSectionTitle('Pricing & Status'),
              const SizedBox(height: 12),
              _buildPricingCard(),
              const SizedBox(height: 24),

              _buildSectionTitle('Features'),
              const SizedBox(height: 12),
              _buildFeaturesCard(),
              const SizedBox(height: 24),

              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
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
        children: [
          TextFormField(
            controller: _brandController,
            decoration: InputDecoration(
              labelText: 'Brand',
              prefixIcon: const Icon(Icons.branding_watermark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter brand' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: 'Model',
              prefixIcon: const Icon(Icons.directions_car),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter model' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    prefixIcon: const Icon(Icons.palette),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _plateNumberController,
                  decoration: InputDecoration(
                    labelText: 'Plate Number',
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mileage (km)',
                    prefixIcon: const Icon(Icons.speed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Container(
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
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _categories
                .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTransmission,
            decoration: InputDecoration(
              labelText: 'Transmission',
              prefixIcon: const Icon(Icons.settings),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _transmissions
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedTransmission = value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFuelType,
                  decoration: InputDecoration(
                    labelText: 'Fuel Type',
                    prefixIcon: const Icon(Icons.local_gas_station),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _fuelTypes
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedFuelType = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSeats,
                  decoration: InputDecoration(
                    labelText: 'Seats',
                    prefixIcon: const Icon(Icons.airline_seat_recline_normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _seats
                      .map((seat) => DropdownMenuItem(
                          value: seat, child: Text('$seat Seats')))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSeats = value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
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
        children: [
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price per Day (\$)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter price' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: const Icon(Icons.info_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _statuses
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedStatus = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
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
            'Select Features',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableFeatures.map((feature) {
              final isSelected = _features.contains(feature);
              return FilterChip(
                label: Text(feature),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _features.add(feature);
                    } else {
                      _features.remove(feature);
                    }
                  });
                },
                backgroundColor: AppColors.softBackground,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final id = int.parse(widget.carId);
      final existing = _car ?? {};

      final totalQty = (existing['totalQuantity'] ??
              existing['availableQuantity'] ??
              1) as int;

      bool isActive;
      int availableQty;

      switch (_selectedStatus) {
        case 'Available':
          isActive = true;
          availableQty = totalQty > 0 ? totalQty : 1;
          break;
        case 'Rented':
          isActive = true;
          availableQty = 0;
          break;
        case 'Maintenance':
          isActive = false;
          availableQty =
              (existing['availableQuantity'] ?? 0) as int;
          break;
        default:
          isActive = true;
          availableQty =
              (existing['availableQuantity'] ?? 0) as int;
      }

      final carData = <String, dynamic>{
        'id': id,
        'name': '${_brandController.text} ${_modelController.text}',
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': int.tryParse(_yearController.text),
        'type': _mapCategoryToType(_selectedCategory),
        'transmission': _selectedTransmission.toUpperCase(),
        'fuel': _mapFuelToBackend(_selectedFuelType),
        'pricePerDay': double.tryParse(_priceController.text),
        'seats': int.tryParse(_selectedSeats),
        'color': _colorController.text,
        'licensePlate': _plateNumberController.text,
        'features': _features,
        'totalQuantity': totalQty,
        'availableQuantity': availableQty,
        'active': isActive,
        'isActive': isActive,
        'imageUrl': existing['imageUrl'],
        'description': existing['description'],
      };

      await CarService.instance.updateCar(id, carData);

      Navigator.pop(context, true); // 🔥 مهم: نرجع true عشان الشاشات السابقة تعيد التحميل

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Car updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update car: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
