import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';

class AdService {
  static final AdService instance = AdService._init();
  AdService._init();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _adsRemoved = false;

  BannerAd? get bannerAd => _adsRemoved ? null : _bannerAd;
  bool get isInterstitialAdReady => !_adsRemoved && _isInterstitialAdReady;

  // Initialize Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Set ads removed status (after in-app purchase)
  void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
    if (removed) {
      _disposeBannerAd();
      _disposeInterstitialAd();
    }
  }

  // Get Banner Ad Unit ID based on platform
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return AppConfig.iosBannerAdUnitId;
    }
    return '';
  }

  // Get Interstitial Ad Unit ID based on platform
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return AppConfig.iosInterstitialAdUnitId;
    }
    return '';
  }

  // Create and load Banner Ad
  void createBannerAd() {
    if (_adsRemoved) return;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) {
          print('Banner ad opened');
        },
        onAdClosed: (ad) {
          print('Banner ad closed');
        },
      ),
    );

    _bannerAd?.load();
  }

  // Create and load Interstitial Ad
  void createInterstitialAd() {
    if (_adsRemoved) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('Interstitial ad loaded');

          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('Interstitial ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('Interstitial ad dismissed');
              _disposeInterstitialAd();
              createInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Interstitial ad failed to show: $error');
              _disposeInterstitialAd();
              createInterstitialAd(); // Try to load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  // Show Interstitial Ad
  void showInterstitialAd() {
    if (_adsRemoved) return;
    
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd?.show();
      _isInterstitialAdReady = false;
    } else {
      print('Interstitial ad is not ready yet');
      createInterstitialAd(); // Try to load ad if not ready
    }
  }

  // Dispose Banner Ad
  void _disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  // Dispose Interstitial Ad
  void _disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  // Dispose all ads
  void dispose() {
    _disposeBannerAd();
    _disposeInterstitialAd();
  }
}
