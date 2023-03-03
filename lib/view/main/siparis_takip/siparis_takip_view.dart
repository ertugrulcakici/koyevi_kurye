import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koyevi_kurye/core/services/navigation/navigation_service.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';
import 'package:koyevi_kurye/product/widget/error_page.dart';
import 'package:koyevi_kurye/product/widget/filter_qr_textfield.dart';
import 'package:koyevi_kurye/product/widget/order_line.dart';
import 'package:koyevi_kurye/view/main/siparis_satirlar/siparis_satirlar_view.dart';
import 'package:koyevi_kurye/view/main/siparis_takip/siparis_takip_notifier.dart';

class SiparisTakipView extends ConsumerStatefulWidget {
  const SiparisTakipView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SiparisTakipViewState();
}

class _SiparisTakipViewState extends ConsumerState<SiparisTakipView> {
  late final ChangeNotifierProvider<SiparisTakipNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider((ref) => SiparisTakipNotifier());
    Future.delayed(Duration.zero, () {
      ref.read(provider).getOrders();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
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
        FilterQrTextfield(onChanged: ref.read(provider).onChanged),
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
        callback: () {
          NavigationService.navigateToPage<bool>(
                  SiparisSatirlarView(siparisModel: siparisModel))
              .then((value) {
            if (value) {
              ref.read(provider).getOrders();
            }
          });
        },
        siparisModel: siparisModel);
  }
}
