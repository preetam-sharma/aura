import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/home/home_screen.dart';
import '../common_widgets/loading_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authState.when(
      data: (_) => null, 
      loading: () => null,
      error: (_, _) => null,
    ),
    redirect: (context, state) {
      if (authState.isLoading) return null; // Let the builder handle it or wait
      
      final user = authState.value;
      final loggingIn = state.uri.path == '/login';
      final signingUp = state.uri.path == '/signup';

      if (user == null) {
        if (loggingIn || signingUp) return null;
        return '/login';
      }

      if (loggingIn || signingUp) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          return authState.when(
            data: (user) => user == null ? const LoginScreen() : const HomeScreen(),
            loading: () => const LoadingScreen(message: 'Initializing Secure Session...'),
            error: (err, stack) => const LoginScreen(),
          );
        },
      ),
    ],
  );
});
