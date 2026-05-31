import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() {
  AppConfig.setup(
    flavor: 'dev',
    baseUrl: 'https://linkstage-4cc42-default-rtdb.firebaseio.com',
  );
  app.main();
}
