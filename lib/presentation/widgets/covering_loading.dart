import 'package:flutter/material.dart';
import 'package:getwidget/components/loader/gf_loader.dart';

class CoveringLoading extends StatelessWidget {
  final double? progress;

  const CoveringLoading({
    super.key,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned.fill 會將子元素填滿其父元素的空間
        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: (0.1 * 255).toDouble()),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 320,
                child: Image.asset('assets/images/app_icon.png'),
              ),
            ),
            const SizedBox(height: 32),
            const GFLoader(size: 64),
            // progress 不為空，則顯示以下元素
            if (progress != null) ...[
              const SizedBox(height: 32),
              Text("$progress%"),
            ],
          ],
        )
      ],
    );
  }
}
