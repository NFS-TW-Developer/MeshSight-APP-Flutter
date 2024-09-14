import 'package:flutter/material.dart';

import '../../core/models/page_error_data.dart';
import '../../localization/generated/l10n.dart';

class CoveringError extends StatelessWidget {
  final PageErrorData? pageErrorData;
  final String? pageErrorMessage;
  final Function()? retryFunction;

  const CoveringError({
    super.key,
    this.pageErrorData,
    this.pageErrorMessage,
    this.retryFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned.fill 會將子元素填滿其父元素的空間
        Positioned.fill(
          child: Container(
            color: Colors.grey[200],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity, // 讓元素填滿其父元素的左右空間
              child: Icon(
                Icons.sentiment_very_dissatisfied,
                size: 160,
              ),
            ),
            // error 不為空，則顯示以下元素
            if (pageErrorData != null || pageErrorMessage != null) ...[
              const SizedBox(height: 32),
              Center(
                child: Text(
                  S.current.PageLoadErrorHint1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "${S.current.PageLoadErrorHint2}\n${S.current.PageLoadErrorHint3}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
              // retryFunction 不為空，則顯示以下元素
              if (retryFunction != null) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: retryFunction,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    S.current.Retry,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
              if (pageErrorData != null) ...[
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "Error: ${pageErrorData?.code}; ${pageErrorData?.description}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if(pageErrorMessage!=null)...[
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "Error: $pageErrorMessage",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]
            ],
            const SizedBox(height: 32),
          ],
        )
      ],
    );
  }
}
