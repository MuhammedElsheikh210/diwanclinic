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

      // 🔥 Firebase
      await Firebase.initializeApp();

      // 🔔 Register background handler (VERY IMPORTANT)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 🔹 Lock Orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // 🔹 Local DB
      final dbService = DatabaseService();
      await dbService.database;
      await dbService.checkTables();

      // 🔹 Storage
      await StorageService().init();

      // 🔔 Notification Core
      await NotificationService().initCore();

      // 🔥 Remote Config
      await FirebaseRemoteConfigService().checkForceUpdate();

      // 🔹 Bindings
      Binding().dependencies();

      // 🎨 ThemeScope (AFTER everything)
      final app = await ThemeScopeWidget.initialize(const MyApp());

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
    final localStorage = LocalStorage_language();
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

      // 🌐 Language
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
