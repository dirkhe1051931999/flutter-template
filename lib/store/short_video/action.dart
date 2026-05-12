import 'package:oolaf_flutted/store/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';

class ShortVideoSetLoadingAction extends AppAction {
  const ShortVideoSetLoadingAction(this.isLoading);

  final bool isLoading;
}

class ShortVideoSetItemsAction extends AppAction {
  const ShortVideoSetItemsAction(this.items);

  final List<ShortVideoItem> items;
}

class ShortVideoSetActiveIndexAction extends AppAction {
  const ShortVideoSetActiveIndexAction(this.activeIndex);

  final int activeIndex;
}
