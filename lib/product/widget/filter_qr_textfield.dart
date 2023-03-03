import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

class FilterQrTextfield extends ConsumerStatefulWidget {
  final Function(String) onChanged;
  const FilterQrTextfield({super.key, required this.onChanged});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FilterQrTextfieldState();
}

class _FilterQrTextfieldState extends ConsumerState<FilterQrTextfield> {
  late final TextEditingController _controller;
  String hint = 'QR Kodu Giriniz';
  late final FocusNode _focusNode;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        hint = '';
      } else {
        hint = 'QR Kodu Giriniz';
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (value) {
        setState(() {
          widget.onChanged(value);
        });
      },
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                })
            : IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                      context: context,
                      onCode: (code) {
                        _controller.text = code ?? "HATA";
                        if (code == null) {
                          _focusNode.requestFocus();
                        }
                        widget.onChanged(code ?? '');
                      });
                },
              ),
      ),
    );
  }
}
