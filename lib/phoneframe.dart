import 'package:flutter/material.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;
  final double phoneWidth;
  const PhoneFrame({super.key, required this.child, this.phoneWidth = 390});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth <= phoneWidth;
        final content = ClipRRect(
          borderRadius: BorderRadius.circular(isNarrow ? 0 : 24),
          child: SizedBox(
            width: isNarrow ? double.infinity : phoneWidth,
            child: Material(
              color: Theme.of(context).colorScheme.background,
              child: child,
            ),
          ),
        );
        if (isNarrow) return content;
        return Container(
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: content,
          ),
        );
      },
    );
  }
}
