import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'index/index_main.dart';

/// 🔔 MUST be top-level
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("🔔 [Background] MessageId: ${message.messageId}");
  log("🧩 [Background Data]: ${message.data}");
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 🔥 Firebase
      await Firebase.initializeApp();

      // 🔔 Background notifications
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 🔹 Lock Orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // 🔹 Local DB
      final dbService = DatabaseService();
      // await dbService.deleteDatabaseFile();

      await dbService.database;
      await dbService.checkTables();

      // 🔹 Storage
      final storage = StorageService();
      await storage.init();
      Get.put(storage, permanent: true);

      // 🔥 Local User Module (NEW)
      Get.lazyPut<LocalUserDataSource>(
        () => LocalUserDataSource(Get.find()),
        fenix: true,
      );

      Get.lazyPut<LocalUserRepository>(
        () => LocalUserRepository(Get.find()),
        fenix: true,
      );

      await Get.putAsync<UserSession>(
        () async => await UserSession(Get.find()).init(),
      );

      // 🔔 Notification Core
      await NotificationService().initCore();

      // 🔥 Remote Config
      await FirebaseRemoteConfigService().checkForceUpdate();

      // 🔹 Register Dependencies
      Binding().dependencies();

      // 🎨 ThemeScope (🔥 مهم جدًا)
      final app = await ThemeScopeWidget.initialize(const MyApp());

      // ✅ ScreenUtil AFTER initialize
      runApp(
        ScreenUtilInit(
          designSize: const Size(430, 932),
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (_, __) => app,
        ),
      );
    },
    (e, s) {
      debugPrint("❌ ZONE ERROR: $e");
      debugPrintStack(stackTrace: s);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  String getLocalLan() {
    return "ar";
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Link',

      // 🌍 Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('ar')],

      locale: Locale(getLocalLan()),
      fallbackLocale: const Locale('ar'),

      // 🧭 Navigation
      initialRoute: loginView,
      getPages: Routes.handle_routes(),
      initialBinding: Binding(),

      // 🎨 Theme
      themeMode: theme.themeMode,
      theme: ThemeData(extensions: [theme.appTheme]),
      darkTheme: ThemeData(extensions: [theme.appTheme]),

      // ⏳ Loader
      builder: EasyLoading.init(),

      // 🌐 Translations
      translations: Translation(),
    );
  }
}
