import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Calculations/manager.dart';
import '../Misc/serialization.dart';
import '../Calculations/manager.dart';
import '../Translation/i18n.dart';
import 'subjectRoute.dart';

void main() {
  // Compatibility.periodPreferences();

  /*switch (Preferences.getPreference("dark_theme", "auto")) {
            case "on":
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                break;
            case "off":
                AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
                break;
            default:
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM);
                } else {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                }
                break;
        }*/

  Manager.init();

  // Serialization.Deserialize();

  /*if (Preferences.getPreference("isFirstRun", "true") == "true") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubjectRoute()),
    );
  }*/

  //Compatibility.init();

  Manager.calculate();

  runApp(MaterialApp(
    localizationsDelegates: const [
      I18nDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: I18nDelegate.supportedLocals,
    home: Scaffold(
      body: HomePage(),
    ),
  ));
}

class HomePage extends StatelessWidget {
  var myMenuItems = <String>[
    'Term',
    'Sort by',
    'Settings',
  ];

  HomePage({Key? key}) : super(key: key);

  void onSelect(item) {
    switch (item) {
      case 'Term':
        print('Home clicked');
        break;
      case 'Sort by':
        Manager.sortAll();
        break;
      case 'Settings':
        print('Setting clicked');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          actions: <Widget>[
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onSelected: (value) {
                //Do something with selected parent value
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 10,
                    child: Text('Item 10'),
                  ),
                  PopupMenuItem<int>(
                    value: 20,
                    child: Text('Item 20'),
                  ),
                  PopupMenuItem<int>(
                    value: 50,
                    child: Text('Item 50'),
                  ),
                  PopupSubMenuItem<int>(
                    title: 'Other items',
                    items: [
                      100,
                      200,
                      300,
                      400,
                      500,
                    ],
                    onSelected: (value) {
                      //Do something with selected child value
                    },
                  ),
                ];
              },
            ),
            /*PopupMenuButton<String>(
              onSelected: onSelect,
              itemBuilder: (BuildContext context) {
                return myMenuItems.map((String choice) {
                  return PopupMenuItem<String>(
                    child: Text(choice),
                    value: choice,
                  );
                }).toList();
              },
            ),*/
          ],
          expandedHeight: 150,
          flexibleSpace: const FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            title: Text(
              "Semester 1",
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            I18n.of(context).average,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          Text(
                            "01",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 0, color: Colors.black, thickness: 1),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SubjectRoute()),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 54,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  Manager.getCurrentTerm().subjects[index].name,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  Manager.getCurrentTerm()
                                      .subjects[index]
                                      .result
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 24)),
                                Icon(
                                  Icons.navigate_next,
                                  size: 24.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
            // Builds 1000 ListTiles
            childCount: Manager.getCurrentTerm().subjects.length,
          ),
        ),
      ],
    );
  }
}
