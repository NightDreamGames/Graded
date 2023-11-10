// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class SubjectRoute extends StatefulWidget {
  const SubjectRoute({
    super.key,
    required this.term,
    required this.subject,
    this.parent,
  });

  final Term term;
  final Subject subject;
  final Subject? parent;

  @override
  State<SubjectRoute> createState() => _SubjectRouteState();
}

class _SubjectRouteState extends State<SubjectRoute> {
  double fabRotation = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      setState(() {
        fabRotation += 0.5;
      });
    });
  }

  void rebuild() {
    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview();
    rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !widget.term.isYearOverview
          ? FloatingActionButton(
              tooltip: translations.add_test,
              onPressed: () {
                setState(() {
                  fabRotation += 0.5;
                });
                showTestDialog(context, widget.subject).then((_) => refreshYearOverview());
              },
              child: SpinningIcon(
                icon: Icons.add,
                rotation: fabRotation,
              ),
            )
          : null,
      body: Builder(
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverSafeArea(
                top: false,
                bottom: false,
                sliver: ResultRow(
                  result: widget.subject.getResult(),
                  preciseResult: widget.subject.getResult(precise: true),
                  leading: !widget.term.isYearOverview
                      ? Row(
                          children: [
                            SizedBox(
                              width: 100 * MediaQuery.textScaleFactorOf(context),
                              child: Text(
                                "${translations.bonus} ${widget.subject.bonus}${widget.subject.bonus < 0 ? "" : "  "}",
                                overflow: TextOverflow.visible,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 8)),
                            IconButton(
                              tooltip: translations.decrease,
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () {
                                widget.subject.changeBonus(-1);
                                refreshYearOverview();
                              },
                              style: getTonalIconButtonStyle(context),
                            ),
                            IconButton(
                              tooltip: translations.increase,
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () {
                                widget.subject.changeBonus(1);
                                refreshYearOverview();
                              },
                              style: getTonalIconButtonStyle(context),
                            ),
                          ],
                        )
                      : Text(
                          translations.yearly_average,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: widget.subject.tests.length,
                    (context, index) {
                      final GlobalKey listKey = GlobalKey();
                      return TextRow(
                        listKey: listKey,
                        leadingText: widget.subject.tests[index].name,
                        trailingText: widget.subject.tests[index].toString(),
                        enableEqualLongPress: true,
                        onTap: () async {
                          if (widget.term.isYearOverview) return;

                          showMenuActions<MenuAction>(context, listKey, MenuAction.values, [translations.edit, translations.delete]).then((result) {
                            switch (result) {
                              case MenuAction.edit:
                                showTestDialog(context, widget.subject, index: index).then((_) => refreshYearOverview());
                              case MenuAction.delete:
                                widget.subject.removeTest(index);
                                refreshYearOverview();
                              default:
                                break;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              if (widget.subject.tests.isEmpty) SliverEmptyWidget(message: translations.no_grades),
              const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
            ],
          );
        },
      ),
    );
  }
}
