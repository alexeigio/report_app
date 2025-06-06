import 'package:flutter/material.dart';
import 'package:report_app/screens/auth/login_screen.dart';
import 'package:report_app/utils/navigation_helpers.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: "Report incidents in seconds",
      description:
          "Accidents, thefts, harassment or any other community issues. Make them visible and actionable.",
      imageAsset: 'assets/images/onboarding/01.jpg',
      bottomHeightFactor: 0.4,
    ),
    _OnboardingPageData(
      title: "Check incidents by date",
      description:
          "Easily explore reports in your area filtered by day. Stay up to date with your surroundings.",
      imageAsset: 'assets/images/onboarding/02.jpg',
      bottomHeightFactor: 0.4,
    ),
    _OnboardingPageData(
      title: "Take part in your community's safety",
      description:
          "Your report can help prevent future incidents. Contribute to building a safer environment.",
      imageAsset: 'assets/images/onboarding/03.jpg',
      bottomHeightFactor: 0.45,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Precargar las imágenes una vez renderizado el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final page in _pages) {
        precacheImage(AssetImage(page.imageAsset), context);
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      fadeTransitionTo(context, LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Stack(
            children: [
              // Imagen ocupa 65% del alto
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      flex: 13,
                      child: Image.asset(
                        page.imageAsset,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        gaplessPlayback: true, // ✅ evita parpadeo
                      ),
                    ),
                    const Spacer(flex: 7),
                  ],
                ),
              ),
              // Contenedor blanco encima parcialmente de la imagen
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height:
                        MediaQuery.of(context).size.height *
                        page.bottomHeightFactor,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Indicadores
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (dotIndex) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentIndex == dotIndex
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _currentIndex == _pages.length - 1
                                    ? "Get Started"
                                    : "Next",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String imageAsset;
  final double bottomHeightFactor;

  _OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.bottomHeightFactor,
  });
}
