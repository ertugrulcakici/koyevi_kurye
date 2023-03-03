import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';
import 'package:koyevi_kurye/product/widget/error_page.dart';
import 'package:koyevi_kurye/product/widget/filter_qr_textfield.dart';
import 'package:koyevi_kurye/product/widget/order_line.dart';
import 'package:koyevi_kurye/view/main/teslim_al/teslim_al_notifier.dart';

class TeslimAlView extends ConsumerStatefulWidget {
  const TeslimAlView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TeslimAlViewState();
}

class _TeslimAlViewState extends ConsumerState<TeslimAlView> {
  late final ChangeNotifierProvider<TeslimAlNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => TeslimAlNotifier());
    Future.delayed(Duration.zero, () {
      ref.read(provider).getOrders();
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
          callBack: ref.read(provider).getOrders,
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
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Teslim al'),
                  content: const Text(
                      'Bu siparişi teslim almayı onaylıyor musunuz ?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Hayır')),
                    TextButton(
                        onPressed: () {
                          ref.read(provider).teslimAl(siparisModel.ficheNo);
                          Navigator.pop(context);
                        },
                        child: const Text('Onayla'))
                  ],
                );
              });
        });
  }
}
