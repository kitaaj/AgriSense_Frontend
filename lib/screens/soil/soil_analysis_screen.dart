import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/farm_model.dart';
import '../../models/soil_analysis_model.dart';
import '../../providers/soil_analysis_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/soil/soil_health_gauge.dart';
import '../../widgets/soil/soil_property_card.dart';
import '../../widgets/soil/recommendation_card.dart';

class SoilAnalysisScreen extends StatefulWidget {
  static const String routeName = '/soil-analysis';

  const SoilAnalysisScreen({super.key});

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  Farm? _farm;
  SoilAnalysis? _analysis;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _farm = args['farm'] as Farm?;
      _analysis = args['analysis'] as SoilAnalysis?;
    }
  }

  Future<void> _performAnalysis() async {
    if (_farm == null) return;

    final soilProvider = Provider.of<SoilAnalysisProvider>(context, listen: false);
    
    final success = await soilProvider.performSoilAnalysis(
      farmId: _farm!.id,
      latitude: _farm!.latitude,
      longitude: _farm!.longitude,
    );

    if (success && mounted) {
      setState(() {
        _analysis = soilProvider.currentAnalysis;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soil analysis completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(soilProvider.errorMessage ?? 'Failed to perform soil analysis'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_farm?.name ?? 'Soil Analysis'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
        ],
      ),
      body: Consumer<SoilAnalysisProvider>(
        builder: (context, soilProvider, child) {
          return LoadingOverlay(
            isLoading: soilProvider.isAnalyzing,
            message: 'Analyzing soil properties...',
            child: _analysis != null ? _buildAnalysisResults() : _buildAnalysisPrompt(),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisPrompt() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.science,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Soil Analysis',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Get detailed insights about your soil health and receive personalized recommendations.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Farm Information
          if (_farm != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow(Icons.agriculture, 'Farm Name', _farm!.name),
                    _buildInfoRow(Icons.location_on, 'Location', _farm!.formattedCoordinates),
                    if (_farm!.area != null)
                      _buildInfoRow(Icons.landscape, 'Area', _farm!.formattedArea),
                    if (_farm!.cropType != null)
                      _buildInfoRow(Icons.eco, 'Crop Type', _farm!.cropType!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          
          // What You'll Get
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What You\'ll Get',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildFeatureItem(
                    Icons.health_and_safety,
                    'Soil Health Score',
                    'Overall assessment of your soil condition',
                  ),
                  _buildFeatureItem(
                    Icons.science,
                    'Nutrient Analysis',
                    'Detailed breakdown of soil nutrients and pH levels',
                  ),
                  _buildFeatureItem(
                    Icons.lightbulb,
                    'Recommendations',
                    'Personalized advice to improve soil health',
                  ),
                  _buildFeatureItem(
                    Icons.trending_up,
                    'Improvement Plan',
                    'Step-by-step guide to optimize your soil',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Start Analysis Button
          CustomButton(
            text: 'Start Soil Analysis',
            onPressed: _farm != null ? _performAnalysis : null,
            icon: Icons.play_arrow,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Info Note
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Analysis uses satellite data and machine learning to provide accurate soil insights.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysis == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section with Soil Health Score
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
                  Text(
                    'Soil Health Analysis',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Analysis completed ${_analysis!.formattedDate}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Soil Health Gauge
                  SoilHealthGauge(
                    score: _analysis!.healthScore.overall,
                    rating: _analysis!.healthScore.overallRating,
                  ),
                ],
              ),
            ),
          ),
          
          // Soil Properties Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soil Properties',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Primary Properties
                Row(
                  children: [
                    Expanded(
                      child: SoilPropertyCard(
                        title: 'pH Level',
                        value: _analysis!.properties.ph.toStringAsFixed(1),
                        status: _analysis!.properties.phStatus,
                        icon: Icons.science,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SoilPropertyCard(
                        title: 'Organic Carbon',
                        value: '${_analysis!.properties.organicCarbon.toStringAsFixed(1)}%',
                        status: _analysis!.properties.organicCarbonStatus,
                        icon: Icons.eco,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Nutrients
                Row(
                  children: [
                    Expanded(
                      child: SoilPropertyCard(
                        title: 'Nitrogen',
                        value: '${_analysis!.properties.nitrogen.toStringAsFixed(2)}%',
                        status: _analysis!.properties.nitrogenStatus,
                        icon: Icons.grass,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SoilPropertyCard(
                        title: 'Phosphorus',
                        value: '${_analysis!.properties.phosphorus.toStringAsFixed(0)} ppm',
                        status: _analysis!.properties.phosphorusStatus,
                        icon: Icons.local_florist,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    Expanded(
                      child: SoilPropertyCard(
                        title: 'Potassium',
                        value: '${_analysis!.properties.potassium.toStringAsFixed(0)} ppm',
                        status: _analysis!.properties.potassiumStatus,
                        icon: Icons.energy_savings_leaf,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SoilPropertyCard(
                        title: 'Texture',
                        value: _analysis!.properties.textureClass,
                        status: SoilPropertyStatus.optimal, // Texture doesn't have status
                        icon: Icons.texture,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Recommendations Section
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                if (_analysis!.recommendations.isEmpty)
                  Card(
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
                            'Excellent Soil Health!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Your soil is in excellent condition. Continue with your current practices.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...(_analysis!.recommendations.map((recommendation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: RecommendationCard(recommendation: recommendation),
                    );
                  })),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'New Analysis',
                        onPressed: _performAnalysis,
                        type: ButtonType.outline,
                        icon: Icons.refresh,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomButton(
                        text: 'View History',
                        onPressed: () {
                          // TODO: Navigate to analysis history
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('History feature coming soon')),
                          );
                        },
                        icon: Icons.history,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
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

