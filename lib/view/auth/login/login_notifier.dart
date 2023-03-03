import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/services/authservice/authservice.dart';
import 'package:koyevi_kurye/core/services/authservice/user_model.dart';
import 'package:koyevi_kurye/core/services/network/response_model.dart';
import 'package:koyevi_kurye/core/utils/helpers/popup_helper.dart';

import '../../../core/services/network/network_service.dart';

class LoginNotifier extends ChangeNotifier {
  Future<void> login(String username, String password) async {
    ResponseModel loginResponse =
        await NetworkService.get("courier/Login/$username/$password");
    if (loginResponse.success) {
      if (loginResponse.data != false) {
        PopupHelper.showSuccessToast("Giriş başarılı");

        AuthService.instance.login(UserModel(
            id: loginResponse.data["ID"],
            username: username,
            password: password,
            name: loginResponse.data["Name"]));
      } else {
        PopupHelper.showErrorToast(
            "Giriş başarısız: ${loginResponse.errorMessage}");
      }
    } else {
      PopupHelper.showErrorToast(loginResponse.errorMessage!);
    }
  }
}
