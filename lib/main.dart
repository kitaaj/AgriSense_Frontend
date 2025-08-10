import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/soil_analysis_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/farm/farm_list_screen.dart';
import 'screens/farm/add_farm_screen.dart';
import 'screens/farm/farm_detail_screen.dart';
import 'screens/soil/soil_analysis_screen.dart';
import 'services/api_service.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await ApiService().initialize();
  
  // Set up logging
  AppLogger.setMinLevel(LogLevel.debug);
  
  runApp(const AgriSenseApp());
}

class AgriSenseApp extends StatelessWidget {
  const AgriSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => SoilAnalysisProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: MaterialColor(
            AppColors.primaryGreen,
            <int, Color>{
              50: Color(AppColors.primaryGreen).withValues(alpha:0.1),
              100: Color(AppColors.primaryGreen).withValues(alpha:0.2),
              200: Color(AppColors.primaryGreen).withValues(alpha:0.3),
              300: Color(AppColors.primaryGreen).withValues(alpha:0.4),
              400: Color(AppColors.primaryGreen).withValues(alpha:0.5),
              500: Color(AppColors.primaryGreen),
              600: Color(AppColors.primaryGreen).withValues(alpha:0.7),
              700: Color(AppColors.primaryGreen).withValues(alpha:0.8),
              800: Color(AppColors.primaryGreen).withValues(alpha:0.9),
              900: Color(AppColors.primaryGreen).withValues(alpha:1.0),
            },
          ),
          primaryColor: Color(AppColors.primaryGreen),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(AppColors.primaryGreen),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: AppTextStyles.fontFamily,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(AppColors.primaryGreen),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: AppTextStyles.titleLarge,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryGreen),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(AppColors.primaryGreen),
              side: BorderSide(color: Color(AppColors.primaryGreen)),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(AppColors.primaryGreen),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              borderSide: BorderSide(color: Color(AppColors.primaryGreen), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(AppColors.primaryGreen),
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthGate(),
        routes: {
          // AuthGate handles them.
          // LoginScreen.routeName: (context) => const LoginScreen(),
          // DashboardScreen.routeName: (context) => const DashboardScreen(),
          RegisterScreen.routeName: (context) => const RegisterScreen(),
          FarmListScreen.routeName: (context) => const FarmListScreen(),
          AddFarmScreen.routeName: (context) => const AddFarmScreen(),
          FarmDetailScreen.routeName: (context) => const FarmDetailScreen(),
          SoilAnalysisScreen.routeName: (context) => const SoilAnalysisScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Consumer here so this widget rebuilds every time auth changes.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while the provider is initializing.
        if (authProvider.state == AuthState.initial || authProvider.state == AuthState.loading) {
          return const SplashScreen(); // Your existing splash screen is perfect here.
        }
        
        // If authenticated, show the dashboard and load its data.
        if (authProvider.isAuthenticated) {
          // One can also trigger data loading here if needed
          // Provider.of<FarmProvider>(context, listen: false).loadFarms();
          // Provider.of<SoilAnalysisProvider>(context, listen: false).loadAnalyses();
          return const DashboardScreen();
        } 
        // Otherwise, show the login screen.
        else {
          return const LoginScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.primaryGreen),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              ),
              child: Icon(
                Icons.agriculture,
                size: 60,
                color: Color(AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // App Name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // App Description
            Text(
              AppConstants.appDescription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

