import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/soil_analysis_model.dart';

class RecommendationsSummaryCard extends StatelessWidget {
  final List<Recommendation> recommendations;
  final VoidCallback? onViewAll;

  const RecommendationsSummaryCard({
    super.key,
    required this.recommendations,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'All Good!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your soil health is excellent. No immediate recommendations needed.',
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

    final highPriority = recommendations.where((r) => r.priority == RecommendationPriority.high).toList();
    final mediumPriority = recommendations.where((r) => r.priority == RecommendationPriority.medium).toList();
    final lowPriority = recommendations.where((r) => r.priority == RecommendationPriority.low).toList();

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
                  Icons.lightbulb,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Priority Summary
            Row(
              children: [
                if (highPriority.isNotEmpty) ...[
                  Expanded(
                    child: _buildPriorityCard(
                      context,
                      'High Priority',
                      highPriority.length,
                      Colors.red,
                      Icons.priority_high,
                    ),
                  ),
                  if (mediumPriority.isNotEmpty || lowPriority.isNotEmpty)
                    const SizedBox(width: AppSpacing.md),
                ],
                if (mediumPriority.isNotEmpty) ...[
                  Expanded(
                    child: _buildPriorityCard(
                      context,
                      'Medium Priority',
                      mediumPriority.length,
                      Colors.orange,
                      Icons.warning,
                    ),
                  ),
                  if (lowPriority.isNotEmpty)
                    const SizedBox(width: AppSpacing.md),
                ],
                if (lowPriority.isNotEmpty)
                  Expanded(
                    child: _buildPriorityCard(
                      context,
                      'Low Priority',
                      lowPriority.length,
                      Colors.blue,
                      Icons.info,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Top Recommendations Preview
            if (highPriority.isNotEmpty) ...[
              Text(
                'Urgent Actions Needed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...highPriority.take(2).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildRecommendationPreview(context, rec),
              )),
              if (highPriority.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    '+${highPriority.length - 2} more high priority recommendations',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ] else if (mediumPriority.isNotEmpty) ...[
              Text(
                'Recommended Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...mediumPriority.take(2).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildRecommendationPreview(context, rec),
              )),
              if (mediumPriority.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    '+${mediumPriority.length - 2} more recommendations',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ] else if (lowPriority.isNotEmpty) ...[
              Text(
                'Optional Improvements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...lowPriority.take(2).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildRecommendationPreview(context, rec),
              )),
              if (lowPriority.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    '+${lowPriority.length - 2} more suggestions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],

            // Total Summary
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.summarize,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Total: ${recommendations.length} recommendation${recommendations.length != 1 ? 's' : ''} across all farms',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
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

  Widget _buildPriorityCard(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
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
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPreview(BuildContext context, Recommendation recommendation) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: priorityColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(
              _getTypeIcon(recommendation.type),
              color: priorityColor,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  recommendation.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: priorityColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.low:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.fertilizer:
        return Icons.scatter_plot;
      case RecommendationType.liming:
        return Icons.science;
      case RecommendationType.organic:
        return Icons.eco;
      case RecommendationType.irrigation:
        return Icons.water_drop;
      case RecommendationType.cultivation:
        return Icons.agriculture;
      case RecommendationType.crop:
        return Icons.grass;
    }
  }
}

class RecommendationCategoryCard extends StatelessWidget {
  final String title;
  final List<Recommendation> recommendations;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const RecommendationCategoryCard({
    super.key,
    required this.title,
    required this.recommendations,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${recommendations.length} recommendation${recommendations.length != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                
                // Preview of top recommendations
                ...recommendations.take(2).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          rec.title,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
                
                if (recommendations.length > 2)
                  Text(
                    '+${recommendations.length - 2} more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

