import 'package:flutter/cupertino.dart';

class AppCupertinoButton extends StatelessWidget {
  const AppCupertinoButton({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      minimumSize: Size.zero,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: child,
    );
  }
}
