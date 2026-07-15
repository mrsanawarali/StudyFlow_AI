import 'package:flutter/material.dart';

class ResponsiveFormContainer extends StatelessWidget {
  final List<Widget> children;
  final double horizontalPadding;
  final double maxWidth;

  const ResponsiveFormContainer({
    Key? key,
    required this.children,
    this.horizontalPadding = 25,
    this.maxWidth = 400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth > maxWidth
              ? maxWidth
              : constraints.maxWidth - horizontalPadding * 2;

          return SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
