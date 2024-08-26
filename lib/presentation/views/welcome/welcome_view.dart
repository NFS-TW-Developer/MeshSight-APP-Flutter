import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';

import '../../../core/app_core.dart';
import '../../../core/models/app_setting_api.dart';
import '../../../core/services/localization_service.dart';
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
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(32),
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
                                items: List.generate(
                                    appLocator<LocalizationService>()
                                        .getSupportedLocales()
                                        .length, (index) {
                                  Locale locale =
                                      appLocator<LocalizationService>()
                                          .getSupportedLocales()[index];
                                  return DropdownMenuItem(
                                    value: appLocator<LocalizationService>()
                                        .getSupportedLocales()[index],
                                    child: Text(
                                      appLocator<LocalizationService>()
                                          .getLanguageName(locale),
                                    ),
                                  );
                                }),
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
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
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
                                onPressed: () =>
                                    model.showOptionsDialog(context),
                                child: Text(S.current.SelectOurDemoApi),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                          label: Text(
                            S.current.AcceptAlertAndStart,
                            style: const TextStyle(
                                color: Colors.white), // 設置文字顏色為白色
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // 警告訊息
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.red,
                          child: Text(
                            S.current.WelcomeAlert1,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 警告訊息
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.red,
                          child: Text(
                            S.current.WelcomeAlert2,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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
