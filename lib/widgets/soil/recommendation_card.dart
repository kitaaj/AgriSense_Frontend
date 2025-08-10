import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/soil_analysis_model.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onTap;
  final bool showDetails;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
    this.showDetails = true,
  });

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

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Type Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Icon(
                      _getTypeIcon(recommendation.type),
                      color: priorityColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  
                  // Title and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          recommendation.typeText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(
                        color: priorityColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      recommendation.priorityText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Description
              Text(
                recommendation.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                maxLines: showDetails ? null : 3,
                overflow: showDetails ? null : TextOverflow.ellipsis,
              ),
              
              if (showDetails) ...[
                // Action Steps
                if (recommendation.actionSteps != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: Colors.blue[700],
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Action Steps',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          recommendation.actionSteps!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Expected Outcome
                if (recommendation.expectedOutcome != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green[700],
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Expected Outcome',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          recommendation.expectedOutcome!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Timeframe and Cost
                if (recommendation.timeframeText != null || recommendation.costText != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      if (recommendation.timeframeText != null) ...[
                        Expanded(
                          child: _buildInfoChip(
                            Icons.schedule,
                            'Timeframe',
                            recommendation.timeframeText!,
                            Colors.purple,
                          ),
                        ),
                        if (recommendation.costText != null)
                          const SizedBox(width: AppSpacing.md),
                      ],
                      if (recommendation.costText != null)
                        Expanded(
                          child: _buildInfoChip(
                            Icons.attach_money,
                            'Est. Cost',
                            recommendation.costText!,
                            Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
              
              // Tap indicator for non-detailed view
              if (!showDetails && onTap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tap for details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right,
                      color: priorityColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationListTile extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationListTile({
    super.key,
    required this.recommendation,
    this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(recommendation.priority);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: priorityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Icon(
          _getTypeIcon(recommendation.type),
          color: priorityColor,
          size: 20,
        ),
      ),
      title: Text(
        recommendation.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                ),
                child: Text(
                  recommendation.priorityText,
                  style: TextStyle(
                    fontSize: 10,
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                recommendation.typeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      isThreeLine: true,
    );
  }
}

class RecommendationSummaryCard extends StatelessWidget {
  final List<Recommendation> recommendations;
  final VoidCallback? onViewAll;

  const RecommendationSummaryCard({
    super.key,
    required this.recommendations,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final highPriority = recommendations.where((r) => r.priority == RecommendationPriority.high).length;
    final mediumPriority = recommendations.where((r) => r.priority == RecommendationPriority.medium).length;
    final lowPriority = recommendations.where((r) => r.priority == RecommendationPriority.low).length;
    
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
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Recommendations Summary',
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
            
            if (recommendations.isEmpty)
              Text(
                'No recommendations needed. Your soil is in excellent condition!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green[600],
                ),
              )
            else ...[
              Row(
                children: [
                  if (highPriority > 0) ...[
                    Expanded(
                      child: _buildPriorityCount(
                        context,
                        'High Priority',
                        highPriority,
                        Colors.red,
                      ),
                    ),
                    if (mediumPriority > 0 || lowPriority > 0)
                      const SizedBox(width: AppSpacing.md),
                  ],
                  if (mediumPriority > 0) ...[
                    Expanded(
                      child: _buildPriorityCount(
                        context,
                        'Medium Priority',
                        mediumPriority,
                        Colors.orange,
                      ),
                    ),
                    if (lowPriority > 0)
                      const SizedBox(width: AppSpacing.md),
                  ],
                  if (lowPriority > 0)
                    Expanded(
                      child: _buildPriorityCount(
                        context,
                        'Low Priority',
                        lowPriority,
                        Colors.blue,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Text(
                'Total: ${recommendations.length} recommendation${recommendations.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCount(BuildContext context, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
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
}

