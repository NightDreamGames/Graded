// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/utilities/hints.dart";
import "package:graded/ui/widgets/list_widgets.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Term term = Manager.getCurrentTerm();
  bool resultTapped = false;

  void rebuild() {
    term = Manager.getCurrentTerm();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Manager.deserializationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations.storage_error),
          ),
        );

        Manager.deserializationError = false;
      }
    });

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          bool exit = true;
          if (Manager.currentTerm == -1) {
            Manager.currentTerm = Manager.lastTerm;
            rebuild();
            exit = false;
          }
          return Future<bool>.value(exit);
        },
        child: CustomScrollView(
          primary: true,
          slivers: [
            SliverAppBar.large(
              title: AppBarTitle(
                title: getTitle(),
              ),
              actions: [
                TermSelector(rebuild: rebuild),
                SortSelector(rebuild: rebuild, sortType: SortType.subject, showSettings: true),
              ],
              automaticallyImplyLeading: false,
            ),
            SliverSafeArea(
              top: false,
              bottom: false,
              sliver: ResultRow(
                result: term.getResult(precise: resultTapped),
                onResultTap: () {
                  resultTapped = !resultTapped;
                  rebuild();
                },
                leading: Text(
                  Manager.currentTerm != -1 ? translations.average : translations.yearly_average,
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
                  childCount: term.subjects.length,
                  (context, index) {
                    if (!term.subjects[index].isGroup) {
                      return TextRow(
                        leading: term.subjects[index].name,
                        trailing: term.subjects[index].getResult(),
                        trailingIcon: Icons.navigate_next,
                        onTap: () => Navigator.pushNamed(context, "/subject", arguments: [index, null]).then((_) => rebuild()),
                      );
                    } else {
                      return GroupRow(
                        leading: term.subjects[index].name,
                        trailing: term.subjects[index].getResult(),
                        children: [
                          for (int i = 0; i < term.subjects[index].children.length; i++)
                            TextRow(
                              leading: term.subjects[index].children[i].name,
                              trailing: term.subjects[index].children[i].getResult(),
                              trailingIcon: Icons.navigate_next,
                              padding: const EdgeInsets.only(left: 32, right: 24),
                              onTap: () => Navigator.pushNamed(context, "/subject", arguments: [index, i]).then((_) => rebuild()),
                              isChild: true,
                            ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
            if (term.subjects.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyWidget(message: translations.no_subjects),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        ),
      ),
    );
  }
}
