import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';

import '../../../core/models/app_setting_api.dart';
import '../../../localization/generated/l10n.dart';
import '../base_view.dart';
import 'welcome_model.dart';

@RoutePage()
class WelcomeView extends StatelessWidget {
  final Function(bool?) onResult;
  const WelcomeView({super.key, required this.onResult});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => WelcomeViewModel(),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return Scaffold(
          body: Stack(
            children: [
              // 背景漸變
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.7, 1.0], // 黑色佔據 70%，綠色佔據 30%
                  ),
                ),
              ),
              ParticlesFly(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                connectDots: true,
                numberOfParticles: 64,
              ),
              // 前景內容
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 標題
                      Text(
                        S.current.WelcomeTitle,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(5.0, 5.0),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // 說明
                      Text(
                        S.current.WelcomeContent,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(5.0, 5.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Text(
                              S.current.Language,
                              style: const TextStyle(fontSize: 16),
                            ),
                            // 下拉選單
                            DropdownButton<Locale>(
                              value: model.currentLocale,
                              items: const [
                                DropdownMenuItem(
                                  value: Locale('en'),
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: Locale.fromSubtags(
                                    languageCode: 'zh',
                                    scriptCode: 'Hant',
                                    countryCode: 'TW',
                                  ),
                                  child: Text('繁體中文(台灣)'),
                                ),
                              ],
                              onChanged: model.setCurrentLocale,
                            ),
                            Text(
                              S.current.ApiUrl,
                              style: const TextStyle(fontSize: 16),
                            ),
                            // 輸入框
                            TextField(
                              controller: model.textController,
                              decoration: InputDecoration(
                                hintText: 'https://api.meshsight.example',
                                hintStyle: const TextStyle(color: Colors.grey),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                errorText: model.errorMessage,
                                errorStyle: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: model.validateApiUrl,
                            ),
                            TextButton(
                              onPressed: () => model.showOptionsDialog(context),
                              child: Text(S.current.SelectOurDemoApi),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 按鈕 TRUE
                      ElevatedButton.icon(
                        onPressed: () async {
                          await model.setAppSettingApi(
                            AppSettingApi(
                              apiUrl: model.textController.text,
                            ),
                          );
                          onResult(true);
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(S.current.Start),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
