import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_field/app_field_types.dart';
import 'package:oolaf_flutted/components/app_field/index.dart';
import 'package:oolaf_flutted/utils/aphelios_client_api_key_storage.dart';

Future<String?> requireClientPostApiKey(BuildContext context) async {
  final stored = await ApheliosClientApiKeyStorage.load();
  if (stored.isNotEmpty) {
    return stored;
  }
  if (!context.mounted) {
    return null;
  }

  var input = '';
  return showCupertinoDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => CupertinoAlertDialog(
        title: const Text('输入 Client API Key'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: AppField(
            label: 'Key',
            type: AppFieldType.password,
            value: input,
            placeholder: 'x-oolaf-client-key',
            clearable: true,
            autofocus: true,
            onChanged: (value) => setState(() => input = value),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: input.trim().isEmpty
                ? null
                : () async {
                    final value = input.trim();
                    await ApheliosClientApiKeyStorage.save(value);
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop(value);
                    }
                  },
            child: const Text('保存'),
          ),
        ],
      ),
    ),
  );
}
