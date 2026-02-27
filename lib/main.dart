import 'index/index_main.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 🔥 Firebase
      await Firebase.initializeApp();

      // 🔹 Orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // 🔹 Local DB
      final dbService = DatabaseService();
      await dbService.database;
      await dbService.checkTables();
      //   await dbService.deleteDatabaseFile();

      // 🔹 Storage & Services
      await StorageService().init();
    //  await NotificationService().initCore();

      await FirebaseRemoteConfigService().checkForceUpdate();

      // 🔹 Bindings (مرة واحدة)
      Binding().dependencies();

      // ✅ IMPORTANT
      // ThemeScope لازم يشتغل *بعد* ScreenUtilInit
      final app = await ThemeScopeWidget.initialize(const MyApp());

      runApp(
        ScreenUtilInit(
          designSize: const Size(430, 932),
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (context, child) => app,
        ),
      );

      // 🔥 Seeder starts AFTER UI (background)
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
    // لو هتستخدمه بعدين تمام
    final localStorage = LocalStorage_language();
    return "ar";
  }

  @override
  Widget build(BuildContext context) {
    // ✅ دلوقتي ThemeScope موجود ومش هيكراش
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
