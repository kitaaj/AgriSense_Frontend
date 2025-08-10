import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/farm_model.dart';
import '../../models/soil_analysis_model.dart';

class RecentActivityCard extends StatelessWidget {
  final List<Farm> farms;
  final List<SoilAnalysis> analyses;
  final int maxItems;

  const RecentActivityCard({
    super.key,
    required this.farms,
    required this.analyses,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final activities = _generateActivities();
    
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start by adding farms and performing soil analyses to see your activity here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
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
            // Header
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full activity history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity history coming soon')),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Activity List
            ...activities.take(maxItems).map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildActivityItem(context, activity),
            )),
          ],
        ),
      ),
    );
  }

  List<ActivityItem> _generateActivities() {
    final activities = <ActivityItem>[];
    
    // Add farm activities
    for (final farm in farms) {
      activities.add(ActivityItem(
        type: ActivityType.farmAdded,
        title: 'Farm Added',
        description: 'Added ${farm.name}',
        timestamp: farm.createdAt,
        icon: Icons.agriculture,
        color: Colors.green,
        farmId: farm.id,
      ));
    }
    
    // Add soil analysis activities
    for (final analysis in analyses) {
      final farm = farms.where((f) => f.id == analysis.farmId).firstOrNull;
      activities.add(ActivityItem(
        type: ActivityType.soilAnalysis,
        title: 'Soil Analysis',
        description: 'Analyzed ${farm?.name ?? 'Farm ${analysis.farmId}'} - ${analysis.healthScore.overallRating}',
        timestamp: analysis.analysisDate,
        icon: Icons.science,
        color: _getHealthColor(analysis.healthScore.overall),
        farmId: analysis.farmId,
        analysisId: analysis.id,
      ));
    }
    
    // Sort by timestamp (most recent first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return activities;
  }

  Color _getHealthColor(double health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.lightGreen;
    if (health >= 40) return Colors.orange;
    if (health >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to relevant screen based on activity type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to ${activity.title.toLowerCase()}')),
        );
      },
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            // Activity Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Icon(
                activity.icon,
                color: activity.color,
                size: 20,
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Activity Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatTimestamp(activity.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Chevron
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

class ActivityItem {
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final int? farmId;
  final int? analysisId;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.farmId,
    this.analysisId,
  });
}

enum ActivityType {
  farmAdded,
  farmUpdated,
  soilAnalysis,
  recommendationViewed,
  weatherAlert,
}

class ActivityTimelineCard extends StatelessWidget {
  final List<ActivityItem> activities;
  final String title;

  const ActivityTimelineCard({
    super.key,
    required this.activities,
    this.title = 'Activity Timeline',
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.timeline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
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
            
            // Timeline
            ...activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final isLast = index == activities.length - 1;
              
              return _buildTimelineItem(context, activity, isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, ActivityItem activity, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: activity.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Activity Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        activity.icon,
                        color: activity.color,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        activity.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: activity.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(activity.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

