import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/car_provider.dart';
import '../../core/models/car_model.dart';
import 'car_details_screen.dart';
import '../../core/widgets/main_bottom_nav.dart';

class SearchScreen extends StatefulWidget {
  final String initialCategory;

  const SearchScreen({super.key, this.initialCategory = 'All'});
  
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  String _selectedTransmission = 'All';
  String _selectedFuelType = 'All';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadCars();
  }

  Future<void> _loadCars() async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    await carProvider.loadCars();
  }

  List<CarModel> _filterCars(List<CarModel> cars) {
    return cars.where((car) {
      final matchesSearch = car.name.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      ) || car.brand.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      
      final matchesCategory = _selectedCategory == 'All' || 
          car.type.toUpperCase() == _selectedCategory.toUpperCase();
      
      final matchesTransmission = _selectedTransmission == 'All' ||
          car.transmission.toUpperCase() == _selectedTransmission.toUpperCase();
      
      final matchesFuel = _selectedFuelType == 'All' ||
          car.fuelType.toUpperCase() == _selectedFuelType.toUpperCase();

      return matchesSearch && matchesCategory && matchesTransmission && matchesFuel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.softBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: false,
                            onChanged: (value) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search for cars...',
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('All', _selectedCategory == 'All',
                            () => setState(() => _selectedCategory = 'All')),
                        _filterChip('Sedan', _selectedCategory == 'Sedan',
                            () => setState(() => _selectedCategory = 'Sedan')),
                        _filterChip('SUV', _selectedCategory == 'SUV',
                            () => setState(() => _selectedCategory = 'SUV')),
                        _filterChip('Sport', _selectedCategory == 'Sport',
                            () => setState(() => _selectedCategory = 'Sport')),
                        _filterChip('Electric', _selectedCategory == 'Electric',
                            () => setState(() => _selectedCategory = 'Electric')),
                        _filterChip('Luxury', _selectedCategory == 'Luxury',
                            () => setState(() => _selectedCategory = 'Luxury')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: Consumer<CarProvider>(
                builder: (context, carProvider, child) {
                  if (carProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (carProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(carProvider.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadCars,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredCars = _filterCars(carProvider.cars);

                  if (filteredCars.isEmpty) {
                    return _emptyState();
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filteredCars.length} cars available',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showFilterBottomSheet(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.softBackground,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.tune, size: 18, color: AppColors.primaryText),
                                    SizedBox(width: 8),
                                    Text(
                                      'Filters',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            return _carCard(filteredCars[index]);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryText : AppColors.softBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }

  Widget _carCard(CarModel car) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(car: car.toJson()),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: AppColors.softBackground,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    car.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.softBackground,
                        child: const Center(
                          child: Icon(Icons.car_rental, size: 40, color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Car Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.settings, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          car.transmission.length > 4 ? car.transmission.substring(0, 4) + '...' : car.transmission,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.local_gas_station, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          car.fuelType,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${car.pricePerDay.toInt()}/day',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No cars found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search query',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedTransmission = 'All';
                        _selectedFuelType = 'All';
                      });
                      setState(() {});
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Transmission filter
              const Text(
                'Transmission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _modalFilterChip('All', _selectedTransmission == 'All', () {
                    setModalState(() => _selectedTransmission = 'All');
                    setState(() {});
                  }),
                  _modalFilterChip('Automatic', _selectedTransmission == 'Automatic', () {
                    setModalState(() => _selectedTransmission = 'Automatic');
                    setState(() {});
                  }),
                  _modalFilterChip('Manual', _selectedTransmission == 'Manual', () {
                    setModalState(() => _selectedTransmission = 'Manual');
                    setState(() {});
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Fuel type filter
              const Text(
                'Fuel Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _modalFilterChip('All', _selectedFuelType == 'All', () {
                    setModalState(() => _selectedFuelType = 'All');
                    setState(() {});
                  }),
                  _modalFilterChip('Petrol', _selectedFuelType == 'Petrol', () {
                    setModalState(() => _selectedFuelType = 'Petrol');
                    setState(() {});
                  }),
                  _modalFilterChip('Diesel', _selectedFuelType == 'Diesel', () {
                    setModalState(() => _selectedFuelType = 'Diesel');
                    setState(() {});
                  }),
                  _modalFilterChip('Electric', _selectedFuelType == 'Electric', () {
                    setModalState(() => _selectedFuelType = 'Electric');
                    setState(() {});
                  }),
                  _modalFilterChip('Hybrid', _selectedFuelType == 'Hybrid', () {
                    setModalState(() => _selectedFuelType = 'Hybrid');
                    setState(() {});
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryText : AppColors.softBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryText : AppColors.softBackground,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primaryText,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
