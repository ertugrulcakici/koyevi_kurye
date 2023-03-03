import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late final TextEditingController _noteController;
  late final TextEditingController _deliveryNoController;

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => TeslimEtNotifier());
    _noteController = TextEditingController();
    _deliveryNoController = TextEditingController();
    Future.delayed(Duration.zero, () {
      ref.read(provider).getData();
    });

    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _deliveryNoController.dispose();
    _formKey.currentState?.dispose();

    super.dispose();
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
        FilterQrTextfield(
          onChanged: ref.read(provider).onChanged,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: ref.watch(provider).ordersFiltered.length,
            itemBuilder: (context, index) {
              return _siparisSatir(ref.watch(provider).ordersFiltered[index]);
            })
      ],
    );
  }

  Widget _siparisSatir(SiparisModel siparisModel) {
    return SiparisSatirListTile(
        siparisModel: siparisModel,
        callback: () {
          _noteController.text = "";
          _deliveryNoController.text = "";
          ref.watch(provider).paymentTypeMap.clear();

          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Siparişi teslim ediyorsunuz"),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                    if (value != null) {
                                      if (value.isNotEmpty) {
                                        ref
                                                .read(provider)
                                                .paymentTypeMap[e.code] =
                                            num.parse(value
                                                .trim()
                                                .replaceAll(",", "."));
                                      }
                                    }
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    labelText: e.typeName,
                                    hintText: e.typeName,
                                  ),
                                ))
                            .toList(),
                        const Divider(),
                        Text(
                            "Toplam ödenmesi gereken: ${siparisModel.total} TL")
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("İptal")),
                    TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            ref.read(provider).deliveryOrder(
                                  ficheNo: siparisModel.ficheNo,
                                  deliverycode: _deliveryNoController.text,
                                  notes: _noteController.text,
                                );

                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Teslim et"))
                  ],
                );
              });
        });
  }
}
