import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/template_item.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/template_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TemplateListView extends StatelessWidget {
  const TemplateListView({
    super.key,
    required this.scrollController,
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  final ScrollController scrollController;
  final List<TemplateItem> items;
  final String? selectedId;
  final ValueChanged<TemplateItem> onSelect;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No templates available',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return TemplateTile(
          item: item,
          isSelected: item.id == selectedId,
          onTap: () => onSelect(item),
        );
      },
    );
  }
}
