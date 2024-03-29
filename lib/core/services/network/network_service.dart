import 'dart:developer';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/services/navigation/navigation_service.dart';
import 'package:koyevi_kurye/core/services/network/response_model.dart';
import 'package:koyevi_kurye/product/constants/app_constants.dart';

abstract class NetworkService {
  static late Dio _dio;
  static const debug = true;
  static const debugDetailed = true;
  static bool notInited = true;

  static Future<void> init() async {
    try {
      Dio tempDio = Dio(BaseOptions(
          sendTimeout: 15000, connectTimeout: 15000, receiveTimeout: 15000));
      (tempDio.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return null;
      };
      Response<Map<String, dynamic>> response = await tempDio
          .post<Map<String, dynamic>>("${AppConstants.APP_API}/app/gettoken",
              data: {
            "grant_type": "password",
            "username": "admin",
            "password": "\$inFtecH1100%",
          });
      AppConstants.appToken = response.data!["data"];
      notInited = false;
    } catch (e) {
      await await showDialog(
          context: NavigationService.context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Bağlantı Hatası"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Tekrar dene"))
              ],
            );
          });
    }

    String token = AppConstants.appToken;
    Map<String, dynamic> headers = <String, dynamic>{};
    headers["Authorization"] = "Bearer $token";

    _dio = Dio(BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 5000,
        headers: headers,
        contentType: Headers.jsonContentType,
        baseUrl: AppConstants.APP_API));

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return null;
    };
  }

  static Future<ResponseModel<T>> get<T>(String url,
      {Map<String, dynamic>? queryParameters}) async {
    while (notInited) {
      await init();
    }
    String fullUrl = url;
    try {
      if (debug) {
        log("GET : $fullUrl");
      }

      Response<Map<String, dynamic>> data =
          await _dio.get<Map<String, dynamic>>(
        fullUrl,
        queryParameters: queryParameters,
      );
      if (debugDetailed) {
        log("GET DATA: ${data.data}");
      }
      return ResponseModel<T>.fromJson(data.data!);
    } catch (e) {
      int? statusCode = (e as DioError).response!.statusCode;
      if (statusCode == 401) {
        notInited = true;
      }

      // ignore: use_build_context_synchronously
      bool? tryAgain = await showDialog(
        context: NavigationService.context,
        builder: (context) {
          return AlertDialog(
            title: Text(statusCode == 500
                ? "Sunucu kaynaklı hata"
                : "Bağlantı hatası 2" "$statusCode"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Tekrar dene"))
            ],
          );
        },
      );

      // bool tryAgain = await PopupHelper.showErrorDialog<bool>(
      //     errorMessage:
      //         statusCode == 500 ? "Sunucu kaynaklı hata" : "Bağlantı hatası",
      //     actions: {
      //       "Tekrar dene": () {
      //         NavigationService.back(data: true);
      //       }
      //     });
      //     log("tryAgain: $tryAgain");
      if (tryAgain == true) {
        return await get<T>(url, queryParameters: queryParameters);
      } else {
        return ResponseModel<T>.networkError();
      }
    }
  }

  static Future<ResponseModel<T>> post<T>(String url,
      {Map<String, dynamic>? queryParameters, dynamic body}) async {
    while (notInited) {
      await init();
    }

    String fullUrl = url;
    try {
      if (debug) {
        log("POST: $fullUrl");
        log("POST BODY: $body");
      }

      Response<Map<String, dynamic>> response =
          await _dio.post<Map<String, dynamic>>(
        fullUrl,
        queryParameters: queryParameters,
        data: body,
      );
      if (debugDetailed) {
        log("POST DATA: ${response.data}");
      }
      return ResponseModel<T>.fromJson(response.data!);
    } catch (e) {
      log("Hata: $e");
      // token expired
      int? statusCode = (e as DioError).response!.statusCode;
      if (statusCode == 401) {
        notInited = true;
      }
      // ignore: use_build_context_synchronously
      bool? tryAgain = await showDialog(
        context: NavigationService.context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                statusCode == 500 ? "Sunucu kaynaklı hata" : "Bağlantı hatası"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Tekrar dene"))
            ],
          );
        },
      );
      if (tryAgain == true) {
        return await post<T>(url, queryParameters: queryParameters, body: body);
      } else {
        return ResponseModel<T>.networkError();
      }
    }
  }

  static void addLoginHeader(int id) async {
    if (notInited) {
      await init();
    }
    _dio.options.headers["CourierUserID"] = id;
    log("addLoginHeader: ${_dio.options.headers}", name: "NetworkService");
  }
}
