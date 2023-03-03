import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/services/network/network_service.dart';
import 'package:koyevi_kurye/core/services/network/response_model.dart';
import 'package:koyevi_kurye/core/utils/helpers/popup_helper.dart';
import 'package:koyevi_kurye/product/mixin/error_support_notifier.dart';
import 'package:koyevi_kurye/product/mixin/loading_support_notifier.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';
import 'package:koyevi_kurye/product/models/siparis_satir_model.dart';

class SiparisSatirlarNotifier extends ChangeNotifier
    with LoadingSupportNotifier, ErrorSupportNotifier {
  final SiparisModel siparisModel;
  SiparisSatirlarNotifier({required this.siparisModel});

  List<SiparisSatirModel> siparisSatirlari = [];

  Future<void> getOrderLines() async {
    try {
      isLoading = true;
      ResponseModel responseModel = await NetworkService.get(
          "courier/OrderDetail/${siparisModel.ficheNo}");
      if (responseModel.success) {
        siparisSatirlari = responseModel.data
            .map<SiparisSatirModel>((e) => SiparisSatirModel.fromJson(e))
            .toList();
        hasError = false;
      } else {
        hasError = true;
        errorDetail = responseModel.errorMessage!;
      }
    } catch (e) {
      hasError = true;
      errorDetail = e;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> teslimAl() async {
    try {
      isLoading = true;
      ResponseModel responseModel = await NetworkService.get(
          "courier/DeliverToCourier/${siparisModel.ficheNo}");
      if (responseModel.success) {
        PopupHelper.showSuccessToast("Sipariş teslim alındı");
        return true;
      } else {
        PopupHelper.showErrorToast(
            "Sipariş teslim alınırken hata oluştu: ${responseModel.errorMessage}");
        return false;
      }
    } catch (e) {
      PopupHelper.showErrorToast("Sipariş teslim alınırken hata oluştu");
      return false;
    } finally {
      isLoading = false;
    }
  }
}
