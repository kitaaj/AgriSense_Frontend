import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/farm_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farm_provider.dart';
import '../../providers/soil_analysis_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/dashboard/weather_card.dart';
import '../../widgets/dashboard/quick_stats_card.dart';
import '../../widgets/dashboard/recent_activity_card.dart';
import '../../widgets/dashboard/recommendations_summary_card.dart';
import '../../widgets/soil/soil_health_gauge.dart';
import '../farm/add_farm_screen.dart';
import '../farm/farm_detail_screen.dart';
import '../soil/soil_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final soilProvider = Provider.of<SoilAnalysisProvider>(context, listen: false);
    
    await Future.wait([
      farmProvider.loadFarms(),
      soilProvider.loadAnalyses(),
    ]);
  }

  Future<void> _refreshDashboard() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final soilProvider = Provider.of<SoilAnalysisProvider>(context, listen: false);
    
    await Future.wait([
      farmProvider.refresh(),
      soilProvider.refresh(),
    ]);
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

  void _navigateToSoilAnalysis(Farm farm) {
    Navigator.of(context).pushNamed(
      SoilAnalysisScreen.routeName,
      arguments: {'farm': farm},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriSense'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      // TODO: Navigate to profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile feature coming soon')),
                      );
                      break;
                    case 'settings':
                      // TODO: Navigate to settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings feature coming soon')),
                      );
                      break;
                    case 'logout':
                      authProvider.logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: Consumer3<AuthProvider, FarmProvider, SoilAnalysisProvider>(
          builder: (context, authProvider, farmProvider, soilProvider, child) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Message
                          Text(
                            'Welcome back${authProvider.user?.fullName != null ? ', ${authProvider.user!.fullName}' : ''}!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Here\'s what\'s happening with your farms today.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Quick Stats
                          QuickStatsCard(
                            farmCount: farmProvider.farms.length,
                            totalArea: farmProvider.totalFarmArea,
                            analysisCount: soilProvider.analyses.length,
                            averageHealth: soilProvider.getSoilHealthStatistics()['averageHealth'] ?? 0.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weather Card
                        const WeatherCard(
                          location: 'Kiboko, Kenya', // TODO: Get from user location
                          temperature: 26,
                          condition: 'Partly Cloudy',
                          humidity: 65,
                          windSpeed: 12,
                        ),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Farms Section
                        _buildSectionHeader(
                          'Your Farms',
                          farmProvider.farms.length,
                          () {
                            Navigator.of(context).pushNamed('/farms');
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        if (farmProvider.farms.isEmpty)
                          _buildEmptyFarmsCard()
                        else
                          _buildFarmsGrid(farmProvider.farms),
                        
                        const SizedBox(height: AppSpacing.lg),
                        
                        // Recent Soil Analyses
                        if (soilProvider.analyses.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Recent Soil Health',
                            soilProvider.getRecentAnalyses().length,
                            () {
                              // TODO: Navigate to soil analysis history
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Analysis history coming soon')),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildSoilHealthOverview(soilProvider),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        
                        // Recommendations Summary
                        if (soilProvider.analyses.isNotEmpty) ...[
                          RecommendationsSummaryCard(
                            recommendations: soilProvider.analyses
                                .expand((analysis) => analysis.recommendations)
                                .toList(),
                            onViewAll: () {
                              // TODO: Navigate to recommendations
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recommendations view coming soon')),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        
                        // Recent Activity
                        RecentActivityCard(
                          farms: farmProvider.farms,
                          analyses: soilProvider.getRecentAnalyses(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFarm,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, VoidCallback? onViewAll) {
    return Row(
      children: [
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
              if (count > 0)
                Text(
                  '$count item${count != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        if (onViewAll != null && count > 0)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildEmptyFarmsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Farms Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first farm to start monitoring soil health and getting recommendations.',
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

  Widget _buildFarmsGrid(List<Farm> farms) {
    final displayFarms = farms.take(4).toList(); // Show max 4 farms on dashboard
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemCount: displayFarms.length,
      itemBuilder: (context, index) {
        final farm = displayFarms[index];
        return _buildFarmGridItem(farm);
      },
    );
  }

  Widget _buildFarmGridItem(Farm farm) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: InkWell(
        onTap: () => _navigateToFarmDetail(farm),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farm Icon and Actions
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'analyze':
                          _navigateToSoilAnalysis(farm);
                          break;
                        case 'view':
                          _navigateToFarmDetail(farm);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'analyze',
                        child: Row(
                          children: [
                            Icon(Icons.science, size: 16),
                            SizedBox(width: 8),
                            Text('Analyze Soil'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Farm Name
              Text(
                farm.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // Farm Details
              if (farm.area != null)
                Text(
                  farm.formattedArea,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              
              if (farm.cropType != null)
                Text(
                  farm.cropType!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              
              const Spacer(),
              
              // Quick Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToSoilAnalysis(farm),
                  icon: const Icon(Icons.science, size: 16),
                  label: const Text('Analyze'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoilHealthOverview(SoilAnalysisProvider soilProvider) {
    final recentAnalyses = soilProvider.getRecentAnalyses().take(3).toList();
    
    if (recentAnalyses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.science_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Recent Soil Analyses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Start analyzing your soil to get health insights and recommendations.',
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Health Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Health Gauges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: recentAnalyses.map((analysis) {
                final farm = Provider.of<FarmProvider>(context, listen: false)
                    .getFarmById(analysis.farmId);
                return SoilHealthMiniGauge(
                  score: analysis.healthScore.overall,
                  label: farm?.name ?? 'Farm ${analysis.farmId}',
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Average Health
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Soil Health',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '${soilProvider.getSoilHealthStatistics()['averageHealth'].toStringAsFixed(1)}% - Good',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
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
}

