import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  String _selectedLanguage = 'English';

  // Business hours data
  final Map<String, Map<String, String>> _businessHours = {
    'Monday': {'open': '08:00 AM', 'close': '06:00 PM'},
    'Tuesday': {'open': '08:00 AM', 'close': '06:00 PM'},
    'Wednesday': {'open': '08:00 AM', 'close': '06:00 PM'},
    'Thursday': {'open': '08:00 AM', 'close': '06:00 PM'},
    'Friday': {'open': '08:00 AM', 'close': '06:00 PM'},
    'Saturday': {'open': '09:00 AM', 'close': '04:00 PM'},
    'Sunday': {'open': 'Closed', 'close': 'Closed'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings
            _buildSectionTitle('App Settings'),
            const SizedBox(height: 12),
            _buildAppSettings(),
            const SizedBox(height: 24),

            // Notification Settings
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildNotificationSettings(),
            const SizedBox(height: 24),

            // Security Settings
            _buildSectionTitle('Security'),
            const SizedBox(height: 12),
            _buildSecuritySettings(),
            const SizedBox(height: 24),

            // Business Settings
            _buildSectionTitle('Business Settings'),
            const SizedBox(height: 12),
            _buildBusinessSettings(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
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
      child: _buildDropdownTile(
        icon: Icons.language,
        title: 'Language',
        value: _selectedLanguage,
        items: ['English', 'العربية'],
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
          _showSnackBar('Language changed to $value');
        },
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
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
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Enable all notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.sms,
            title: 'SMS Notifications',
            subtitle: 'Receive notifications via SMS',
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
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
      child: _buildNavigationTile(
        icon: Icons.lock,
        title: 'Change Password',
        subtitle: 'Update your password',
        onTap: () => _showChangePasswordDialog(),
      ),
    );
  }

  Widget _buildBusinessSettings() {
    return Container(
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
      child: _buildNavigationTile(
        icon: Icons.schedule,
        title: 'Business Hours',
        subtitle: 'Set operating hours',
        onTap: () => _showBusinessHoursDialog(),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                _showSnackBar('Passwords do not match');
                return;
              }
              if (newPasswordController.text.length < 6) {
                _showSnackBar('Password must be at least 6 characters');
                return;
              }
              Navigator.pop(context);
              _showSnackBar('Password changed successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showBusinessHoursDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.primary),
              const SizedBox(width: 12),
              const Expanded(child: Text('Business Hours')),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _businessHours.length,
              itemBuilder: (context, index) {
                final day = _businessHours.keys.elementAt(index);
                final hours = _businessHours[day]!;
                final isClosed = hours['open'] == 'Closed';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isClosed
                        ? AppColors.error.withOpacity(0.05)
                        : AppColors.softBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          day,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          isClosed ? 'Closed' : '${hours['open']} - ${hours['close']}',
                          style: TextStyle(
                            color: isClosed ? AppColors.error : AppColors.textPrimary,
                            fontWeight: isClosed ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: AppColors.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showEditDayHoursDialog(day, hours);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDayHoursDialog(String day, Map<String, String> currentHours) {
    bool isClosed = currentHours['open'] == 'Closed';
    String openTime = isClosed ? '08:00 AM' : currentHours['open']!;
    String closeTime = isClosed ? '06:00 PM' : currentHours['close']!;

    final openTimes = _generateTimeOptions();
    final closeTimes = _generateTimeOptions();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit $day Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Closed toggle
              SwitchListTile(
                title: const Text('Closed'),
                subtitle: Text(isClosed ? 'This day is closed' : 'This day is open'),
                value: isClosed,
                onChanged: (value) {
                  setDialogState(() {
                    isClosed = value;
                  });
                },
                activeColor: AppColors.error,
              ),
              const Divider(),
              if (!isClosed) ...[
                const SizedBox(height: 8),
                // Open time
                Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Text('Open:', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: openTime,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: openTimes.map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            openTime = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Close time
                Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Text('Close:', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: closeTime,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: closeTimes.map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            closeTime = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isClosed) {
                    _businessHours[day] = {'open': 'Closed', 'close': 'Closed'};
                  } else {
                    _businessHours[day] = {'open': openTime, 'close': closeTime};
                  }
                });
                Navigator.pop(dialogContext);
                _showSnackBar('$day hours updated');
                // Re-open the business hours dialog to show updated values
                Future.delayed(const Duration(milliseconds: 100), () {
                  _showBusinessHoursDialog();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _generateTimeOptions() {
    final times = <String>[];
    for (int hour = 6; hour <= 22; hour++) {
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final ampm = hour >= 12 ? 'PM' : 'AM';
      times.add('${h.toString().padLeft(2, '0')}:00 $ampm');
      times.add('${h.toString().padLeft(2, '0')}:30 $ampm');
    }
    return times;
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(fontSize: 11),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(fontSize: 11),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
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
