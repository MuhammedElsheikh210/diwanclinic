import '../../Presentation/screens/forceudpate/force_update_local.dart';
import '../../index/index_main.dart';

class RouteWelcomeMiddleWare extends GetMiddleware {
  RouteWelcomeMiddleWare({super.priority});

  @override
  RouteSettings? redirect(String? route) {
    final user = LocalUser().getUserData();
    print("user type is ${user.userType}");

    final forceUpdateModel = ForceUdpate().getForceUpdateData();
    // ---------------------------------------------------------
    // 1️⃣ FORCE UPDATE ALWAYS COMES FIRST
    // ---------------------------------------------------------
    if (forceUpdateModel?.forceUpdate == true) {
      return const RouteSettings(name: forceUpdateView);
    }

    // ---------------------------------------------------------
    // 3️⃣ LOGIN CHECK
    // ---------------------------------------------------------
    if (user.key == null || user.uid == null) {
      // User is not logged in
      return null;
    }

    // ---------------------------------------------------------
    // 4️⃣ ALLOW NAVIGATION
    // ---------------------------------------------------------
    return user.userType == UserType.patient ||
            user.userType == UserType.pharmacy
        ? const RouteSettings(name: mainpage)
        : const RouteSettings(name: syncView);
  }
}
