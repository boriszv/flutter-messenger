import 'package:pa_messenger/pages/app_container.dart';
import 'package:pa_messenger/pages/chat.dart';
import 'package:pa_messenger/pages/login.dart';
import 'package:pa_messenger/pages/take_picture.dart';
import 'package:pa_messenger/pages/take_picture_preivew.dart';
import 'package:pa_messenger/pages/verify_phone.dart';

final appRoutes = {
  '/': (_) => AppContainer(),
  '/chat': (_) => Chat(),
  '/login': (_) => Login(),
  '/verify-phone': (_) => VerifyPhone(),
  '/take-picture': (_) => TakePicture(),
  '/take-picture-preview': (_) => TakePicturePreview(),
};
