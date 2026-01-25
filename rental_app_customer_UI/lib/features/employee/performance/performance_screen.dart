import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/employee_bottom_nav.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/report_service.dart';
import '../../../core/services/employee_service.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Time'];
  bool _isLoading = true;

  Map<String, dynamic> performanceData = {
    'totalTasks': 0,
    'completed': 0,
    'inProgress': 0,
    'cancelled': 0,
    'rating': 0.0,
    'totalReviews': 0,
    'onTimeRate': 0,
    'customerSatisfaction': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        // Get employee data by user ID
        final employeeData = await EmployeeService.instance.getEmployeeByUserId(userId);
        final employeeId = employeeData['id'];

        // Get performance data
        final performance = await ReportService.instance.getEmployeePerformance(employeeId);

        if (mounted) {
          setState(() {
            performanceData = {
              'totalTasks': (performance['completedTasks'] ?? 0) +
                  (performance['pendingTasks'] ?? 0) +
                  (performance['inProgressTasks'] ?? 0),
              'completed': performance['completedTasks'] ?? performance['tasksCompleted'] ?? 0,
              'inProgress': performance['inProgressTasks'] ?? 0,
              'cancelled': 0,
              'rating': performance['rating'] ?? 0.0,
              'totalReviews': performance['totalRatings'] ?? 0,
              'onTimeRate': 92, // Not tracked in backend yet
              'customerSatisfaction': ((performance['rating'] ?? 0) * 20).round(),
            };
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),

                    // Stats Overview
                    _buildSectionTitle('Overview'),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                    const SizedBox(height: 20),

                    // Rating Card
                    _buildSectionTitle('Rating & Reviews'),
                    const SizedBox(height: 12),
                    _buildRatingCard(),
                    const SizedBox(height: 20),

                    // Performance Metrics
                    _buildSectionTitle('Performance Metrics'),
                    const SizedBox(height: 12),
                    _buildMetricsCard(),
                    const SizedBox(height: 20),

                    // Achievements
                    _buildSectionTitle('Achievements'),
                    const SizedBox(height: 12),
                    _buildAchievementsCard(),
                    const SizedBox(height: 20),

                    // Recent Reviews
                    _buildSectionTitle('Recent Reviews'),
                    const SizedBox(height: 12),
                    _buildRecentReviews(),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 2),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Performance'),
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download_outlined),
          onPressed: () {
            _showSnackBar('Download report');
          },
          tooltip: 'Download Report',
        ),
      ],
    );
  }

  // ==================== PERIOD SELECTOR ====================
  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = period == _selectedPeriod;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== STATS GRID ====================
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          title: 'Total Tasks',
          value: performanceData['totalTasks'].toString(),
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
          trend: '+12%',
          isPositive: true,
        ),
        _buildStatCard(
          title: 'Completed',
          value: performanceData['completed'].toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          trend: '+8%',
          isPositive: true,
        ),
        _buildStatCard(
          title: 'In Progress',
          value: performanceData['inProgress'].toString(),
          icon: Icons.autorenew,
          color: AppColors.info,
        ),
        _buildStatCard(
          title: 'Cancelled',
          value: performanceData['cancelled'].toString(),
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          trend: '-3%',
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool? isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ?? true)
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (isPositive ?? true)
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: (isPositive ?? true)
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: (isPositive ?? true)
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== RATING CARD ====================
  Widget _buildRatingCard() {
    final rating = performanceData['rating'];
    final reviews = performanceData['totalReviews'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rating Display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        '/5.0',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.floor()
                          ? Icons.star
                          : index < rating
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.white,
                      size: 24,
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Based on $reviews reviews',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== METRICS CARD ====================
  Widget _buildMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMetricRow(
            title: 'On-Time Completion',
            value: performanceData['onTimeRate'],
            icon: Icons.access_time,
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _buildMetricRow(
            title: 'Customer Satisfaction',
            value: performanceData['customerSatisfaction'],
            icon: Icons.sentiment_satisfied_alt,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ==================== ACHIEVEMENTS CARD ====================
  Widget _buildAchievementsCard() {
    final achievements = [
      {
        'title': '10 Tasks Completed',
        'description': 'Complete 10 tasks',
        'icon': Icons.emoji_events,
        'color': AppColors.warning,
        'unlocked': true,
      },
      {
        'title': '5 Star Rating',
        'description': 'Maintain 5.0 rating',
        'icon': Icons.star,
        'color': AppColors.warning,
        'unlocked': true,
      },
      {
        'title': 'Fast Worker',
        'description': 'Complete 5 tasks in one day',
        'icon': Icons.bolt,
        'color': AppColors.info,
        'unlocked': true,
      },
      {
        'title': 'Customer Favorite',
        'description': 'Get 10 five-star reviews',
        'icon': Icons.favorite,
        'color': AppColors.error,
        'unlocked': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: achievements.asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          final isLast = index == achievements.length - 1;

          return Column(
            children: [
              _buildAchievementItem(
                title: achievement['title'] as String,
                description: achievement['description'] as String,
                icon: achievement['icon'] as IconData,
                color: achievement['color'] as Color,
                unlocked: achievement['unlocked'] as bool,
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool unlocked,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: unlocked ? color.withOpacity(0.1) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: unlocked ? color : Colors.grey[400],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? AppColors.textPrimary : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: unlocked ? AppColors.textSecondary : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        if (unlocked)
          Icon(
            Icons.check_circle,
            color: color,
            size: 24,
          )
        else
          Icon(
            Icons.lock_outline,
            color: Colors.grey[400],
            size: 24,
          ),
      ],
    );
  }

  // ==================== RECENT REVIEWS ====================
  Widget _buildRecentReviews() {
    final reviews = [
      {
        'customer': 'Ahmad Khalil',
        'rating': 5.0,
        'comment': 'Excellent service! Very professional and on time.',
        'date': '2 hours ago',
      },
      {
        'customer': 'Sara Ali',
        'rating': 4.5,
        'comment': 'Good experience, car was clean and in great condition.',
        'date': '1 day ago',
      },
      {
        'customer': 'Mohammed Hassan',
        'rating': 5.0,
        'comment': 'Fast and efficient. Highly recommend!',
        'date': '2 days ago',
      },
    ];

    return Column(
      children: reviews.map((review) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      review['customer'].toString()[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['customer'] as String,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          review['date'] as String,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.ratingStar,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ratingStar,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review['comment'] as String,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==================== HELPERS ====================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
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