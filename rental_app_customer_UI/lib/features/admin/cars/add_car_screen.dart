import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/car_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({Key? key}) : super(key: key);

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _mileageController = TextEditingController();

  String _selectedCategory = 'Sedan';
  String _selectedTransmission = 'Automatic';
  String _selectedFuelType = 'Gasoline';
  String _selectedSeats = '5';
  String _selectedStatus = 'Available';

  final List<String> _categories = ['Sedan', 'SUV', 'Luxury', 'Electric', 'Sports'];
  final List<String> _transmissions = ['Automatic', 'Manual'];
  final List<String> _fuelTypes = ['Gasoline', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _seats = ['2', '4', '5', '7', '8'];
  final List<String> _statuses = ['Available', 'Maintenance'];

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
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Add New Car'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 12),
              _buildBasicInfoCard(),
              const SizedBox(height: 24),

              // Specifications
              _buildSectionTitle('Specifications'),
              const SizedBox(height: 12),
              _buildSpecificationsCard(),
              const SizedBox(height: 24),

              // Pricing & Status
              _buildSectionTitle('Pricing & Status'),
              const SizedBox(height: 12),
              _buildPricingCard(),
              const SizedBox(height: 24),

              // Features
              _buildSectionTitle('Features'),
              const SizedBox(height: 12),
              _buildFeaturesCard(),
              const SizedBox(height: 24),

              // Submit Button
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
              hintText: 'e.g., Toyota',
              prefixIcon: const Icon(Icons.branding_watermark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter brand';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: 'Model',
              hintText: 'e.g., Camry',
              prefixIcon: const Icon(Icons.directions_car),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter model';
              }
              return null;
            },
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
                    hintText: '2024',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    hintText: 'White',
                    prefixIcon: const Icon(Icons.palette),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
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
                    hintText: 'ABC-1234',
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mileage (km)',
                    hintText: '15000',
                    prefixIcon: const Icon(Icons.speed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
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
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
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
            items: _transmissions.map((transmission) {
              return DropdownMenuItem(
                value: transmission,
                child: Text(transmission),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTransmission = value!;
              });
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
                  items: _fuelTypes.map((fuel) {
                    return DropdownMenuItem(
                      value: fuel,
                      child: Text(fuel),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFuelType = value!;
                    });
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
                  items: _seats.map((seat) {
                    return DropdownMenuItem(
                      value: seat,
                      child: Text('$seat Seats'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSeats = value!;
                    });
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
              hintText: '45.00',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              return null;
            },
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
            items: _statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
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
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Add Car',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Map category to backend CarType enum
        String carType;
        switch (_selectedCategory) {
          case 'SUV':
            carType = 'SUV';
            break;
          case 'Luxury':
            carType = 'LUXURY';
            break;
          case 'Electric':
            carType = 'ELECTRIC';
            break;
          case 'Sports':
            carType = 'SPORT';
            break;
          default:
            carType = 'SEDAN';
        }

        // Map fuel type to backend FuelType enum
        String fuelType;
        switch (_selectedFuelType) {
          case 'Diesel':
            fuelType = 'DIESEL';
            break;
          case 'Electric':
            fuelType = 'ELECTRIC';
            break;
          case 'Hybrid':
            fuelType = 'HYBRID';
            break;
          default:
            fuelType = 'PETROL';
        }

        final carData = {
          'name': '${_brandController.text} ${_modelController.text}',
          'brand': _brandController.text,
          'model': _modelController.text,
          'year': int.tryParse(_yearController.text) ?? 2024,
          'type': carType,
          'transmission': _selectedTransmission.toUpperCase(),
          'fuel': fuelType,
          'pricePerDay': double.tryParse(_priceController.text) ?? 0,
          'seats': int.tryParse(_selectedSeats) ?? 5,
          'color': _colorController.text,
          'licensePlate': _plateNumberController.text,
          'features': _features,
          'isActive': _selectedStatus == 'Available',
          'totalQuantity': 1,
          'availableQuantity': _selectedStatus == 'Available' ? 1 : 0,
        };

        await CarService.instance.addCar(carData);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Car added successfully'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add car: $e'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}