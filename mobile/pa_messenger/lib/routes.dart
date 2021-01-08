import 'package:pa_messenger/pages/app_container.dart';
import 'package:pa_messenger/pages/conversation_list.dart';
import 'package:pa_messenger/pages/login.dart';
import 'package:pa_messenger/pages/verify_phone.dart';

final appRoutes = {
  '/': (_) => AppContainer(),
  '/login': (_) => Login(),
  '/verify-phone': (_) => VerifyPhone()
};
