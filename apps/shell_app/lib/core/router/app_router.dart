import 'package:fluttershell/core/shell/app_shell_page.dart';
import 'package:fluttershell/features/bridge_demo/presentation/bridge_demo_page.dart';
import 'package:fluttershell/features/home/presentation/home_page.dart';
import 'package:fluttershell/features/hotel/presentation/hotel_chat_page.dart';
import 'package:fluttershell/features/profile/presentation/profile_page.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Route path constants. New pages register here and in [appRouterProvider].
abstract final class AppRoutes {
  static const String home = '/';
  static const String service = '/service';
  static const String profile = '/profile';
  static const String bridgeDemo = '/bridge';
}

/// App router. keepAlive: the router must survive navigation (a page-scoped
/// router would reset navigation state on every rebuild).
///
/// The three main tabs live in a [StatefulShellRoute.indexedStack]; the demo
/// opens directly on the concierge chat (PRD 4). The bridge demo stays a
/// top-level route so it fills the whole screen.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.service,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.service,
                builder: (context, state) => const HotelChatPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.bridgeDemo,
        builder: (context, state) => const BridgeDemoPage(),
      ),
    ],
  );
}
