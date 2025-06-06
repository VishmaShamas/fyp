import 'package:fashion_fusion/constants/colors.dart';
import 'package:flutter/material.dart';

class DividerRow extends StatelessWidget {
  const DividerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('or' ,style: TextStyle(
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          color: AppColors.greyColor
        ),),),
        const Expanded(child: Divider())
      ],
    );
  }
}