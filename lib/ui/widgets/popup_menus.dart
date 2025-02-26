// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/l10n/translations.dart";
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
        if (!getCurrentYear().hasBeenSortedCustom && value == SortMode.custom) {
          getCurrentYear().subjects = Calculator.sortObjects(getCurrentYear().subjects, sortType: SortType.subject);
          for (final subject in getCurrentYear().subjects) {
            subject.children = Calculator.sortObjects(subject.children, sortType: SortType.subject);
          }
          getCurrentYear().hasBeenSortedCustom = true;
        }

        if (getPreference("sortMode$sortType") == value) {
          setPreference<int>("sortDirection$sortType", -getPreference<int>("sortDirection$sortType"));
        } else {
          final int sortDirection = switch (value) {
            SortMode.result || SortMode.weight => SortDirection.descending,
            SortMode.name || SortMode.timestamp || SortMode.custom || _ => SortDirection.ascending,
          };

          setPreference<int>("sortDirection$sortType", sortDirection);
        }

        setPreference<int>("sortMode$sortType", value);

        onTap?.call();
      },
      itemBuilder: (context) {
        return [
          getPopupMenuItem(SortMode.name, translations.name),
          getPopupMenuItem(SortMode.result, translations.result),
          if (sortType == SortType.subject) ...[
            getPopupMenuItem(SortMode.weight, translations.coefficientOne),
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
    final int sortDirection = getPreference<int>("sortDirection$sortType");
    final IconData icon = switch (sortDirection) {
      SortDirection.ascending => Icons.arrow_upward,
      SortDirection.descending => Icons.arrow_downward,
      _ => Icons.check,
    };

    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (getPreference<int>("sortMode$sortType") == value) Icon(icon, size: 20),
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
