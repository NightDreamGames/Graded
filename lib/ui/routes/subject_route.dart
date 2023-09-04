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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController maximumController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    gradeController.dispose();
    maximumController.dispose();
    super.dispose();
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
              onPressed: () =>
                  showTestDialog(context, widget.subject, nameController, gradeController, maximumController).then((_) => refreshYearOverview()),
              child: const Icon(Icons.add),
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
                              style: getIconButtonStyle(context),
                            ),
                            IconButton(
                              tooltip: translations.increase,
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () {
                                widget.subject.changeBonus(1);
                                refreshYearOverview();
                              },
                              style: getIconButtonStyle(context),
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
                bottom: false,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: widget.subject.tests.length,
                    (context, index) {
                      final GlobalKey listKey = GlobalKey();
                      return TextRow(
                        listKey: listKey,
                        leading: widget.subject.tests[index].name,
                        trailing: widget.subject.tests[index].toString(),
                        enableEqualLongPress: true,
                        onTap: () async {
                          if (widget.term.isYearOverview) return;

                          showMenuActions<MenuAction>(context, listKey, MenuAction.values, [translations.edit, translations.delete]).then((result) {
                            switch (result) {
                              case MenuAction.edit:
                                showTestDialog(context, widget.subject, nameController, gradeController, maximumController, index: index)
                                    .then((_) => refreshYearOverview());
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
              if (widget.subject.tests.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyWidget(message: translations.no_grades),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
            ],
          );
        },
      ),
    );
  }
}
