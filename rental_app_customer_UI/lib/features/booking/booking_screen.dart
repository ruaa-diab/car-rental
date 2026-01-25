import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../mainApp/home.dart';

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic>? preSelectedCar;
  const BookingScreen({super.key, this.preSelectedCar});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _searchController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cvvController = TextEditingController();
  
  // Booking data
  int? selectedCarId;
  String? selectedCarName;
  double? selectedCarPrice;
  String? selectedCarImage;
  String? selectedCarType;
  DateTime? pickupDate;
  DateTime? returnDate;
  TimeOfDay? pickupTime;
  TimeOfDay? returnTime;
  int? pickupBranchId;
  int? returnBranchId;
  String? pickupBranchName;
  String? returnBranchName;
  DateTime? cardExpiryDate;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.preSelectedCar != null) {
      selectedCarId = widget.preSelectedCar!['id'];
      selectedCarName = widget.preSelectedCar!['name'];
      selectedCarPrice = (widget.preSelectedCar!['pricePerDay'] ?? widget.preSelectedCar!['price'] ?? 0).toDouble();
      selectedCarImage = widget.preSelectedCar!['imageUrl'] ?? widget.preSelectedCar!['image'];
      selectedCarType = widget.preSelectedCar!['type'] ?? 'Luxury';
      _currentStep = 1;
    }
  }

  Future<void> _loadData() async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final branchProvider = Provider.of<BranchProvider>(context, listen: false);
    await Future.wait([
      carProvider.loadCars(),
      branchProvider.loadBranches(),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  int get totalDays {
    if (pickupDate == null || returnDate == null) return 1;
    return returnDate!.difference(pickupDate!).inDays + 1;
  }

  double get totalPrice => (selectedCarPrice ?? 0) * totalDays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
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
        title: const Text(
          'Book Your Ride',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(child: _buildCurrentStep()),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomButtons(),
          const MainBottomNav(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildStep(0, 'Car', Icons.directions_car),
          _buildStepLine(0),
          _buildStep(1, 'Date', Icons.calendar_today),
          _buildStepLine(1),
          _buildStep(2, 'Location', Icons.location_on),
          _buildStepLine(2),
          _buildStep(3, 'Payment', Icons.payment),
          _buildStepLine(3),
          _buildStep(4, 'Review', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 3) : null,
          ),
          child: Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primary : Colors.grey, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
      ],
    );
  }

  Widget _buildStepLine(int beforeStep) {
    final isActive = _currentStep > beforeStep;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildCarSelection();
      case 1: return _buildDateSelection();
      case 2: return _buildLocationSelection();
      case 3: return _buildPayment();
      case 4: return _buildReview();
      default: return const SizedBox();
    }
  }

  Widget _buildCarSelection() {
    return Consumer<CarProvider>(
      builder: (context, carProvider, child) {
        if (carProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final cars = carProvider.cars.where((car) {
          return car.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search cars...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ...cars.map((car) => _buildCarCard(car)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarCard(CarModel car) {
    final isSelected = selectedCarId == car.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCarId = car.id;
          selectedCarName = car.name;
          selectedCarPrice = car.pricePerDay;
          selectedCarImage = car.imageUrl;
          selectedCarType = car.type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(car.imageUrl, width: 100, height: 70, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 100, height: 70, color: AppColors.softBackground, child: const Icon(Icons.car_rental))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(car.type, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('\$${car.pricePerDay.toInt()}/day', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pickup Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateField('Date', pickupDate, (date) => setState(() => pickupDate = date))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeField('Time', pickupTime, (time) => setState(() => pickupTime = time))),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Return Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateField('Date', returnDate, (date) => setState(() => returnDate = date))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeField('Time', returnTime, (time) => setState(() => returnTime = time))),
            ],
          ),
          if (pickupDate != null && returnDate != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Days:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('$totalDays days', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, Function(DateTime) onSelect) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(value != null ? '${value.day}/${value.month}/${value.year}' : label, style: TextStyle(color: value != null ? AppColors.primaryText : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? value, Function(TimeOfDay) onSelect) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: value ?? TimeOfDay.now());
        if (time != null) onSelect(time);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(value != null ? value.format(context) : label, style: TextStyle(color: value != null ? AppColors.primaryText : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelection() {
    return Consumer<BranchProvider>(
      builder: (context, branchProvider, child) {
        if (branchProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pickup Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...branchProvider.branches.map((branch) => _buildBranchCard(branch, true)),
              const SizedBox(height: 24),
              const Text('Return Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...branchProvider.branches.map((branch) => _buildBranchCard(branch, false)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchCard(BranchModel branch, bool isPickup) {
    final isSelected = isPickup ? pickupBranchId == branch.id : returnBranchId == branch.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPickup) {
            pickupBranchId = branch.id;
            pickupBranchName = branch.name;
          } else {
            returnBranchId = branch.id;
            returnBranchName = branch.name;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.location_on, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(branch.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(branch.address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPayment() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Card Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: _inputDecoration('Card Number', Icons.credit_card),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), _CardNumberInputFormatter()],
              validator: (v) => v!.replaceAll(' ', '').length < 16 ? 'Enter valid card number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardHolderController,
              decoration: _inputDecoration('Card Holder Name', Icons.person),
              validator: (v) => v!.isEmpty ? 'Enter card holder name' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectCardExpiryDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(cardExpiryDate != null ? '${cardExpiryDate!.month.toString().padLeft(2, '0')}/${cardExpiryDate!.year % 100}' : 'MM/YY',
                              style: TextStyle(color: cardExpiryDate != null ? AppColors.primaryText : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: _inputDecoration('CVV', Icons.lock),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                    validator: (v) => v!.length < 3 ? 'Enter CVV' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('\$${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReviewCard('Car', [
            _reviewRow('Vehicle', selectedCarName ?? '-'),
            _reviewRow('Type', selectedCarType ?? '-'),
            _reviewRow('Price/Day', '\$${selectedCarPrice?.toStringAsFixed(0) ?? 0}'),
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('Schedule', [
            _reviewRow('Pickup', '${pickupDate?.day}/${pickupDate?.month}/${pickupDate?.year} at ${pickupTime?.format(context) ?? '-'}'),
            _reviewRow('Return', '${returnDate?.day}/${returnDate?.month}/${returnDate?.year} at ${returnTime?.format(context) ?? '-'}'),
            _reviewRow('Duration', '$totalDays days'),
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('Location', [
            _reviewRow('Pickup', pickupBranchName ?? '-'),
            _reviewRow('Return', returnBranchName ?? '-'),
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('Payment', [
            _reviewRow('Card', '**** **** **** ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}'),
            _reviewRow('Total', '\$${totalPrice.toStringAsFixed(2)}'),
          ]),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_currentStep == 4 ? _confirmBooking : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_currentStep == 4 ? 'Confirm Booking' : 'Continue', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && selectedCarId == null) {
      _showError('Please select a car');
      return;
    }
    if (_currentStep == 1 && (pickupDate == null || returnDate == null || pickupTime == null || returnTime == null)) {
      _showError('Please select dates and times');
      return;
    }
    if (_currentStep == 1 && returnDate!.isBefore(pickupDate!)) {
      _showError('Return date must be after pickup date');
      return;
    }
    if (_currentStep == 2 && (pickupBranchId == null || returnBranchId == null)) {
      _showError('Please select pickup and return locations');
      return;
    }
    if (_currentStep == 3) {
      if (!_formKey.currentState!.validate() || cardExpiryDate == null) {
        _showError('Please fill all payment details');
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }

  Future<void> _selectCardExpiryDate() async {
    final now = DateTime.now();
    int selectedMonth = cardExpiryDate?.month ?? now.month;
    int selectedYear = cardExpiryDate?.year ?? now.year;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Expiry Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () { if (selectedYear > now.year) setState(() => selectedYear--); }),
                  Text('$selectedYear', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { if (selectedYear < now.year + 20) setState(() => selectedYear++); }),
                ],
              ),
              Wrap(
                children: List.generate(12, (i) {
                  final month = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => selectedMonth = month),
                    child: Container(
                      width: 60, height: 40,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: selectedMonth == month ? AppColors.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][i], style: TextStyle(color: selectedMonth == month ? Colors.white : Colors.black))),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, DateTime(selectedYear, selectedMonth)), child: const Text('OK')),
          ],
        ),
      ),
    );
    if (result != null) setState(() => cardExpiryDate = result);
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      final pickupDateTime = DateTime(pickupDate!.year, pickupDate!.month, pickupDate!.day, pickupTime!.hour, pickupTime!.minute);
      final returnDateTime = DateTime(returnDate!.year, returnDate!.month, returnDate!.day, returnTime!.hour, returnTime!.minute);

      final booking = await bookingProvider.createBooking(
        carId: selectedCarId!,
        pickupBranchId: pickupBranchId!,
        returnBranchId: returnBranchId!,
        pickupDate: pickupDateTime,
        returnDate: returnDateTime,
        pickupTime: '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')}',
        returnTime: '${returnTime!.hour.toString().padLeft(2, '0')}:${returnTime!.minute.toString().padLeft(2, '0')}',
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolderName: _cardHolderController.text,
        cardExpiry: '${cardExpiryDate!.month.toString().padLeft(2, '0')}/${cardExpiryDate!.year % 100}',
        cardCvv: _cvvController.text,
      );

      if (booking != null && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showError(bookingProvider.error ?? 'Booking failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            const Text('Booking Confirmed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Your booking has been successfully confirmed.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}