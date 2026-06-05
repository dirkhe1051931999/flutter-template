import 'package:flutter/widgets.dart';

class AppVerticalVideoFeedController {
  AppVerticalVideoFeedController({
    int initialPage = 0,
  }) : _pageController = PageController(initialPage: initialPage);

  final PageController _pageController;
  AppVerticalVideoFeedControllerDelegate? _delegate;

  PageController get pageController => _pageController;

  bool get hasClients => _pageController.hasClients;

  int get currentIndex => _delegate?.currentIndex ?? 0;

  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    return _pageController.animateToPage(
      page,
      duration: duration,
      curve: curve,
    );
  }

  void jumpToPage(int page) {
    _pageController.jumpToPage(page);
  }

  Future<void> showNextPage() async {
    await _delegate?.showNextPage();
  }

  Future<void> showPreviousPage() async {
    await _delegate?.showPreviousPage();
  }

  void attach(AppVerticalVideoFeedControllerDelegate delegate) {
    _delegate = delegate;
  }

  void detach(AppVerticalVideoFeedControllerDelegate delegate) {
    if (identical(_delegate, delegate)) {
      _delegate = null;
    }
  }

  void dispose() {
    _pageController.dispose();
  }
}

abstract class AppVerticalVideoFeedControllerDelegate {
  int get currentIndex;

  Future<void> showNextPage();

  Future<void> showPreviousPage();
}
