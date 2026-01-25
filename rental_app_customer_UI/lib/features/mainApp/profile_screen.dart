import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../core/providers/providers.dart';
import '../../features/booking/view_all_booking_screen.dart';
import '../../features/auth/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, bool> notificationStatus = {
    'Booking Updates': true,
    'Promotions & Offers': true,
    'New Cars Available': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with profile info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile picture
                        GestureDetector(
                          onTap: () => _showImagePickerDialog(context),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.softBackground,
                                ),
                                child: user?.profileImage != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user!.profileImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          user?.fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          user?.email ?? 'email@example.com',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        // Stats row
                        Consumer<BookingProvider>(
                          builder: (context, bookingProvider, child) {
                            final totalBookings =
                                bookingProvider.bookings.length;
                            final completed = bookingProvider.bookings
                                .where((b) => b.status == 'COMPLETED')
                                .length;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _statItem('$totalBookings', 'Bookings'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: AppColors.softBackground),
                                _statItem('$completed', 'Completed'),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: AppColors.softBackground),
                                _statItem('4.9', 'Rating'),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 12),
                          child: Text('Account',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText)),
                        ),
                        _menuCard(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => _showEditProfileDialog(context),
                        ),
                        const SizedBox(height: 12),
                        _menuCard(
                          context: context,
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const SizedBox(height: 12),
                        _menuCard(
                          context: context,
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: () => _showNotificationsDialog(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // More Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 12),
                          child: Text('More',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText)),
                        ),
                        _menuCard(
                          context: context,
                          icon: Icons.history,
                          title: 'Booking History',
                          subtitle: 'View your past rentals',
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ViewAllBookingsScreen()));
                          },
                        ),
                        const SizedBox(height: 12),
                        _menuCard(
                          context: context,
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get assistance',
                          onTap: () => _showHelpSupportDialog(context),
                        ),
                        const SizedBox(height: 12),
                        _menuCard(
                          context: context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy terms',
                          onTap: () => _showPrivacyPolicyDialog(context),
                        ),
                        const SizedBox(height: 12),
                        _menuCard(
                          context: context,
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and info',
                          onTap: () => _showAboutDialog(context),
                        ),
                        const SizedBox(height: 12),
                        _menuCard(
                          context: context,
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          onTap: () => _showLogoutDialog(context),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 4),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText)),
        const SizedBox(height: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isDestructive ? Colors.red : AppColors.primary,
                  size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red
                              : AppColors.primaryText)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textSecondary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageOption(
                    Icons.camera_alt, 'Camera', () => Navigator.pop(context)),
                _imageOption(Icons.photo_library, 'Gallery',
                    () => Navigator.pop(context)),
                _imageOption(
                    Icons.delete, 'Remove', () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _imageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.softBackground,
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final nameController = TextEditingController(text: user?.fullName);
    final phoneController = TextEditingController(text: user?.phone);
    final formKey = GlobalKey<FormState>();

    String? validatePhone(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your phone number';
      }
      if (value.length != 13) {
        return 'Phone must be exactly 13 characters';
      }
      if (!value.startsWith('+970') && !value.startsWith('+972')) {
        return 'Phone must start with +970 or +972';
      }
      if (!RegExp(r'^\+97[02]\d{9}$').hasMatch(value)) {
        return 'Invalid phone number format';
      }
      return null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                maxLength: 13,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+970599123456',
                ),
                validator: validatePhone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await authProvider.updateProfile(
                  fullName: nameController.text, phone: phoneController.text);
              Navigator.pop(context);
              _showSnackBar(context, 'Profile updated successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: currentController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 16),
            TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 16),
            TextField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (newController.text != confirmController.text) {
                _showSnackBar(context, 'Passwords do not match');
                return;
              }
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.changePassword(
                  currentController.text, newController.text);
              Navigator.pop(context);
              _showSnackBar(
                  context,
                  success
                      ? 'Password changed successfully'
                      : 'Failed to change password');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Change', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Notification Settings',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: notificationStatus.keys.map((key) {
              return SwitchListTile(
                title: Text(key),
                value: notificationStatus[key]!,
                onChanged: (value) =>
                    setState(() => notificationStatus[key] = value),
                activeColor: AppColors.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _supportOption(
                  Icons.email, 'Email Support', 'support@autora.com'),
              const SizedBox(height: 16),
              _supportOption(Icons.phone, 'Phone Support', '+1 (555) 123-4567'),
              const SizedBox(height: 16),
              _supportOption(Icons.chat, 'Live Chat', 'Available 24/7'),
              const SizedBox(height: 16),
              // FAQ Option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.help_outline, color: AppColors.primary),
                title: const Text('FAQ'),
                subtitle: const Text('Common questions'),
                onTap: () {
                  Navigator.pop(context);
                  _showFAQDialog(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _faqItem(
                question: 'How do I book a car?',
                answer:
                    'Browse available cars, select your preferred vehicle, choose pickup/return dates, and complete the booking with your payment method.',
              ),
              const SizedBox(height: 16),
              _faqItem(
                question: 'What documents do I need?',
                answer:
                    'You need a valid driver\'s license, national ID or passport, and a credit card in your name for the security deposit.',
              ),
              const SizedBox(height: 16),
              _faqItem(
                question: 'Can I cancel my booking?',
                answer:
                    'Yes, you can cancel up to 24 hours before pickup for a full refund. Cancellations within 24 hours may incur a fee.',
              ),
              const SizedBox(height: 16),
              _faqItem(
                question: 'What is included in the rental?',
                answer:
                    'All rentals include basic insurance, unlimited mileage, and 24/7 roadside assistance.',
              ),
              const SizedBox(height: 16),
              _faqItem(
                question: 'How do I extend my rental?',
                answer:
                    'Contact us via phone or email at least 24 hours before your return date to extend your rental period.',
              ),
              const SizedBox(height: 16),
              _faqItem(
                question: 'What happens if the car breaks down?',
                answer:
                    'Call our 24/7 roadside assistance immediately. We\'ll arrange repairs or provide a replacement vehicle at no extra cost.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _supportOption(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last updated: January 10, 2026\n\n'
                '1. Information We Collect\n'
                'We collect information you provide directly to us, including name, email, phone number, and payment details.\n\n'
                '2. How We Use Your Information\n'
                'We use your information to provide and improve our services, process bookings, and communicate with you.\n\n'
                '3. Data Security\n'
                'We implement security measures to protect your personal information from unauthorized access.\n\n'
                '4. Your Rights\n'
                'You have the right to access, update, or delete your personal information at any time.\n\n'
                '5. Contact Us\n'
                'For privacy concerns, contact us at privacy@rentalapp.com',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About Autora',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20)),
              child:
                  const Icon(Icons.car_rental, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Autora',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Version 1.0.0',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('Your trusted car rental partner.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
          backgroundColor: AppColors.primary),
    );
  }
}
