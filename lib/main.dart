import 'dart:developer';
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

      await Firebase.initializeApp();

      // DB
      final dbService = DatabaseService();
      await dbService.database;

      // Storage
      final storage = StorageService();
      await storage.init();
      Get.put(storage, permanent: true);

      // 🔥 Local User Module
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

      // Notifications
      await NotificationService().initCore();

      // Bindings
      Binding().dependencies();

      // ✅ IMPORTANT: ScreenUtil FIRST
      runApp(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            return ThemeScopeWidget(
              preferences: ThemePreferences(), // 👈 مش null
              child: const MyApp(),
            );
          },
        ),
      );
    },
    (e, s) {
      debugPrint("❌ ZONE ERROR: $e");
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
