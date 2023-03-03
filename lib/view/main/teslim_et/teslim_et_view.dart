import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koyevi_kurye/core/services/navigation/navigation_service.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';
import 'package:koyevi_kurye/product/widget/error_page.dart';
import 'package:koyevi_kurye/product/widget/filter_qr_textfield.dart';
import 'package:koyevi_kurye/product/widget/order_line.dart';
import 'package:koyevi_kurye/view/main/teslim_et/teslim_et_notifier.dart';

class TeslimEtView extends ConsumerStatefulWidget {
  const TeslimEtView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TeslimEtViewState();
}

class _TeslimEtViewState extends ConsumerState<TeslimEtView> {
  late final ChangeNotifierProvider<TeslimEtNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => TeslimEtNotifier());
    Future.delayed(Duration.zero, () {
      ref.read(provider).getData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    if (ref.watch(provider).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ref.watch(provider).hasError) {
      return ErrorPage(
          callBack: ref.read(provider).getData,
          errorDetail: ref.watch(provider).errorDetail);
    }

    return _content();
  }

  Column _content() {
    return Column(
      children: [
        FilterQrTextfield(onChanged: ref.read(provider).onChanged),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: ref.watch(provider).ordersFiltered.length,
              itemBuilder: (context, index) {
                return _siparisSatir(ref.watch(provider).ordersFiltered[index]);
              }),
        )
      ],
    );
  }

  Widget _siparisSatir(SiparisModel siparisModel) {
    return SiparisSatirListTile(
        siparisModel: siparisModel,
        callback: () {
          ref.watch(provider).paymentTypeMap.clear();
          NavigationService.navigateToPage(
              PaymentDialog(provider: provider, siparisModel: siparisModel));
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return Dialog(
          //         insetPadding: const EdgeInsets.all(16),
          //         child: ,
          //       );
          //     });
        });
  }
}

class PaymentDialog extends ConsumerWidget {
  final ChangeNotifierProvider<TeslimEtNotifier> provider;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _deliveryNoController = TextEditingController();
  final SiparisModel siparisModel;
  PaymentDialog(
      {super.key, required this.provider, required this.siparisModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Siparişi teslim ediyorsunuz",
                      style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  ...[
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Teslimat numarası boş olamaz";
                        }
                        return null;
                      },
                      controller: _deliveryNoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Teslimat numarası giriniz"),
                    ),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: "Teslimat notu giriniz"),
                    ),
                  ],
                  ...ref
                      .watch(provider)
                      .paymentTypes
                      .map<Widget>((e) => TextFormField(
                            initialValue: "0",
                            onChanged: (value) {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                ref.read(provider).notifyListeners();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              value = value.trim();
                              value = value.replaceAll(',', '.');
                              try {
                                num.parse(value);
                                return null; // Geçerli bir sayı.
                              } catch (e) {
                                return 'Geçersiz sayı';
                              }
                            },
                            onSaved: (value) {
                              if (value != null && value.isNotEmpty) {
                                ref.read(provider).paymentTypeMap[e.code] =
                                    num.parse(
                                        value.trim().replaceAll(",", "."));
                              } else {
                                log("e: $e is empty. value: $value");
                              }
                            },
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: e.typeName,
                              hintText: e.typeName,
                            ),
                          ))
                      .toList(),
                  const Divider(),
                  Consumer(
                    builder: (context, refInner, child) {
                      return Column(
                        children: [
                          Text(
                              "Toplam ödenmesi gereken: ${siparisModel.total.toStringAsFixed(2)} TL"),
                          const Divider(),
                          Text(
                              "Ödenen: ${refInner.watch(provider).paymentTypeMap.values.fold<num>(0, (previousValue, element) => previousValue + element).toStringAsFixed(2)} TL"),
                          const Divider(),
                          Text(
                              "Kalan: ${(siparisModel.total - refInner.watch(provider).paymentTypeMap.values.fold<num>(0, (previousValue, element) => previousValue + element)).toStringAsFixed(2)} TL"),
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("İptal")),
                      TextButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();

                              ref
                                  .read(provider)
                                  .deliveryOrder(
                                    ficheNo: siparisModel.ficheNo,
                                    deliverycode: _deliveryNoController.text,
                                    notes: _noteController.text,
                                  )
                                  .then((value) {
                                if (value) {
                                  Navigator.pop(context);
                                }
                              });
                            }
                          },
                          child: const Text("Teslim et"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
