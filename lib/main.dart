import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdfconverter/features/pdf/data/repositories/advancedExcelService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/excelPdfService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/excelService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/imagePdfService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/ocrService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfEditService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfImageService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfReaderService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfSignatureService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/wordReaderService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/wordService.dart';
import 'package:pdfconverter/features/pdf/domain/repositories/pdfRepositoryImpl.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:pdfconverter/features/pdf/presentation/screens/homeScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  AdManager.instance.loadInterstitialAd();
  AdManager.instance.loadRewardedAd();
  AdManager.instance.loadBannerAd();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('zh'),
        Locale('es'),
        Locale('fr'),
        Locale('ru'),
        Locale('pt'),
        Locale('ja'),
        Locale('hi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app_title'.tr(),
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: BlocProvider(
        create: (_) => PdfBloc(
          PdfRepositoryImpl(
            OcrService(),
            PdfService(),
            WordService(),
            PdfReaderService(),
            WordReaderService(),
            ExcelService(),
            ImagePdfService(),
            PdfImageService(),
            ExcelPdfService(),
            PdfEditService(),
            AdvancedExcelService(),
            PdfSignatureService(),
          ),
        ),
        child: const HomeScreen(),
      ),
    );
  }
}

// ----------------------------
// AD MANAGER
// ----------------------------
class AdManager {
  AdManager._privateConstructor();
  static final AdManager instance = AdManager._privateConstructor();

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  void loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => _isBannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  Widget getBannerWidget() {
    if (_isBannerLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox(height: 50);
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  DateTime? _lastInterstitialTime;
  int _actionCount = 0;

  void loadInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
        },
        onAdFailedToLoad: (error) => _isInterstitialLoaded = false,
      ),
    );
  }

  void showInterstitialAd({int frequency = 3, int cooldownSeconds = 90}) {
    _actionCount++;
    if (_lastInterstitialTime != null) {
      final diff = DateTime.now().difference(_lastInterstitialTime!);
      if (diff.inSeconds < cooldownSeconds) return;
    }
    if (_actionCount % frequency != 0) return;
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _lastInterstitialTime = DateTime.now();
      _isInterstitialLoaded = false;
    }
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  void loadRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedLoaded = false;
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
        },
        onAdFailedToLoad: (error) => _isRewardedLoaded = false,
      ),
    );
  }

  void showRewardedAd(VoidCallback onRewarded) {
    if (_isRewardedLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedAd();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) => onRewarded(),
      );
      _isRewardedLoaded = false;
    }
  }
}
