// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../calculations/calculator.dart';
import '../../calculations/manager.dart';
import '../../calculations/term.dart';
import '../../translations/translations.dart';
import '../utilities/hints.dart';
import '../widgets/list_widgets.dart';
import '../widgets/misc_widgets.dart';
import '../widgets/popup_menus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
            content: Text(Translations.storage_error),
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
                actionAmount: 2,
              ),
              actions: [
                TermSelector(rebuild: rebuild),
                SortSelector(rebuild: rebuild, type: SortType.subject, showSettings: true),
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
                  Manager.currentTerm != -1 ? Translations.average : Translations.yearly_average,
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
                  addAutomaticKeepAlives: true,
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
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        ),
      ),
    );
  }
}
