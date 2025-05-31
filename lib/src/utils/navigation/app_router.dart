import 'package:auto_route/auto_route.dart';
import 'package:triva/src/modules/home/screens/home_screen.dart';
import 'package:triva/src/modules/home/screens/onboarding_screen.dart';
import 'package:triva/src/modules/home/screens/verify_otp_screen.dart';
import 'package:triva/src/modules/home/screens/login_screen.dart';
import 'package:triva/src/modules/home/screens/register_screen.dart';
import 'package:triva/src/modules/home/screens/dashboard_screen.dart';
import 'package:triva/src/modules/home/screens/splash_screen.dart';
part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
final class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  final List<AutoRoute> routes = [
    CustomRoute(
      page: SplashRoute.page,
      path: '/splash',
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: HomeRoute.page,
      path: '/home',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: OnboardingRoute.page,
      path: '/onboarding',
      transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
    ),
    CustomRoute(
      page: RegisterRoute.page,
            path: '/register',

      transitionsBuilder: TransitionsBuilders.slideRightWithFade,
    ),
    CustomRoute(
      page: VerifyOtpRoute.page,
      path: '/verify-otp',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
    CustomRoute(
      page: LoginRoute.page,
      path: '/login',
      transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
    ),
    CustomRoute(
      page: DashboardRoute.page,
      path: '/dashboard',
      transitionsBuilder: TransitionsBuilders.fadeIn,
    ),
  ];
}

