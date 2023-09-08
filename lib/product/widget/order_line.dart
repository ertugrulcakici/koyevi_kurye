import 'package:flutter/material.dart';
import 'package:koyevi_kurye/core/utils/extensions/datetime_extensions.dart';
import 'package:koyevi_kurye/product/models/siparis_model.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
                siparisModel.orderDate != null
                    ? Text(
                        "Sipariş tarihi:${siparisModel.orderDate!.toFormattedString()}")
                    : Container(),
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
                          siparisModel.deliveryAddresDetail.mobilePhone !=
                                      null &&
                                  siparisModel.deliveryAddresDetail.mobilePhone!
                                      .isNotEmpty
                              ? Text(
                                  "Telefon no:${siparisModel.deliveryAddresDetail.mobilePhone}")
                              : Container(),
                          siparisModel.deliveryAddresDetail.email != null &&
                                  siparisModel
                                      .deliveryAddresDetail.email!.isNotEmpty
                              ? Text(
                                  "Email:${siparisModel.deliveryAddresDetail.email}")
                              : Container(),
                          Text(
                              "Adres: ${siparisModel.deliveryAddresDetail.address}"),
                          const Divider(),
                          TextButton(
                              onPressed: () {
                                launchUrlString(
                                    siparisModel
                                        .deliveryAddresDetail.googleMapsUrl,
                                    mode: LaunchMode
                                        .externalNonBrowserApplication);
                              },
                              child: const Text("Haritada göster"))
                        ],
                      )
                    ]),
                ExpansionTile(
                  title: const Text("Paket numaraları"),
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: siparisModel.packageList.length,
                        itemBuilder: (context, index) {
                          return Text(siparisModel.packageList[index]);
                        })
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
