import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/services/network/network_service.dart';
import 'package:koyevi_kurye/core/services/network/response_model.dart';
import 'package:koyevi_kurye/core/utils/helpers/popup_helper.dart';
import 'package:koyevi_kurye/product/mixin/error_support_notifier.dart';
import 'package:koyevi_kurye/product/mixin/loading_support_notifier.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';

class TeslimAlNotifier extends ChangeNotifier
    with LoadingSupportNotifier, ErrorSupportNotifier {
  List<SiparisModel> orders = [];
  List<SiparisModel> ordersFiltered = [];

  Future<void> getOrders() async {
    try {
      isLoading = true;
      ResponseModel ordersModel =
          await NetworkService.get("courier/DeliverToCourierList");
      if (ordersModel.success) {
        orders = ordersModel.data
            .map<SiparisModel>((e) => SiparisModel.fromJson(e))
            .toList();
        ordersFiltered = orders.toList();
        hasError = false;
      } else {
        hasError = true;
        errorDetail = ordersModel.errorMessage!;
      }
    } catch (e) {
      hasError = true;
      errorDetail = e;
    } finally {
      isLoading = false;
    }
  }

  Future<void> teslimAl(String ficheNo) async {
    try {
      ResponseModel responseModel =
          await NetworkService.get("courier/DeliverToCourier/$ficheNo");
      if (responseModel.success) {
        getOrders();
        PopupHelper.showSuccessToast("Sipariş başarıyla teslim alındı");
      }
    } catch (e) {
      PopupHelper.showErrorToast("Sipariş teslim alınırken hata oluştu: $e");
    }
  }

  void onChanged(String value) {
    ordersFiltered = orders
        .where((element) =>
            element.ficheNo.toLowerCase().contains(value.toLowerCase()) ||
            element.packageList.any((element) => element
                .toLowerCase()
                .trim()
                .contains(value.toLowerCase().trim())))
        .toList();
    notifyListeners();
  }
}
