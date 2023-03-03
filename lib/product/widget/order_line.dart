import 'package:flutter/material.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';

class SiparisSatirListTile extends StatefulWidget {
  final SiparisModel siparisModel;
  final Function() callback;
  const SiparisSatirListTile(
      {super.key, required this.siparisModel, required this.callback});

  @override
  State<SiparisSatirListTile> createState() => _SiparisSatirListTileState();
}

class _SiparisSatirListTileState extends State<SiparisSatirListTile> {
  @override
  Widget build(BuildContext context) {
    final SiparisModel siparisModel = widget.siparisModel;
    bool isExpanded = false;
    return InkWell(
        onTap: widget.callback,
        child: Card(
          child: ListTile(
            title: Text("Barkod: ${siparisModel.ficheNo}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("İsim: ${siparisModel.cariName}"),
                Text("Sipariş tarihi:${siparisModel.orderDate}"),
                Text("Ödeme tipi:${siparisModel.paymentTypeName}"),
                Text("Tutar: ${siparisModel.total.toStringAsFixed(2)}"),
                ExpansionTile(
                    title: const Text("Adres detayları"),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                              "Adres sahibi: ${siparisModel.deliveryAddresDetail.adresBasligi}"),
                          siparisModel
                                  .deliveryAddresDetail.mobilePhone.isNotEmpty
                              ? Text(
                                  "Telefon no:${siparisModel.deliveryAddresDetail.mobilePhone}")
                              : Container(),
                          siparisModel.deliveryAddresDetail.email.isNotEmpty
                              ? Text(
                                  "Email:${siparisModel.deliveryAddresDetail.email}")
                              : Container(),
                          Text(
                              "Adres: ${siparisModel.deliveryAddresDetail.address}")
                        ],
                      )
                    ])
              ],
            ),
          ),
        ));
  }
}
