import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/services/network/network_service.dart';
import 'package:koyevi_kurye/core/services/network/response_model.dart';
import 'package:koyevi_kurye/core/utils/helpers/popup_helper.dart';
import 'package:koyevi_kurye/product/mixin/error_support_notifier.dart';
import 'package:koyevi_kurye/product/mixin/loading_support_notifier.dart';
import 'package:koyevi_kurye/product/models/payment_type_model.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';

class TeslimEtNotifier extends ChangeNotifier
    with LoadingSupportNotifier, ErrorSupportNotifier {
  List<SiparisModel> orders = [];
  List<SiparisModel> ordersFiltered = [];
  List<PaymentTypeModel> paymentTypes = [];
  Map<int, num> paymentTypeMap = {};

  Future<void> getData() async {
    try {
      isLoading = true;
      ResponseModel ordersModel =
          await NetworkService.get("courier/DeliverToCustomerList");
      ResponseModel paymentTypesModel =
          await NetworkService.get("orders/PaymentSummary/0");

      if (ordersModel.success && paymentTypesModel.success) {
        orders = ordersModel.data
            .map<SiparisModel>((e) => SiparisModel.fromJson(e))
            .toList();
        ordersFiltered = orders.toList();
        paymentTypes = paymentTypesModel.data
            .map<PaymentTypeModel>((e) => PaymentTypeModel.fromJson(e))
            .toList();
        hasError = false;
      } else {
        hasError = true;
        errorDetail =
            "${ordersModel.errorMessage ?? "Siparişler alınırken hata oluşmadı"}\n${paymentTypesModel.errorMessage ?? "Ödeme tipleri alınırken hata oluşmadı"}";
      }
    } catch (e) {
      hasError = true;
      errorDetail = e;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> deliveryOrder({
    required String ficheNo,
    required String deliverycode,
    required String notes,
  }) async {
    try {
      ResponseModel responseModel = await NetworkService.post(
        "courier/DeliverToCustomer",
        body: {
          "ficheNo": ficheNo,
          "deliverycode": deliverycode,
          "notes": notes,
          "payments": paymentTypeMap.entries
              .map((e) => {
                    "paymenttype": e.key,
                    "amount": e.value,
                  })
              .toList(),
        },
      );
      if (responseModel.success) {
        getData();
        PopupHelper.showSuccessToast("Sipariş teslim edildi");
        return true;
      } else {
        PopupHelper.showErrorToast(responseModel.errorMessage!);
        return false;
      }
    } catch (e) {
      PopupHelper.showErrorToast("Sipariş teslim edilirken hata oluştu: $e");
      return false;
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
