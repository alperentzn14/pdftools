import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GradientAdBanner extends StatefulWidget {
  final String adUnitId;
  const GradientAdBanner({super.key, required this.adUnitId});

  @override
  State<GradientAdBanner> createState() => _GradientAdBannerState();
}

class _GradientAdBannerState extends State<GradientAdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (_isLoading || _isAdLoaded) return;
    _isLoading = true;

    late final BannerAd ad;
    ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isAdLoaded = true;
            _isLoading = false;
            _bannerAd = ad;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Ad failed to load: $err');
          _isLoading = false;
          ad.dispose();
        },
      ),
    );

    try {
      await ad.load();
    } catch (_) {
      _isLoading = false;
      ad.dispose();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            _isAdLoaded && _bannerAd != null
                ? AdWidget(ad: _bannerAd!)
                : const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Your Ad Here",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
