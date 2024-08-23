import 'package:flutter/material.dart';

class BaseImage extends StatelessWidget {
  final ImageProvider image;
  final BoxFit? fit;
  final Function? onFinished;
  final Function? onErrored;

  const BaseImage({
    super.key,
    required this.image,
    this.fit,
    this.onFinished,
    this.onErrored,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          onFinished?.call();
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        onErrored?.call();
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 50),
              const Text('Load image failed'),
              ElevatedButton(
                onPressed: () {
                  (context as Element).markNeedsBuild();
                },
                child: const Text('Reload'),
              ),
            ],
          ),
        );
      },
    );
  }
}
