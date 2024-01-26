// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Dart imports:
import "dart:math" as math;

// Flutter imports:
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// A sliver that insets another sliver by sufficient padding to avoid
/// intrusions by the operating system.
///
/// For example, this will indent the sliver by enough to avoid the status bar
/// at the top of the screen.
///
/// It will also indent the sliver by the amount necessary to avoid The Notch
/// on the iPhone X, or other similar creative physical features of the
/// display.
///
/// When a [minimum] padding is specified, the greater of the minimum padding
/// or the safe area padding will be applied.
///
/// See also:
///
///  * [CustomSafeArea], for insetting box widgets to avoid operating system intrusions.
///  * [SliverPadding], for insetting slivers in general.
///  * [MediaQuery], from which the window padding is obtained.
///  * [dart:ui.FlutterView.padding], which reports the padding from the operating
///    system.
class CustomSliverSafeArea extends StatelessWidget {
  /// Creates a sliver that avoids operating system interfaces.
  const CustomSliverSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    required this.sliver,
  });

  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom side of the screen.
  final bool bottom;

  /// This minimum padding to apply.
  ///
  /// The greater of the minimum padding and the media padding is be applied.
  final EdgeInsets minimum;

  final bool maintainBottomViewPadding;

  /// The sliver below this sliver in the tree.
  ///
  /// The padding on the [MediaQuery] for the [sliver] will be suitably adjusted
  /// to zero out any sides that were avoided by this sliver.
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.paddingOf(context);

    if (maintainBottomViewPadding) {
      padding = padding.copyWith(bottom: MediaQuery.viewPaddingOf(context).bottom);
    }

    assert(debugCheckHasMediaQuery(context));
    return SliverPadding(
      padding: EdgeInsets.only(
        left: math.max(left ? padding.left : 0.0, minimum.left),
        top: math.max(top ? padding.top : 0.0, minimum.top),
        right: math.max(right ? padding.right : 0.0, minimum.right),
        bottom: math.max(bottom ? padding.bottom : 0.0, minimum.bottom),
      ),
      sliver: MediaQuery.removePadding(
        context: context,
        removeLeft: left,
        removeTop: top,
        removeRight: right,
        removeBottom: bottom,
        child: sliver,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty("left", value: left, ifTrue: "avoid left padding"));
    properties.add(FlagProperty("top", value: top, ifTrue: "avoid top padding"));
    properties.add(FlagProperty("right", value: right, ifTrue: "avoid right padding"));
    properties.add(FlagProperty("bottom", value: bottom, ifTrue: "avoid bottom padding"));
  }
}
