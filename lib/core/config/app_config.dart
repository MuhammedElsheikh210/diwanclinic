class AppConfig {
  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  final String flavor;
  final String baseUrl;

  AppConfig._({required this.flavor, required this.baseUrl});

  static void setup({required String flavor, required String baseUrl}) {
    _instance = AppConfig._(flavor: flavor, baseUrl: baseUrl);
  }

  bool get isDev => flavor == 'dev';
  bool get isProd => flavor == 'prod';
}
