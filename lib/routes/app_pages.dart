 
import 'package:get/get.dart';
import '../auth/views/login_view.dart';
import '../auth/views/create_account_view.dart';
import '../auth/views/forgot_password_view.dart';

import '../non_login/home/views/home_view_non_login.dart';
import '../non_login/browse/views/browse_view.dart';
// import '../non_login/applied/views/applied_view.dart';
// import '../non_login/profile/views/profile_view.dart';

// import '../login/home/views/home_view.dart' as LoginHomeView;
// import '../login/browse/views/browse_view.dart' as LoginBrowseView;
// import '../login/applied/views/applied_view.dart' as LoginAppliedView;
// import '../login/profile/views/profile_view.dart' as LoginProfileView;

import 'app_routes.dart';

class AppPages {
  static final pages = [
    // Authentication Pages
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoutes.createAccount,
      page: () => CreateAccountView(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordView(),
    ),

    // Non-login Pages
    GetPage(
      name: AppRoutes.homeNonLogin,
      page: () => HomeViewNonLogin(),
    ),
    GetPage(
      name: AppRoutes.browseNonLogin,
      page: () => BrowseView(),
    ),

  ];
}
