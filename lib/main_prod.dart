import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() {
  AppConfig.setup(
    flavor: 'prod',
    baseUrl: 'https://link-b47c8-default-rtdb.firebaseio.com',
  );
  app.main();
}
