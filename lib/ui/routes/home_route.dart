// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/translations.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.term,
  });

  final Term term;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void rebuild() {
    setState(() {});
  }

  void refreshYearOverview() {
    Manager.refreshYearOverview();
    rebuild();
  }

  //TODO Fix SliverFillRemaining filling too much of the screen
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
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
                  result: widget.term.getResult(),
                  preciseResult: widget.term.getResult(precise: true),
                  leading: Text(
                    widget.term.isYearOverview ? translations.yearly_average : translations.average,
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
                    childCount: widget.term.subjects.length,
                    (context, index) {
                      if (!widget.term.subjects[index].isGroup) {
                        return TextRow(
                          leading: widget.term.subjects[index].name,
                          trailing: widget.term.subjects[index].getResult(),
                          trailingIcon: Icons.navigate_next,
                          onTap: () {
                            Navigator.pushNamed(context, "/subject", arguments: [null, widget.term.subjects[index]])
                                .then((_) => refreshYearOverview());
                          },
                        );
                      } else {
                        return GroupRow(
                          leading: widget.term.subjects[index].name,
                          trailing: widget.term.subjects[index].getResult(),
                          children: [
                            for (int i = 0; i < widget.term.subjects[index].children.length; i++)
                              TextRow(
                                leading: widget.term.subjects[index].children[i].name,
                                trailing: widget.term.subjects[index].children[i].getResult(),
                                trailingIcon: Icons.navigate_next,
                                padding: const EdgeInsets.only(left: 32, right: 24),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/subject",
                                    arguments: [widget.term.subjects[index], widget.term.subjects[index].children[i]],
                                  ).then((_) => refreshYearOverview());
                                },
                                isChild: true,
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
              if (widget.term.subjects.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyWidget(message: translations.no_subjects),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          );
        },
      ),
    );
  }
}
