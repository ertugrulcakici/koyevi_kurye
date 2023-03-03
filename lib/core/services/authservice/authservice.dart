import 'package:koyevi_kurye/core/services/authservice/authservice_cache_enums.dart';
import 'package:koyevi_kurye/core/services/authservice/user_model.dart';
import 'package:koyevi_kurye/core/services/cache/cache_manager.dart';
import 'package:koyevi_kurye/core/services/navigation/navigation_service.dart';
import 'package:koyevi_kurye/core/services/network/network_service.dart';
import 'package:koyevi_kurye/home.dart';
import 'package:koyevi_kurye/view/auth/login/login_view.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();
  AuthService._internal();

  UserModel? _user;

  static AuthService get instance => _authService;
  UserModel get user => _authService._user!;

  void login(UserModel user) {
    CacheManager.instance
        .setBool(AuthServiceCacheEnums.isLoggedIn.toString(), true);
    CacheManager.instance
        .setString(AuthServiceCacheEnums.username.toString(), user.username);
    CacheManager.instance
        .setString(AuthServiceCacheEnums.password.toString(), user.password);
    CacheManager.instance.setInt(AuthServiceCacheEnums.id.toString(), user.id);
    CacheManager.instance
        .setString(AuthServiceCacheEnums.name.toString(), user.name);
    _staticLogin(user);
    NavigationService.navigateToPage(const HomeView());
  }

  void _staticLogin(UserModel userModel) {
    _authService._user = userModel;
    NetworkService.addLoginHeader(userModel.id);
  }

  Future<void> logout() async {
    await CacheManager.instance
        .setBool(AuthServiceCacheEnums.isLoggedIn.toString(), false);
    await CacheManager.instance
        .remove(AuthServiceCacheEnums.username.toString());
    await CacheManager.instance
        .remove(AuthServiceCacheEnums.password.toString());
    await CacheManager.instance.remove(AuthServiceCacheEnums.id.toString());
    await CacheManager.instance.remove(AuthServiceCacheEnums.name.toString());
    _authService._user = null;
    NavigationService.navigateToPageAndRemoveUntil(const LoginView());
  }

  bool get isLoggedIn {
    bool isLoggedInInside = CacheManager.instance
            .getBool(AuthServiceCacheEnums.isLoggedIn.toString()) ??
        false;
    if (isLoggedInInside) {
      UserModel user = UserModel(
          id: CacheManager.instance
              .getInt(AuthServiceCacheEnums.id.toString())!,
          username: CacheManager.instance
              .getString(AuthServiceCacheEnums.username.toString())!,
          password: CacheManager.instance
              .getString(AuthServiceCacheEnums.password.toString())!,
          name: CacheManager.instance
              .getString(AuthServiceCacheEnums.name.toString())!);
      _staticLogin(user);
      return true;
    } else {
      return false;
    }
  }
}
