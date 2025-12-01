import 'package:flutter/widgets.dart';

// Global keys for MainScreen and TrackingPage. These are typed as GlobalKey
// with no private state type to avoid circular imports; we call methods via
// dynamic on the state objects.
final GlobalKey mainScreenKey = GlobalKey();
final GlobalKey trackingPageKey = GlobalKey();

/// Switch the main tab in the `MainScreen` (index: 0=Home,1=Search,2=Tracking,3=Profile)
void switchMainTab(int index) {
  final state = mainScreenKey.currentState as dynamic;
  try {
    state?.setTab(index);
  } catch (_) {
    // ignore if not available
  }
}

/// Open the Tracking tab and instruct the TrackingPage to show a specific subview
/// Subpage values: 'tracking' (default), 'statistics', 'edit'
void openTrackingSubpage(String subpage) {
  // First ensure the MainScreen shows the tracking tab
  switchMainTab(2);
  final tstate = trackingPageKey.currentState as dynamic;
  try {
    tstate?.setActiveSub(subpage);
  } catch (_) {
    // ignore if not available
  }
}
