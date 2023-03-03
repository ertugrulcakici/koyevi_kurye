import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';
import 'package:koyevi_kurye/product/models/siparis_satir_model.dart';
import 'package:koyevi_kurye/product/widget/error_page.dart';
import 'package:koyevi_kurye/view/main/siparis_satirlar/siparis_satirlar_notifier.dart';

class SiparisSatirlarView extends ConsumerStatefulWidget {
  final SiparisModel siparisModel;
  const SiparisSatirlarView({super.key, required this.siparisModel});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SiparisSatirlarViewState();
}

class _SiparisSatirlarViewState extends ConsumerState<SiparisSatirlarView> {
  late final ChangeNotifierProvider<SiparisSatirlarNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider(
        (ref) => SiparisSatirlarNotifier(siparisModel: widget.siparisModel));
    Future.delayed(Duration.zero, () {
      ref.read(provider).getOrderLines();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _backDialog(context);
        return Future.value(false);
      },
      child: SafeArea(
          child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _fab(context),
          label: const Text("Teslim al"),
          icon: const Icon(Icons.check_circle_outline),
        ),
        appBar: AppBar(title: const Text('Sipariş Satırları')),
        body: _body(),
      )),
    );
  }

  Future<void> _fab(BuildContext context) async {
    if (ref
        .watch(provider)
        .siparisSatirlari
        .where((element) => !element.isAdded)
        .isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Dikkat"),
              content: const Text(
                  "Siparişinizde eksik ürün var. Yinede devam etmek istiyor musunuz ?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text("Hayır")),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context, false);
                      bool success = await ref.read(provider).teslimAl();
                      if (success) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text("Evet")),
              ],
            );
          });
    }
  }

  Future<dynamic> _backDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Dikkat"),
            content: const Text(
                "Yaptığınız değişiklikler silinecek. Çıkmak istediğinize emin misiniz?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Hayır")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    Navigator.pop(context, false);
                  },
                  child: const Text("Evet")),
            ],
          );
        });
  }

  Widget _body() {
    if (ref.watch(provider).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ref.watch(provider).hasError) {
      return ErrorPage(
          callBack: ref.read(provider).getOrderLines,
          errorDetail: ref.watch(provider).errorDetail);
    }

    return _content();
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text("Henüz eklenmemiş ürünler"),
          const Divider(),
          ListView.builder(
              shrinkWrap: true,
              itemCount: ref
                  .watch(provider)
                  .siparisSatirlari
                  .where((element) => !element.isAdded)
                  .length,
              itemBuilder: (context, index) {
                return _siparisSatir(
                    ref.watch(provider).siparisSatirlari[index]);
              }),
          const Divider(height: 20, color: Colors.black, thickness: 2),
          const Text("Eklenmiş ürünler"),
          const Divider(),
          ListView.builder(
              shrinkWrap: true,
              itemCount: ref
                  .watch(provider)
                  .siparisSatirlari
                  .where((element) => element.isAdded)
                  .length,
              itemBuilder: (context, index) {
                return _siparisSatir(
                    ref.watch(provider).siparisSatirlari[index]);
              }),
        ],
      ),
    );
  }

  Widget _siparisSatir(SiparisSatirModel siparisSatirModel) {
    return CheckboxListTile(
        value: siparisSatirModel.isAdded,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.green,
        tileColor: siparisSatirModel.isAdded ? Colors.green : Colors.white,
        onChanged: (value) {
          ref
              .read(provider)
              .siparisSatirlari
              .firstWhere((element) => element.id == siparisSatirModel.id)
              .isAdded = value!;
          ref.read(provider).notifyListeners();
        },
        title: Text(siparisSatirModel.product.name),
        secondary: CachedNetworkImage(
          imageUrl: siparisSatirModel.product.mainImageThumbUrl,
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Barkod: ${siparisSatirModel.product.barcode}"),
            Text(
                "Birim / miktar: ${siparisSatirModel.product.unitCode} / ${siparisSatirModel.product.miktar}"),
            Text("Açıklama: ${siparisSatirModel.product.aciklama}"),
            Text(
                "Eklenecek miktar: ${siparisSatirModel.amount.toStringAsFixed(4)}")
          ],
        ));
  }
}
