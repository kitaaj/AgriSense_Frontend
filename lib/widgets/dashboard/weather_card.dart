import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class WeatherCard extends StatelessWidget {
  final String location;
  final int temperature;
  final String condition;
  final int humidity;
  final int windSpeed;

  const WeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'partly cloudy':
      case 'partly sunny':
        return Icons.wb_cloudy;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.grain;
      case 'stormy':
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'partly cloudy':
      case 'partly sunny':
        return Colors.blue;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.indigo;
      case 'stormy':
      case 'thunderstorm':
        return Colors.purple;
      case 'snowy':
      case 'snow':
        return Colors.lightBlue;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherColor = _getWeatherColor(condition);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              weatherColor.withOpacity(0.1),
              weatherColor.withOpacity(0.05),
            ],
          ),
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
                    Icons.location_on,
                    color: weatherColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      location,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: weatherColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.refresh,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Main Weather Info
              Row(
                children: [
                  // Weather Icon and Temperature
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: weatherColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          ),
                          child: Icon(
                            _getWeatherIcon(condition),
                            color: weatherColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$temperature°',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: weatherColor,
                              ),
                            ),
                            Text(
                              condition,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Weather Details
                  Expanded(
                    child: Column(
                      children: [
                        _buildWeatherDetail(
                          Icons.water_drop,
                          'Humidity',
                          '$humidity%',
                          Colors.blue,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildWeatherDetail(
                          Icons.air,
                          'Wind',
                          '$windSpeed km/h',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Weather Insights
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  border: Border.all(color: weatherColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: weatherColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _getWeatherInsight(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: weatherColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getWeatherInsight() {
    if (condition.toLowerCase().contains('rain')) {
      return 'Good conditions for soil moisture. Consider delaying fertilizer application.';
    } else if (condition.toLowerCase().contains('sunny')) {
      return 'Perfect weather for field work and soil analysis.';
    } else if (humidity > 80) {
      return 'High humidity may affect crop disease risk. Monitor closely.';
    } else if (windSpeed > 20) {
      return 'Strong winds detected. Avoid spraying operations today.';
    } else {
      return 'Good conditions for most farming activities.';
    }
  }
}

class WeatherForecastCard extends StatelessWidget {
  final List<WeatherForecast> forecast;

  const WeatherForecastCard({
    super.key,
    required this.forecast,
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
              '7-Day Forecast',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            ...forecast.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildForecastItem(context, day),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(BuildContext context, WeatherForecast day) {
    return Row(
      children: [
        // Day
        SizedBox(
          width: 60,
          child: Text(
            day.dayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Weather Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(
            _getWeatherIcon(day.condition),
            color: Colors.blue,
            size: 16,
          ),
        ),
        
        const SizedBox(width: AppSpacing.md),
        
        // Condition
        Expanded(
          child: Text(
            day.condition,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        
        // Temperature Range
        Text(
          '${day.highTemp}°/${day.lowTemp}°',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(width: AppSpacing.sm),
        
        // Rain Chance
        if (day.rainChance > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.xs),
            ),
            child: Text(
              '${day.rainChance}%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'partly cloudy':
      case 'partly sunny':
        return Icons.wb_cloudy;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.grain;
      case 'stormy':
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }
}

class WeatherForecast {
  final String dayName;
  final String condition;
  final int highTemp;
  final int lowTemp;
  final int rainChance;

  const WeatherForecast({
    required this.dayName,
    required this.condition,
    required this.highTemp,
    required this.lowTemp,
    required this.rainChance,
  });
}

