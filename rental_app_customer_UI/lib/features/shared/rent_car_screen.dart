import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/car_service.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/branch_service.dart';

class RentCarScreen extends StatefulWidget {
  const RentCarScreen({super.key});

  @override
  State<RentCarScreen> createState() => _RentCarScreenState();
}

class _RentCarScreenState extends State<RentCarScreen> {
  bool _isLoading = false;
  bool _loadingCars = true;
  List<dynamic> _cars = [];
  List<dynamic> _branches = [];
  int? _selectedCarId;
  int? _selectedPickupBranchId;
  int? _selectedReturnBranchId;
  DateTime? _pickupDate;
  DateTime? _returnDate;
  TimeOfDay? _pickupTime;
  TimeOfDay? _returnTime;
  
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cvvController = TextEditingController();
  DateTime? _cardExpiryDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loadingCars = true);
    try {
      final cars = await CarService.instance.getAvailableCars();
      final branches = await BranchService.instance.getAllBranches();
      setState(() {
        _cars = cars;
        _branches = branches;
        _loadingCars = false;
      });
    } catch (e) {
      setState(() => _loadingCars = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _selectTime(bool isPickup) async {
    final initialTime = isPickup ? _pickupTime ?? TimeOfDay.now() : _returnTime ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupTime = picked;
        } else {
          _returnTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (_selectedCarId == null || 
        _selectedPickupBranchId == null || 
        _selectedReturnBranchId == null ||
        _pickupDate == null || 
        _returnDate == null ||
        _pickupTime == null ||
        _returnTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pickupDateTime = DateTime(
        _pickupDate!.year, _pickupDate!.month, _pickupDate!.day,
        _pickupTime!.hour, _pickupTime!.minute
      );
      final returnDateTime = DateTime(
        _returnDate!.year, _returnDate!.month, _returnDate!.day,
        _returnTime!.hour, _returnTime!.minute
      );

      await BookingService.instance.createBooking(
        carId: _selectedCarId!,
        pickupBranchId: _selectedPickupBranchId!,
        returnBranchId: _selectedReturnBranchId!,
        pickupDate: pickupDateTime,
        returnDate: returnDateTime,
        pickupTime: '${_pickupTime!.hour.toString().padLeft(2, '0')}:${_pickupTime!.minute.toString().padLeft(2, '0')}',
        returnTime: '${_returnTime!.hour.toString().padLeft(2, '0')}:${_returnTime!.minute.toString().padLeft(2, '0')}',
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolderName: _cardHolderController.text,
        cardExpiry: _cardExpiryDate != null 
            ? '${_cardExpiryDate!.month.toString().padLeft(2, '0')}/${_cardExpiryDate!.year % 100}'
            : '12/25',
        cardCvv: _cvvController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car rental booked successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Rent a Car'),
      ),
      body: _loadingCars
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Selection
                  _buildSectionTitle('Select Car'),
                  const SizedBox(height: 12),
                  _buildCarSelection(),
                  const SizedBox(height: 24),

                  // Date Selection
                  _buildSectionTitle('Select Dates & Times'),
                  const SizedBox(height: 12),
                  _buildDateSelection(),
                  const SizedBox(height: 12),
                  _buildTimeSelection(),
                  const SizedBox(height: 24),

                  // Branch Selection
                  _buildSectionTitle('Select Locations'),
                  const SizedBox(height: 12),
                  _buildBranchSelection(),
                  const SizedBox(height: 24),

                  // Payment
                  _buildSectionTitle('Payment Information'),
                  const SizedBox(height: 12),
                  _buildPaymentSection(),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Confirm Rental'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle,
    );
  }

  Widget _buildCarSelection() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cars.length,
        itemBuilder: (context, index) {
          final car = _cars[index];
          final isSelected = _selectedCarId == car['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCarId = car['id']),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        car['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.softBackground,
                          child: const Icon(Icons.directions_car, size: 50),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car['name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${car['pricePerDay'] ?? 0}/day',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            'Pickup Date',
            _pickupDate,
            () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _pickupDate = date);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            'Return Date',
            _returnDate,
            () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _pickupDate ?? DateTime.now(),
                firstDate: _pickupDate ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _returnDate = date);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pickup Time', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    _pickupTime != null
                        ? '${_pickupTime!.hour.toString().padLeft(2, '0')}:${_pickupTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select time',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(false),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Return Time', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    _returnTime != null
                        ? '${_returnTime!.hour.toString().padLeft(2, '0')}:${_returnTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select time',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelection() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedPickupBranchId,
          decoration: InputDecoration(
            labelText: 'Pickup Branch',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _branches.map<DropdownMenuItem<int>>((branch) {
            return DropdownMenuItem<int>(
              value: branch['id'] as int,
              child: Text(branch['name'] ?? 'Unknown'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedPickupBranchId = value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: _selectedReturnBranchId,
          decoration: InputDecoration(
            labelText: 'Return Branch',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _branches.map<DropdownMenuItem<int>>((branch) {
            return DropdownMenuItem<int>(
              value: branch['id'] as int,
              child: Text(branch['name'] ?? 'Unknown'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedReturnBranchId = value),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardHolderController,
            decoration: InputDecoration(
              labelText: 'Card Holder Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _cardExpiryDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _cardExpiryDate != null
                          ? '${_cardExpiryDate!.month}/${_cardExpiryDate!.year % 100}'
                          : 'Expiry',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
