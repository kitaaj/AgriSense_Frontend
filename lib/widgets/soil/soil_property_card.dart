import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/soil_analysis_model.dart';

class SoilPropertyCard extends StatelessWidget {
  final String title;
  final String value;
  final SoilPropertyStatus status;
  final IconData icon;
  final String? unit;
  final String? description;

  const SoilPropertyCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    this.unit,
    this.description,
  });

  Color _getStatusColor(SoilPropertyStatus status) {
    switch (status) {
      case SoilPropertyStatus.low:
        return Colors.orange;
      case SoilPropertyStatus.optimal:
        return Colors.green;
      case SoilPropertyStatus.high:
        return Colors.blue;
    }
  }

  String _getStatusText(SoilPropertyStatus status) {
    switch (status) {
      case SoilPropertyStatus.low:
        return 'Low';
      case SoilPropertyStatus.optimal:
        return 'Optimal';
      case SoilPropertyStatus.high:
        return 'High';
    }
  }

  IconData _getStatusIcon(SoilPropertyStatus status) {
    switch (status) {
      case SoilPropertyStatus.low:
        return Icons.trending_down;
      case SoilPropertyStatus.optimal:
        return Icons.check_circle;
      case SoilPropertyStatus.high:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Status Indicator
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _getStatusText(status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            // Description
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SoilPropertyDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final SoilPropertyStatus status;
  final IconData icon;
  final String? unit;
  final String description;
  final String? recommendation;
  final List<String>? ranges;

  const SoilPropertyDetailCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    this.unit,
    required this.description,
    this.recommendation,
    this.ranges,
  });

  Color _getStatusColor(SoilPropertyStatus status) {
    switch (status) {
      case SoilPropertyStatus.low:
        return Colors.orange;
      case SoilPropertyStatus.optimal:
        return Colors.green;
      case SoilPropertyStatus.high:
        return Colors.blue;
    }
  }

  String _getStatusText(SoilPropertyStatus status) {
    switch (status) {
      case SoilPropertyStatus.low:
        return 'Below Optimal';
      case SoilPropertyStatus.optimal:
        return 'Optimal Range';
      case SoilPropertyStatus.high:
        return 'Above Optimal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStatusText(status),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        if (unit != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              unit!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Description
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            
            // Ranges
            if (ranges != null && ranges!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reference Ranges',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...ranges!.map((range) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            range,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            // Recommendation
            if (recommendation != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommendation',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            recommendation!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SoilPropertyListTile extends StatelessWidget {
  final String title;
  final String value;
  final SoilPropertyStatus status;
  final IconData icon;
  final VoidCallback? onTap;

  const SoilPropertyListTile({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.icon,
    this.onTap,
  });

  Color _getStatusColor(SoilPropertyStatus status) {
    switch (status) {
      case SoilPropertyStatus.low:
        return Colors.orange;
      case SoilPropertyStatus.optimal:
        return Colors.green;
      case SoilPropertyStatus.high:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Icon(
          icon,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}

