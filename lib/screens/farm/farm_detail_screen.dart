import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/farm_model.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'add_farm_screen.dart';

class FarmDetailScreen extends StatefulWidget {
  static const String routeName = '/farm-detail';

  const FarmDetailScreen({super.key});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  Farm? _farm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Farm) {
      _farm = args;
    }
  }

  void _navigateToEdit() {
    if (_farm != null) {
      Navigator.of(context).pushNamed(
        AddFarmScreen.routeName,
        arguments: _farm,
      );
    }
  }

  void _showDeleteConfirmation() {
    if (_farm == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: Text('Are you sure you want to delete "${_farm!.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final farmProvider = Provider.of<FarmProvider>(context, listen: false);
              final success = await farmProvider.deleteFarm(_farm!.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppConstants.farmDeletedMessage),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(); // Go back to farm list
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(farmProvider.errorMessage ?? 'Failed to delete farm'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_farm == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Farm Details'),
        ),
        body: const Center(
          child: Text('Farm not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_farm!.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Farm', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              color: Theme.of(context).primaryColor,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.lg),
                    topRight: Radius.circular(AppBorderRadius.lg),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Farm Icon and Name
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      child: Icon(
                        Icons.agriculture,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _farm!.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_farm!.description != null && _farm!.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _farm!.description!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Farm Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Information Card
                  _buildInfoCard(
                    'Basic Information',
                    [
                      _buildInfoRow(Icons.location_on, 'Location', _farm!.formattedCoordinates),
                      if (_farm!.area != null)
                        _buildInfoRow(Icons.landscape, 'Area', _farm!.formattedArea),
                      if (_farm!.cropType != null)
                        _buildInfoRow(Icons.eco, 'Crop Type', _farm!.cropType!),
                      _buildInfoRow(Icons.calendar_today, 'Created', 
                          DateFormat('MMMM dd, yyyy').format(_farm!.createdAt)),
                      _buildInfoRow(Icons.update, 'Last Updated', 
                          DateFormat('MMMM dd, yyyy').format(_farm!.updatedAt)),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Coordinates Card
                  _buildInfoCard(
                    'Precise Coordinates',
                    [
                      _buildInfoRow(Icons.my_location, 'Latitude', _farm!.latitude.toStringAsFixed(6)),
                      _buildInfoRow(Icons.my_location, 'Longitude', _farm!.longitude.toStringAsFixed(6)),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Analyze Soil',
                          'Get soil health insights',
                          Icons.science,
                          Colors.green,
                          () {
                            // TODO: Navigate to soil analysis
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Soil analysis feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildActionCard(
                          'View Reports',
                          'See analysis history',
                          Icons.assessment,
                          Colors.blue,
                          () {
                            // TODO: Navigate to reports
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reports feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Recommendations',
                          'Get farming advice',
                          Icons.lightbulb,
                          Colors.orange,
                          () {
                            // TODO: Navigate to recommendations
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recommendations feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildActionCard(
                          'Edit Farm',
                          'Update farm details',
                          Icons.edit,
                          Colors.purple,
                          _navigateToEdit,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Delete Button
                  CustomButton(
                    text: 'Delete Farm',
                    onPressed: _showDeleteConfirmation,
                    type: ButtonType.danger,
                    icon: Icons.delete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

