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
            case SortMode.timestamp:
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
            getPopupMenuItem(SortMode.coefficient, translations.coefficientOne),
            getPopupMenuItem(SortMode.custom, translations.custom),
          ],
          if (sortType == SortType.test) ...[
            getPopupMenuItem(SortMode.timestamp, translations.date),
          ],
        ];
      },
    );
  }

  PopupMenuItem<int> getPopupMenuItem(int value, String title) {
    final int sortDirection = getPreference<int>("sort_direction$sortType");
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
      tooltip: translations.settings,
      onPressed: () => Navigator.pushNamed(context, "/settings").then((_) => onReturn?.call()),
      icon: const Icon(
        Icons.settings,
      ),
    );
  }
}

Future<T?> showMenuActions<T>(BuildContext context, List<T> actionsEnum, List<String> translations) async {
  final RenderBox? box = context.findRenderObject() as RenderBox?;
  if (box == null) return Future.value();

  final Offset position = box.localToGlobal(Offset(box.size.width, box.size.height / 4));

  return showMenu(
    context: context,
    position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
    items: [
      for (final T action in actionsEnum) PopupMenuItem<T>(value: action, child: Text(translations[actionsEnum.indexOf(action)])),
    ],
  );
}
