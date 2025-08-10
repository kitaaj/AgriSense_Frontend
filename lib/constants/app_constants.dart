// App Constants for AgriSense Mobile Application

class AppConstants {
  // App Information
  static const String appName = 'AgriSense';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Farming Solutions for Sub-Saharan Africa';
  
  // API Configuration
  static const String baseUrl = 'http://192.168.150.166:5000/api'; // Android emulator localhost
  static const String baseUrlIOS = 'http://localhost:5000/api'; // iOS simulator localhost
  static const String baseUrlProduction = 'https://api.agrisense.com/api';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String selectedLanguageKey = 'selected_language';
  static const String themeKey = 'theme_mode';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String currentUserEndpoint = '/auth/me';
  static const String farmsEndpoint = '/farms';
  static const String soilAnalysisEndpoint = '/soil-analysis';
  static const String dashboardEndpoint = '/dashboard';
  static const String profileEndpoint = '/profile';
  static const String statisticsEndpoint = '/statistics';
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxFarmNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Geographic Constants
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;
  
  // Sub-Saharan Africa bounds for location validation
  static const double subSaharanMinLatitude = -35.0;
  static const double subSaharanMaxLatitude = 15.0;
  static const double subSaharanMinLongitude = -20.0;
  static const double subSaharanMaxLongitude = 55.0;
  
  // Soil Health Score Ranges
  static const double excellentSoilScore = 80.0;
  static const double goodSoilScore = 60.0;
  static const double fairSoilScore = 40.0;
  
  // Recommendation Priority Levels
  static const int criticalPriority = 1;
  static const int highPriority = 2;
  static const int mediumPriority = 3;
  static const int lowPriority = 4;
  static const int optionalPriority = 5;
  
  // Animation Durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  
  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
  
  // Cache Duration (in hours)
  static const int shortCacheDuration = 1;
  static const int mediumCacheDuration = 6;
  static const int longCacheDuration = 24;
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const double imageQuality = 0.8;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'en', // English
    'sw', // Swahili
    'fr', // French
    'pt', // Portuguese
    'ar', // Arabic
  ];
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultCropType = 'Mixed Crops';
  static const double defaultFarmArea = 1.0;
  static const String defaultSoilDepth = '0-20';
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String authenticationErrorMessage = 'Authentication failed. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String locationErrorMessage = 'Unable to get your location. Please enable location services.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registrationSuccessMessage = 'Registration successful!';
  static const String farmCreatedMessage = 'Farm created successfully!';
  static const String farmUpdatedMessage = 'Farm updated successfully!';
  static const String farmDeletedMessage = 'Farm deleted successfully!';
  static const String analysisCompletedMessage = 'Soil analysis completed!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableLocationTracking = true;
  static const bool enableBiometricAuth = true;
  
  // Map Configuration
  static const double defaultZoom = 15.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 20.0;
  
  // Chart Configuration
  static const int maxChartDataPoints = 50;
  static const double chartAnimationDuration = 1.0;
  
  // Refresh Intervals (in seconds)
  static const int dashboardRefreshInterval = 300; // 5 minutes
  static const int farmDataRefreshInterval = 600; // 10 minutes
  static const int weatherRefreshInterval = 1800; // 30 minutes
}

// Crop Types commonly grown in Sub-Saharan Africa
class CropTypes {
  static const List<String> commonCrops = [
    'Maize (Corn)',
    'Rice',
    'Wheat',
    'Sorghum',
    'Millet',
    'Cassava',
    'Sweet Potato',
    'Yam',
    'Plantain',
    'Banana',
    'Beans',
    'Cowpeas',
    'Groundnuts (Peanuts)',
    'Soybeans',
    'Cotton',
    'Coffee',
    'Cocoa',
    'Tea',
    'Sugarcane',
    'Oil Palm',
    'Sesame',
    'Sunflower',
    'Mixed Crops',
    'Other',
  ];
}

// Soil Property Units
class SoilUnits {
  static const String phUnit = 'pH';
  static const String carbonUnit = '%';
  static const String nitrogenUnit = '%';
  static const String phosphorusUnit = 'mg/kg';
  static const String potassiumUnit = 'mg/kg';
  static const String areaUnit = 'hectares';
}

// App Colors (Material Design 3 compatible)
class AppColors {
  // Primary Colors (Earth tones for agricultural theme)
  static const int primaryGreen = 0xFF2E7D32; // Forest Green
  static const int primaryBrown = 0xFF5D4037; // Brown
  static const int primaryBlue = 0xFF1976D2; // Sky Blue
  
  // Secondary Colors
  static const int secondaryGreen = 0xFF4CAF50;
  static const int secondaryBrown = 0xFF8D6E63;
  static const int secondaryBlue = 0xFF42A5F5;
  
  // Status Colors
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFF9800;
  static const int errorColor = 0xFFF44336;
  static const int infoColor = 0xFF2196F3;
  
  // Soil Health Colors
  static const int excellentSoil = 0xFF4CAF50; // Green
  static const int goodSoil = 0xFF8BC34A; // Light Green
  static const int fairSoil = 0xFFFF9800; // Orange
  static const int poorSoil = 0xFFF44336; // Red
  
  // Priority Colors
  static const int criticalPriorityColor = 0xFFF44336; // Red
  static const int highPriorityColor = 0xFFFF9800; // Orange
  static const int mediumPriorityColor = 0xFFFFEB3B; // Yellow
  static const int lowPriorityColor = 0xFF2196F3; // Blue
  static const int optionalPriorityColor = 0xFF9E9E9E; // Grey
}

// App Text Styles
class AppTextStyles {
  static const String fontFamily = 'Roboto';
  
  // Font Sizes
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
}

// App Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// App Border Radius
class AppBorderRadius {
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double circular = 50.0;
}

