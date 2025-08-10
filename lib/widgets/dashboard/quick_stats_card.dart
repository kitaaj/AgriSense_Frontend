import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class QuickStatsCard extends StatelessWidget {
  final int farmCount;
  final double totalArea;
  final int analysisCount;
  final double averageHealth;

  const QuickStatsCard({
    super.key,
    required this.farmCount,
    required this.totalArea,
    required this.analysisCount,
    required this.averageHealth,
  });

  String _formatArea(double area) {
    if (area >= 1000) {
      return '${(area / 1000).toStringAsFixed(1)}k ha';
    } else if (area >= 100) {
      return '${area.toStringAsFixed(0)} ha';
    } else {
      return '${area.toStringAsFixed(1)} ha';
    }
  }

  Color _getHealthColor(double health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.lightGreen;
    if (health >= 40) return Colors.orange;
    if (health >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  String _getHealthRating(double health) {
    if (health >= 80) return 'Excellent';
    if (health >= 60) return 'Good';
    if (health >= 40) return 'Fair';
    if (health >= 20) return 'Poor';
    return 'Very Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Quick Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.agriculture,
                    farmCount.toString(),
                    'Farm${farmCount != 1 ? 's' : ''}',
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.landscape,
                    _formatArea(totalArea),
                    'Total Area',
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.science,
                    analysisCount.toString(),
                    'Analyses',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.health_and_safety,
                    analysisCount > 0 ? '${averageHealth.toStringAsFixed(0)}%' : 'N/A',
                    analysisCount > 0 ? _getHealthRating(averageHealth) : 'No Data',
                    analysisCount > 0 ? _getHealthColor(averageHealth) : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DetailedStatsCard extends StatelessWidget {
  final Map<String, dynamic> farmStats;
  final Map<String, dynamic> soilStats;
  final Map<String, dynamic> recommendationStats;

  const DetailedStatsCard({
    super.key,
    required this.farmStats,
    required this.soilStats,
    required this.recommendationStats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Farm Statistics
            _buildStatsSection(
              context,
              'Farm Statistics',
              Icons.agriculture,
              Theme.of(context).primaryColor,
              [
                _StatItem('Total Farms', farmStats['totalFarms']?.toString() ?? '0'),
                _StatItem('Total Area', '${farmStats['totalArea']?.toStringAsFixed(1) ?? '0'} ha'),
                _StatItem('Average Farm Size', '${farmStats['averageSize']?.toStringAsFixed(1) ?? '0'} ha'),
                _StatItem('Active Farms', farmStats['activeFarms']?.toString() ?? '0'),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Soil Health Statistics
            _buildStatsSection(
              context,
              'Soil Health Statistics',
              Icons.health_and_safety,
              Colors.green,
              [
                _StatItem('Total Analyses', soilStats['totalAnalyses']?.toString() ?? '0'),
                _StatItem('Average Health', '${soilStats['averageHealth']?.toStringAsFixed(1) ?? '0'}%'),
                _StatItem('Excellent Soils', soilStats['excellentCount']?.toString() ?? '0'),
                _StatItem('Poor Soils', soilStats['poorCount']?.toString() ?? '0'),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Recommendation Statistics
            _buildStatsSection(
              context,
              'Recommendations',
              Icons.lightbulb,
              Colors.orange,
              [
                _StatItem('Total Recommendations', recommendationStats['totalRecommendations']?.toString() ?? '0'),
                _StatItem('High Priority', recommendationStats['highPriorityCount']?.toString() ?? '0'),
                _StatItem('Medium Priority', recommendationStats['mediumPriorityCount']?.toString() ?? '0'),
                _StatItem('Low Priority', recommendationStats['lowPriorityCount']?.toString() ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<_StatItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);
}

class ProgressStatsCard extends StatelessWidget {
  final String title;
  final List<ProgressStat> stats;
  final Color primaryColor;

  const ProgressStatsCard({
    super.key,
    required this.title,
    required this.stats,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            ...stats.map((stat) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildProgressItem(context, stat),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, ProgressStat stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${stat.current}/${stat.total}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        LinearProgressIndicator(
          value: stat.total > 0 ? stat.current / stat.total : 0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
        
        const SizedBox(height: AppSpacing.xs),
        
        Text(
          '${((stat.total > 0 ? stat.current / stat.total : 0) * 100).toStringAsFixed(1)}% complete',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class ProgressStat {
  final String label;
  final int current;
  final int total;

  const ProgressStat({
    required this.label,
    required this.current,
    required this.total,
  });
}

