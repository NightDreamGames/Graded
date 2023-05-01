// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../calculations/calculator.dart';
import '../../calculations/manager.dart';
import '../../localization/translations.dart';
import '../../misc/storage.dart';
import '../utilities/misc_utilities.dart';

class TermSelector extends StatelessWidget {
  const TermSelector({Key? key, required this.rebuild}) : super(key: key);

  final Function rebuild;

  @override
  Widget build(BuildContext context) {
    return getPreference<int>("term") != 1
        ? PopupMenuButton<String>(
            color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
            icon: Icon(Icons.access_time_outlined, color: Theme.of(context).colorScheme.secondary),
            tooltip: translations.select_school_term,
            itemBuilder: (BuildContext context) {
              List<String> items = [];

              switch (getPreference<int>("term")) {
                case 2:
                  items = [
                    "${translations.semester} 1",
                    "${translations.semester} 2",
                  ];
                  break;
                case 3:
                  items = [
                    "${translations.trimester} 1",
                    "${translations.trimester} 2",
                    "${translations.trimester} 3",
                  ];
                  break;
              }

              if (getPreference<int>("validated_year") == 1) {
                items.add(translations.exams);
              }
              items.add(translations.year_overview);

              List<PopupMenuEntry<String>> entries = [];
              for (int i = 0; i < items.length; i++) {
                entries.add(PopupMenuItem<String>(
                  value: i.toString(),
                  onTap: () {
                    if (i == getPreference<int>("term") + (getPreference<int>("validated_year") == 1 ? 1 : 0)) {
                      Manager.lastTerm = Manager.currentTerm;
                      Manager.currentTerm = -1;
                    } else {
                      Manager.currentTerm = i;
                    }

                    rebuild();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(items[i]),
                      if (Manager.currentTerm == i || (Manager.currentTerm == -1 && i == items.length - 1)) const Icon(Icons.check, size: 20),
                    ],
                  ),
                ));
              }

              return entries;
            },
          )
        : Container();
  }
}

class SortSelector extends StatelessWidget {
  const SortSelector({
    Key? key,
    required this.rebuild,
    required this.type,
    this.showSettings = false,
  }) : super(key: key);

  final Function rebuild;
  final int type;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<dynamic>(
      color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.secondary),
      tooltip: translations.more_options,
      onSelected: (value) {
        if (value == "settings") {
          Navigator.pushNamed(context, "/settings").then((_) => rebuild());
        }
      },
      itemBuilder: (context) {
        return [
          PopupSubMenuItem<int>(
            title: translations.sort_by,
            items: [
              getPopupSubMenuItem(SortMode.name, translations.name),
              getPopupSubMenuItem(SortMode.result, translations.result),
              if (type == SortType.subject) ...[
                getPopupSubMenuItem(SortMode.coefficient, translations.coefficient),
                getPopupSubMenuItem(SortMode.custom, translations.custom),
              ]
            ],
            onSelected: (value) {
              if (getPreference("sort_mode$type") == value) {
                setPreference<int>("sort_direction$type", -getPreference("sort_direction$type"));
              } else {
                int direction = 0;

                switch (value) {
                  case SortMode.name:
                    direction = 1;
                    break;
                  case SortMode.result:
                  case SortMode.coefficient:
                    direction = -1;
                    break;
                  case SortMode.custom:
                  default:
                    direction = 0;
                    break;
                }
                setPreference<int>("sort_direction$type", direction);
              }

              setPreference<int>("sort_mode$type", value);

              Manager.sortAll();
              rebuild();
            },
          ),
          if (showSettings)
            PopupMenuItem<String>(
              value: "settings",
              child: Text(translations.settings),
            ),
        ];
      },
    );
  }

  PopupMenuItem<int> getPopupSubMenuItem(int value, String title) {
    int sortDirection = getPreference<int>("sort_direction$type");
    IconData icon = Icons.check;
    switch (sortDirection) {
      case 0:
        icon = Icons.check;
        break;
      case 1:
        icon = Icons.arrow_upward;
        break;
      case -1:
        icon = Icons.arrow_downward;
        break;
    }

    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (getPreference<int>("sort_mode$type") == value) Icon(icon, size: 20),
        ],
      ),
    );
  }
}

class PopupSubMenuItem<T> extends PopupMenuEntry<T> {
  const PopupSubMenuItem({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
  });

  final String title;
  final List<PopupMenuEntry<T>> items;
  final Function(T) onSelected;

  @override
  double get height => kMinInteractiveDimension;

  @override
  bool represents(T? value) => false;

  @override
  State createState() => _PopupSubMenuState<T>();
}

class _PopupSubMenuState<T> extends State<PopupSubMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
      tooltip: widget.title,
      onCanceled: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      onSelected: (T value) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        widget.onSelected.call(value);
      },
      offset: const Offset(0, -8),
      itemBuilder: (context) {
        return widget.items;
      },
      child: IgnorePointer(
        child: PopupMenuItem(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
              ),
              Icon(Icons.arrow_right, size: 24.0, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

Future<MenuAction?> showListMenu(BuildContext context, GlobalKey listKey) async {
  RenderBox box = listKey.currentContext?.findRenderObject() as RenderBox;
  Offset position = box.localToGlobal(Offset(box.size.width, box.size.height / 2));

  return await showMenu(
    context: context,
    color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
    position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
    items: [
      PopupMenuItem<MenuAction>(value: MenuAction.edit, child: Text(translations.edit)),
      PopupMenuItem<MenuAction>(value: MenuAction.delete, child: Text(translations.delete)),
    ],
  );
}
