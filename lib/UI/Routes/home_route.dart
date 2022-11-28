// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../Calculations/manager.dart';
import '../../Calculations/term.dart';
import '../../Translations/translations.dart';
import '../Utilities/hints.dart';
import '../Widgets/list_widgets.dart';
import '../Widgets/misc_widgets.dart';
import '../Widgets/popup_menus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Term term = Manager.getCurrentTerm();

  void rebuild() {
    term = Manager.getCurrentTerm();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: Theme.of(context).brightness != Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarDividerColor: Theme.of(context).colorScheme.surface,
      ));

      if (Manager.deserializationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.storage_error),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            elevation: 3,
          ),
        );

        Manager.deserializationError = false;
      }
    });

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          if (Manager.currentTerm == -1) {
            Manager.currentTerm = Manager.lastTerm;
            rebuild();
          } else {
            exit(0);
          }

          return Future<bool>.value(false);
        },
        child: CustomScrollView(
          primary: true,
          slivers: <Widget>[
            SliverAppBar.large(
              centerTitle: true,
              automaticallyImplyLeading: false,
              flexibleSpace: ScrollingTitle(title: getTitle()),
              actions: <Widget>[
                TermSelector(rebuild: rebuild),
                SortSelector(rebuild: rebuild, type: 0),
              ],
            ),
            ResultRow(
              rebuild,
              result: term.getResult(),
              leading: Text(
                Translations.average,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return TextRow(
                    leading: term.subjects[index].name,
                    trailing: term.subjects[index].getResult(),
                    icon: Icons.navigate_next,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/subject",
                        arguments: index,
                      ).then((_) => rebuild());
                    },
                  );
                },
                addAutomaticKeepAlives: true,
                childCount: term.subjects.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
