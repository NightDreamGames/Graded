// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";

class SortAction extends StatelessWidget {
  const SortAction({
    super.key,
    required this.sortType,
    this.onTap,
  });

  final int sortType;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.sort),
      tooltip: translations.sort_by,
      onSelected: (value) {
        if (getPreference("sort_mode$sortType") == value) {
          setPreference<int>("sort_direction$sortType", -getPreference<int>("sort_direction$sortType"));
        } else {
          int sortDirection = SortDirection.notApplicable;

          switch (value) {
            case SortMode.name:
              sortDirection = SortDirection.ascending;
            case SortMode.result:
            case SortMode.coefficient:
              sortDirection = SortDirection.descending;
            case SortMode.custom:
              sortDirection = SortDirection.notApplicable;
          }
          setPreference<int>("sort_direction$sortType", sortDirection);
        }

        setPreference<int>("sort_mode$sortType", value);

        Manager.sortAll();
        onTap?.call();
      },
      itemBuilder: (context) {
        return [
          getPopupMenuItem(SortMode.name, translations.name),
          getPopupMenuItem(SortMode.result, translations.result),
          if (sortType == SortType.subject) ...[
            getPopupMenuItem(SortMode.coefficient, translations.coefficient),
            getPopupMenuItem(SortMode.custom, translations.custom),
          ],
        ];
      },
    );
  }

  PopupMenuItem<int> getPopupMenuItem(int value, String title) {
    int sortDirection = getPreference<int>("sort_direction$sortType");
    IconData icon = Icons.check;
    switch (sortDirection) {
      case SortDirection.ascending:
        icon = Icons.arrow_upward;
      case SortDirection.descending:
        icon = Icons.arrow_downward;
      case SortDirection.notApplicable:
        icon = Icons.check;
    }

    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (getPreference<int>("sort_mode$sortType") == value) Icon(icon, size: 20),
        ],
      ),
    );
  }
}

class SettingsAction extends StatelessWidget {
  const SettingsAction({
    super.key,
    this.onReturn,
  });

  final Function()? onReturn;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pushNamed(context, "/settings").then((_) => onReturn?.call()),
      icon: const Icon(
        Icons.settings,
      ),
    );
  }
}

Future<MenuAction?> showMenuActions(BuildContext context, GlobalKey listKey) async {
  RenderBox? box = listKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return Future.value();

  Offset position = box.localToGlobal(Offset(box.size.width, box.size.height / 2));

  return showMenu(
    context: context,
    color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
    position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
    items: [
      PopupMenuItem<MenuAction>(value: MenuAction.edit, child: Text(translations.edit)),
      PopupMenuItem<MenuAction>(value: MenuAction.delete, child: Text(translations.delete)),
    ],
  );
}
