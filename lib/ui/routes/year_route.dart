// Flutter imports:
import "package:flutter/material.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/year.dart";
import "package:graded/localization/translations.dart";
import "package:graded/main.dart";
import "package:graded/misc/enums.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/easy_form_field.dart";
import "package:graded/ui/widgets/misc_widgets.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class YearRoute extends StatefulWidget {
  const YearRoute({super.key});

  @override
  State<YearRoute> createState() => _YearRouteState();
}

class _YearRouteState extends State<YearRoute> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: translations.add_year,
        onPressed: () => Navigator.pushNamed(context, "/setup"),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text(
          translations.manage_years,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
        toolbarHeight: 64,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Manager.years.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                primary: true,
                itemCount: Manager.years.length,
                itemBuilder: (context, index) {
                  final Year year = Manager.years[index];
                  final GlobalKey key = GlobalKey();
                  return Column(
                    children: [
                      ListTile(
                        key: key,
                        title: Text(
                          year.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (Manager.currentYear == index)
                              const Padding(
                                padding: EdgeInsets.only(right: 32),
                                child: Icon(Icons.check),
                              ),
                            Text(
                              Calculator.format(year.result),
                              overflow: TextOverflow.visible,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        onLongPress: () {
                          showPopupActions(context, key, index, year);
                        },
                        onTap: () {
                          showPopupActions(context, key, index, year);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(),
                      ),
                    ],
                  );
                },
              )
            : EmptyWidget(message: translations.no_items),
      ),
    );
  }

  void showPopupActions(BuildContext context, GlobalKey key, int index, Year year) {
    showMenuActions<YearAction>(
      context,
      key,
      YearAction.values,
      [translations.select, translations.edit, translations.delete],
    ).then((result) {
      switch (result) {
        case YearAction.select:
          Manager.changeYear(index);
          Navigator.pushAndRemoveUntil(context, createRoute(const RouteSettings(name: "/")), (_) => false);
        case YearAction.edit:
          nameController.text = year.name;

          showDialog(
            context: context,
            builder: (context) => EasyDialog(
              title: translations.edit_year,
              icon: Icons.edit,
              child: EasyFormField(
                controller: nameController,
                label: translations.name,
                autofocus: true,
              ),
            ),
          ).then((value) {
            year.name = nameController.value.text;
          });
        case YearAction.delete:
          Manager.years.removeAt(index);

          if (Manager.years.isEmpty) {
            Navigator.of(context).pushNamedAndRemoveUntil("/setup", (_) => false);
          } else if (index == Manager.currentYear || Manager.currentYear == Manager.years.length) {
            Manager.changeYear(Manager.years.length - 1);
          }
        default:
          break;
      }
      rebuild();
    });
  }
}
