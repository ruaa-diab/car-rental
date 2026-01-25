import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pickup_inspection_screen.dart';


class PickupNavigationScreen extends StatefulWidget {
  final int taskId;

  const PickupNavigationScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<PickupNavigationScreen> createState() => _PickupNavigationScreenState();
}

class _PickupNavigationScreenState extends State<PickupNavigationScreen> {
  late Map<String, dynamic> task;
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Load task data
    task = {
      'id': widget.taskId,
      'customer': {
        'name': 'Ahmad Khalil',
        'phone': '0599123456',
        'address': 'Al-Masyoun, Ramallah',
      },
      'vehicle': {
        'model': 'Toyota RAV4',
        'plate': 'ABC-123',
      },
      'location': {
        'lat': 31.9038,
        'lng': 35.2034,
        'distance': '2.5 km',
        'duration': '8 min',
      },
      'time': '10:00 AM',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Navigation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _makePhoneCall(task['customer']['phone']),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Placeholder
          Expanded(
            child: _buildMapPlaceholder(),
          ),

          // Bottom Card
          _buildBottomCard(),
        ],
      ),
    );
  }

  // ==================== MAP PLACEHOLDER ====================
  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          // Map Icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Map View',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${task['location']['distance']} • ${task['location']['duration']}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Current Location Button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                _showSnackBar('Centering to current location');
              },
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
            ),
          ),

          // Destination Marker
          Positioned(
            bottom: 100,
            left: MediaQuery.of(context).size.width / 2 - 20,
            child: Icon(
              Icons.location_on,
              size: 40,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM CARD ====================
  Widget _buildBottomCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Customer Info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['customer']['name'],
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task['vehicle']['model']} • ${task['vehicle']['plate']}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Call Button
              IconButton(
                onPressed: () => _makePhoneCall(task['customer']['phone']),
                icon: Icon(
                  Icons.phone,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Address
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task['customer']['address'],
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Navigate Button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _openExternalMap,
                  icon: const Icon(Icons.navigation, size: 20),
                  label: const Text(
                    'Open Maps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Arrived Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _onArrived,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Arrived',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // ==================== HELPERS ====================
  void _openExternalMap() async {
    final lat = task['location']['lat'];
    final lng = task['location']['lng'];
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Cannot open map');
    }
  }

  void _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar('Cannot make phone call');
    }
  }

  void _onArrived() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupInspectionScreen(taskId: widget.taskId),
      ),
    );
  }

  void _showSnackBar(String message) {
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