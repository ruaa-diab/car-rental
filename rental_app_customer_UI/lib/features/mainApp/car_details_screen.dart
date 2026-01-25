import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/favorite_provider.dart';
import '../../features/booking/booking_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  final ScrollController _scrollController = ScrollController();
  double _imageOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _imageOpacity = 1.0 - (_scrollController.offset / 300).clamp(0.0, 0.7);
      });
    });
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final carId = widget.car['id'];
    if (carId != null) {
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
      final isFav = await favoriteProvider.checkIsFavorite(carId);
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final carId = widget.car['id'];
    if (carId == null) return;

    setState(() => _isLoadingFavorite = true);

    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final success = await favoriteProvider.toggleFavorite(carId);

    if (mounted) {
      setState(() {
        _isLoadingFavorite = false;
        if (success) {
          _isFavorite = !_isFavorite;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _carImageUrl {
    return widget.car['imageUrl'] ?? widget.car['image'] ?? '';
  }

  bool get _isNetworkImage {
    return _carImageUrl.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: Stack(
        children: [
          // Fixed background image with parallax effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: _imageOpacity,
              child: Container(
                height: 350,
                decoration: const BoxDecoration(color: AppColors.cardWhite),
                child: _isNetworkImage
                    ? Image.network(
                        _carImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.softBackground,
                            child: const Center(
                              child: Icon(Icons.car_rental, size: 80, color: AppColors.textSecondary),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        _carImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.softBackground,
                            child: const Center(
                              child: Icon(Icons.car_rental, size: 80, color: AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Transparent app bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: _isLoadingFavorite ? null : _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: _isLoadingFavorite
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : AppColors.primaryText,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),

              // Spacer for image
              const SliverToBoxAdapter(child: SizedBox(height: 250)),

              // Content container
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car name and rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.car['name'] ?? 'Car',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 18, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.car['rating'] ?? 4.5}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Category/Type
                        Text(
                          widget.car['type'] ?? widget.car['category'] ?? 'Luxury',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),

                        // Specs row
                        Row(
                          children: [
                            Expanded(
                              child: _specCard(
                                icon: Icons.settings,
                                label: 'Transmission',
                                value: widget.car['transmission'] ?? 'Automatic',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _specCard(
                                icon: Icons.local_gas_station,
                                label: 'Fuel',
                                value: widget.car['fuelType'] ?? widget.car['fuel'] ?? 'Petrol',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _specCard(
                                icon: Icons.airline_seat_recline_normal,
                                label: 'Seats',
                                value: '${widget.car['seats'] ?? 5}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Features
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _buildFeatureChips(),
                        ),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          widget.car['description'] ??
                              'The ${widget.car['name']} is a luxury vehicle that combines powerful performance with sophisticated comfort. Perfect for both city driving and long journeys.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom booking bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(widget.car['pricePerDay'] ?? widget.car['price'] ?? 0).toInt()}/day',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingScreen(preSelectedCar: widget.car),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureChips() {
    final features = widget.car['features'];
    if (features != null && features is List) {
      return features.map<Widget>((feature) => _featureChip(feature.toString())).toList();
    }
    // Default features if none provided
    return [
      _featureChip('GPS Navigation'),
      _featureChip('Bluetooth'),
      _featureChip('Air Conditioning'),
      _featureChip('Parking Sensors'),
      _featureChip('Backup Camera'),
      _featureChip('Cruise Control'),
    ];
  }

  Widget _specCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softBackground, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            feature,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
