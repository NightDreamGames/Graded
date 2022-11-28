// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:gradely/Calculations/manager.dart';
import 'package:gradely/Translations/translations.dart';
import '../../Misc/storage.dart';

class TermSelector extends StatelessWidget {
  const TermSelector({Key? key, required this.rebuild}) : super(key: key);

  final Function rebuild;

  @override
  Widget build(BuildContext context) {
    return Manager.maxTerm != 1
        ? PopupMenuButton<String>(
            color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
            icon: Icon(Icons.access_time_outlined, color: Theme.of(context).colorScheme.secondary),
            tooltip: Translations.select_term,
            itemBuilder: (BuildContext context) {
              List<String> a = [];

              switch (Manager.maxTerm) {
                case 2:
                  a = [
                    Translations.semester_1,
                    Translations.semester_2,
                    Translations.year_overview,
                  ];
                  break;
                case 3:
                  a = [
                    Translations.trimester_1,
                    Translations.trimester_2,
                    Translations.trimester_3,
                    Translations.year_overview,
                  ];
                  break;
              }

              List<PopupMenuEntry<String>> entries = [];
              for (int i = 0; i < a.length; i++) {
                entries.add(PopupMenuItem<String>(
                  value: i.toString(),
                  onTap: () {
                    if (i == Manager.maxTerm) {
                      Manager.lastTerm = Manager.currentTerm;
                      Manager.currentTerm = -1;
                    } else {
                      Manager.currentTerm = i;
                    }

                    rebuild();
                  },
                  child: Text(a[i]),
                ));
              }

              return entries;
            },
          )
        : Container();
  }
}

class SortSelector extends StatelessWidget {
  const SortSelector({Key? key, required this.rebuild, required this.type}) : super(key: key);

  final Function rebuild;
  final int type;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.secondary),
      tooltip: Translations.more_options,
      onSelected: (value) {
        if (value == "settings") {
          Navigator.pushNamed(context, "/settings").then((_) => rebuild());
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> popupList = [
          PopupSubMenuItem<String>(
            title: Translations.sort_by,
            items: type == 0
                ? [Translations.az, Translations.grade, Translations.coefficient]
                : type == 1
                    ? [Translations.az, Translations.grade]
                    : [Translations.az, Translations.coefficient],
            onSelected: (value) {
              int sortMode = 0;

              if (value == Translations.az) {
                sortMode = 0;
              } else if (value == Translations.grade) {
                sortMode = 1;
              } else if (value == Translations.coefficient) {
                sortMode = 2;
              }

              Storage.setPreference<int>("sort_mode${type + 1}", sortMode);

              Manager.sortAll();

              rebuild();
            },
          ),
        ];

        if (type == 0) {
          popupList.add(PopupMenuItem<String>(
            value: "settings",
            child: Text(Translations.settings),
          ));
        }

        return popupList;
      },
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
  final List<T> items;
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
      offset: Offset.zero,
      itemBuilder: (BuildContext context) {
        return widget.items
            .map(
              (item) => PopupMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ),
            )
            .toList();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 12.0, bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Text(
                widget.title,
                style: PopupMenuTheme.of(context).textStyle ?? Theme.of(context).textTheme.subtitle1!,
              ),
            ),
            Icon(Icons.arrow_right, size: 24.0, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

Future<String?> showListMenu(BuildContext context, GlobalKey listKey) async {
  RenderBox box = listKey.currentContext?.findRenderObject() as RenderBox;
  Offset position = box.localToGlobal(Offset(box.size.width, box.size.height / 2));

  return await showMenu(
    context: context,
    color: ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2),
    position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
    items: [
      PopupMenuItem<String>(value: "edit", child: Text(Translations.edit)),
      PopupMenuItem<String>(value: "delete", child: Text(Translations.delete)),
    ],
  );
}
