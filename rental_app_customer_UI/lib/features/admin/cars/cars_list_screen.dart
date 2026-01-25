import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/car_service.dart';
import 'car_details_screen.dart';
import 'add_car_screen.dart';

class CarsListScreen extends StatefulWidget {
  const CarsListScreen({Key? key}) : super(key: key);

  @override
  State<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _cars = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cars = await CarService.instance.getAllCars();
      setState(() {
        _cars = cars.map((c) => c as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCars {
    return _cars.where((car) {
      final brand = car['brand']?.toString() ?? '';
      final model = car['model']?.toString() ?? '';
      final name = car['name']?.toString() ?? '';
      final plateNumber = car['plateNumber']?.toString() ?? '';
      final status = car['status']?.toString().toUpperCase() ?? 'AVAILABLE';

      final matchesSearch = brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plateNumber.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          status == _selectedFilter.toUpperCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildSearchAndFilter(),
                    _buildStatsBar(),
                    Expanded(
                      child: _filteredCars.isEmpty
                          ? _buildEmptyState()
                          : _buildCarsGrid(),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCarScreen()),
          );
          if (result == true) {
            _loadCars();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Car',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error loading cars', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(_error ?? '', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCars,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Manage Cars'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadCars,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            _showFilterDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search cars...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.softBackground,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Available'),
                _buildFilterChip('Rented'),
                _buildFilterChip('Maintenance'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: AppColors.softBackground,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalCars = _cars.length;
    final availableCars = _cars.where((c) =>
        (c['status']?.toString().toUpperCase() ?? 'AVAILABLE') == 'AVAILABLE').length;
    final rentedCars = _cars.where((c) =>
        (c['status']?.toString().toUpperCase() ?? '') == 'RENTED').length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalCars.toString(), AppColors.primary),
          _buildStatItem('Available', availableCars.toString(), AppColors.success),
          _buildStatItem('Rented', rentedCars.toString(), AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildCarsGrid() {
    return RefreshIndicator(
      onRefresh: _loadCars,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _filteredCars.length,
        itemBuilder: (context, index) {
          final car = _filteredCars[index];
          return _buildCarCard(car);
        },
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    final status = car['status']?.toString().toUpperCase() ?? 'AVAILABLE';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'AVAILABLE':
        statusColor = AppColors.success;
        statusText = 'Available';
        break;
      case 'RENTED':
        statusColor = AppColors.warning;
        statusText = 'Rented';
        break;
      case 'MAINTENANCE':
        statusColor = AppColors.error;
        statusText = 'Maintenance';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    final brand = car['brand']?.toString() ?? '';
    final model = car['model']?.toString() ?? '';
    final name = car['name']?.toString() ?? '$brand $model';
    final year = car['year']?.toString() ?? '';
    final plateNumber = car['plateNumber']?.toString() ?? '';
    final pricePerDay = car['pricePerDay']?.toString() ?? '0';
    final imageUrl = car['imageUrl']?.toString();
    final images = car['additionalImages'] as List?;
    final firstImage = images?.isNotEmpty == true ? images!.first : imageUrl;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailsScreen(carId: car['id']?.toString() ?? ''),
          ),
        );
        if (result == true) {
          _loadCars();
        }
      },
      child: Container(
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
            // Car Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: firstImage != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        firstImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.directions_car, size: 50, color: Colors.grey),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.directions_car, size: 50, color: Colors.grey),
                    ),
            ),

            // Car Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$year ${plateNumber.isNotEmpty ? '• $plateNumber' : ''}',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '\$$pricePerDay/day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No cars found',
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Cars'),
              onTap: () {
                setState(() => _selectedFilter = 'All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Available'),
              onTap: () {
                setState(() => _selectedFilter = 'Available');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Rented'),
              onTap: () {
                setState(() => _selectedFilter = 'Rented');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Maintenance'),
              onTap: () {
                setState(() => _selectedFilter = 'Maintenance');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
