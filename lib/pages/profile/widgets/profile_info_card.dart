import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_field/app_field_types.dart';
import 'package:oolaf_flutted/components/app_field/index.dart';
import 'package:oolaf_flutted/pages/profile/profile_view_data.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    required this.items,
    required this.onItemChanged,
    super.key,
  });

  final List<ProfileInfoItem> items;
  final void Function(ProfileInfoItem item, String value) onItemChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xAAFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '用户信息',
              style: TextStyle(
                color: Color(0xFF1F2329),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ProfileInfoField(
                  item: item,
                  onChanged: (value) => onItemChanged(item, value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoField extends StatelessWidget {
  const ProfileInfoField({
    required this.item,
    required this.onChanged,
    super.key,
  });

  final ProfileInfoItem item;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppField(
      value: item.value,
      label: item.label,
      type: item.key == 'age' ? AppFieldType.digit : AppFieldType.text,
      placeholder: '请输入${item.label}',
      clearable: true,
      clearTrigger: AppFieldClearTrigger.always,
      maxLength: item.key == 'age' ? 2 : null,
      border: false,
      labelWidth: 130,
      inputAlign: AppFieldTextAlign.left,
      onChanged: onChanged,
    );
  }
}
