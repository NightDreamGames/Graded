// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:showcaseview/showcaseview.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/term.dart';
import '../../Misc/storage.dart';
import '../../Translations/translations.dart';
import 'dialogs.dart';
import 'popup_menus.dart';

class TextRow extends StatelessWidget {
  const TextRow({
    Key? key,
    required this.leading,
    required this.trailing,
    this.leadingIcon,
    this.trailingIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.listKey,
    this.onTap,
    this.isChild = false,
    this.horizontalTitleGap = 16,
  }) : super(key: key);

  final String leading;
  final String trailing;
  final Widget? leadingIcon;
  final IconData? trailingIcon;
  final EdgeInsets padding;
  final Key? listKey;
  final Function()? onTap;
  final bool isChild;
  final double horizontalTitleGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isChild)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
        ListTile(
          horizontalTitleGap: horizontalTitleGap,
          key: listKey,
          onTap: onTap,
          contentPadding: padding,
          leading: leadingIcon,
          title: Text(
            leading,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
              if (trailingIcon != null) ...[
                const Padding(padding: EdgeInsets.only(right: 24)),
                Icon(
                  trailingIcon,
                  size: 24.0,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ),
        if (!isChild)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
      ],
    );
  }
}

class GroupRow extends StatefulWidget {
  const GroupRow({Key? key, required this.children, required this.leading, required this.trailing}) : super(key: key);

  final String leading;
  final String trailing;
  final List<Widget> children;

  @override
  State<GroupRow> createState() => _GroupRowState();
}

class _GroupRowState extends State<GroupRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.leading,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.trailing,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 24)),
                  AnimatedRotation(
                    turns: _isExpanded ? .5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 24.0,
                      color: _isExpanded ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            onExpansionChanged: (value) {
              setState(() {
                _isExpanded = value;
              });
            },
            childrenPadding: const EdgeInsets.only(left: 16),
            children: widget.children,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
      ],
    );
  }
}

class ResultRow extends StatelessWidget {
  const ResultRow({Key? key, required this.result, required this.leading}) : super(key: key);

  final String result;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  leading,
                  Text(
                    result,
                    style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              thickness: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectTile extends StatefulWidget {
  const SubjectTile({
    Key? key,
    required this.s,
    required this.listKey,
    required this.index1,
    this.index2 = 0,
    required this.reorderIndex,
    required this.rebuild,
    required this.nameController,
    required this.coeffController,
  }) : super(key: key);

  final Subject s;
  final GlobalKey listKey;
  final int index1;
  final int index2;
  final int reorderIndex;
  final Function rebuild;
  final TextEditingController nameController;
  final TextEditingController coeffController;

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile> {
  final GlobalKey showCaseKey1 = GlobalKey();
  final GlobalKey showCaseKey2 = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String coefficientString = Calculator.format(widget.s.coefficient, ignoreZero: true);

    if (widget.index1 == 1 && Manager.termTemplate.length >= 3 && getPreference<bool>("showcase_subject_edit", true)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.findAncestorWidgetOfExactType<ShowCaseWidget>() != null) {
          ShowCaseWidget.of(context).startShowCase([showCaseKey1, showCaseKey2]);
          setPreference("showcase_subject_edit", false);
        }
      });
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: widget.s.isChild ? const EdgeInsets.only(left: 16) : EdgeInsets.zero,
      child: TextRow(
        listKey: widget.listKey,
        leading: widget.s.name,
        trailing: coefficientString == "0" && widget.s.isGroup ? "" : coefficientString,
        padding: const EdgeInsets.only(left: 4, right: 24),
        horizontalTitleGap: 8,
        leadingIcon: ReorderableDragStartListener(
          index: widget.reorderIndex,
          child: Showcase(
            key: showCaseKey1,
            description: Translations.showcase_tap_subject,
            disableDefaultTargetGestures: true,
            disposeOnTap: true,
            onTargetClick: () {
              ShowCaseWidget.of(context).next();
            },
            scaleAnimationCurve: Curves.easeInOut,
            child: Showcase(
              key: showCaseKey2,
              description: Translations.showcase_drag_subject,
              disableDefaultTargetGestures: true,
              disposeOnTap: true,
              onTargetClick: () {
                ShowCaseWidget.of(context).next();
              },
              scaleAnimationCurve: Curves.easeInOut,
              child: IconButton(
                icon: const Icon(Icons.drag_handle),
                onPressed: () {
                  ShowCaseWidget.of(context).next();

                  if (widget.index1 == 0 && !widget.s.isChild) return;
                  List<List<Subject>> lists = [Manager.termTemplate];
                  for (Term term in Manager.getCurrentYear().terms) {
                    lists.add(term.subjects);
                  }

                  bool isChild = widget.s.isChild;

                  for (List<Subject> list in lists) {
                    if (!isChild) {
                      Subject parent = list[widget.index1 - 1];
                      Subject child = list.removeAt(widget.index1);

                      parent.isGroup = true;
                      child.isChild = true;
                      child.isGroup = false;

                      parent.children.addAll([child, ...child.children]);
                      child.children.clear();
                    } else {
                      Subject parent = list[widget.index1];
                      Subject child = parent.children.removeAt(widget.index2);
                      list.insert(widget.index1 + 1, child..isChild = false);
                      if (parent.children.isEmpty) parent.isGroup = false;
                    }
                  }

                  Manager.calculate();
                  serialize();
                  widget.rebuild();
                },
              ),
            ),
          ),
        ),
        onTap: () async {
          showListMenu(context, widget.listKey).then((result) {
            if (result == "edit") {
              showSubjectDialog(context, widget.nameController, widget.coeffController,
                      index: widget.index1, index2: widget.s.isChild ? widget.index2 : null)
                  .then((_) => widget.rebuild());
            } else if (result == "delete") {
              var parent = Manager.termTemplate[widget.index1];
              Manager.sortAll(sortModeOverride: SortMode.name);
              int newIndex = Manager.termTemplate.indexOf(parent);

              if (widget.s.isChild) {
                Manager.termTemplate[newIndex].children.removeWhere((element) => element.processedName == widget.s.processedName);
              } else {
                Manager.termTemplate.removeWhere((element) => element.processedName == widget.s.processedName);
              }

              for (Term t in Manager.getCurrentYear().terms) {
                if (widget.s.isChild) {
                  Subject parent = t.subjects[newIndex];
                  parent.children.removeWhere((element) => element.processedName == widget.s.processedName);
                  parent.isGroup = parent.children.isNotEmpty;
                } else {
                  t.subjects.removeWhere((element) => element.processedName == widget.s.processedName);
                }
              }

              Manager.calculate();
              widget.rebuild();
            }
          });
        },
      ),
    );
  }
}
