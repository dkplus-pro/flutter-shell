import 'package:fluttershell/features/home/presentation/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route path constants. New pages register here and in [appRouterProvider].
abstract final class AppRoutes {
  static const String home = '/';
}

/// App router. keepAlive: the router must survive navigation (a page-scoped
/// router would reset navigation state on every rebuild).
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
