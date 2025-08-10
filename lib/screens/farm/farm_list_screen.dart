import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/farm_model.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/farm/farm_card.dart';
import 'add_farm_screen.dart';
import 'farm_detail_screen.dart';

class FarmListScreen extends StatefulWidget {
  static const String routeName = '/farms';

  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCropType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmProvider>(context, listen: false).loadFarms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddFarm() {
    Navigator.of(context).pushNamed(AddFarmScreen.routeName);
  }

  void _navigateToFarmDetail(Farm farm) {
    Navigator.of(context).pushNamed(
      FarmDetailScreen.routeName,
      arguments: farm,
    );
  }

  List<Farm> _getFilteredFarms(List<Farm> farms) {
    List<Farm> filtered = farms;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = farms.where((farm) {
        return farm.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (farm.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (farm.cropType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply crop type filter
    if (_selectedCropType != null && _selectedCropType!.isNotEmpty) {
      filtered = filtered.where((farm) => farm.cropType == _selectedCropType).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farms'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<FarmProvider>(context, listen: false).refresh();
            },
          ),
        ],
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          return LoadingOverlay(
            isLoading: farmProvider.isLoading,
            child: Column(
              children: [
                // Search and Filter Section
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
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search farms...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Crop Type Filter
                        if (farmProvider.uniqueCropTypes.isNotEmpty)
                          DropdownButtonFormField<String>(
                            value: _selectedCropType,
                            decoration: InputDecoration(
                              labelText: 'Filter by Crop Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Crop Types'),
                              ),
                              ...farmProvider.uniqueCropTypes.map((cropType) {
                                return DropdownMenuItem<String>(
                                  value: cropType,
                                  child: Text(cropType),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCropType = value;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: _buildContent(farmProvider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFarm,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(FarmProvider farmProvider) {
    if (farmProvider.state == FarmState.error) {
      return _buildErrorState(farmProvider);
    }

    if (!farmProvider.hasFarms && farmProvider.state == FarmState.loaded) {
      return _buildEmptyState();
    }

    final filteredFarms = _getFilteredFarms(farmProvider.farms);

    if (filteredFarms.isEmpty && farmProvider.hasFarms) {
      return _buildNoResultsState();
    }

    return _buildFarmsList(filteredFarms, farmProvider);
  }

  Widget _buildErrorState(FarmProvider farmProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load farms',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              farmProvider.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'Try Again',
              onPressed: () => farmProvider.refresh(),
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Farms Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first farm to start analyzing soil health and getting recommendations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'Add Your First Farm',
              onPressed: _navigateToAddFarm,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Results Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting your search or filter criteria.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'Clear Filters',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCropType = null;
                });
              },
              type: ButtonType.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmsList(List<Farm> farms, FarmProvider farmProvider) {
    return RefreshIndicator(
      onRefresh: () => farmProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: farms.length + 1, // +1 for summary card
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(farmProvider);
          }
          
          final farm = farms[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: FarmCard(
              farm: farm,
              onTap: () => _navigateToFarmDetail(farm),
              onEdit: () {
                Navigator.of(context).pushNamed(
                  AddFarmScreen.routeName,
                  arguments: farm,
                );
              },
              onDelete: () => _showDeleteConfirmation(farm, farmProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(FarmProvider farmProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Farms',
                    farmProvider.farms.length.toString(),
                    Icons.agriculture,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Area',
                    '${farmProvider.totalFarmArea.toStringAsFixed(1)} ha',
                    Icons.landscape,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Farm farm, FarmProvider farmProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm'),
        content: Text('Are you sure you want to delete "${farm.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await farmProvider.deleteFarm(farm.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppConstants.farmDeletedMessage),
                    backgroundColor: Colors.green,
                  ),
                );
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
}

