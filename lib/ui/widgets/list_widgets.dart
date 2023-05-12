// Flutter imports:
import "package:flutter/material.dart";

// Package imports:
import "package:showcaseview/showcaseview.dart";

// Project imports:
import "package:graded/calculations/calculator.dart";
import "package:graded/calculations/manager.dart";
import "package:graded/calculations/subject.dart";
import "package:graded/calculations/term.dart";
import "package:graded/localization/translations.dart";
import "package:graded/misc/enums.dart";
import "package:graded/misc/storage.dart";
import "package:graded/ui/routes/subject_edit_route.dart";
import "package:graded/ui/widgets/dialogs.dart";
import "package:graded/ui/widgets/popup_menus.dart";

class TextRow extends StatelessWidget {
  const TextRow({
    super.key,
    required this.leading,
    required this.trailing,
    this.leadingIcon,
    this.trailingIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.listKey,
    this.onTap,
    this.isChild = false,
    this.horizontalTitleGap = 16,
  });

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
  const GroupRow({
    super.key,
    required this.children,
    required this.leading,
    required this.trailing,
  });

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
              ),
            ),
            trailing: Row(
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
  const ResultRow({
    super.key,
    required this.result,
    required this.leading,
    this.onResultTap,
  });

  final String result;
  final Widget leading;
  final Function()? onResultTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          GestureDetector(
            onTap: onResultTap,
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
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
    super.key,
    required this.s,
    required this.listKey,
    required this.index1,
    this.index2 = 0,
    required this.reorderIndex,
    required this.rebuild,
    required this.nameController,
    required this.coeffController,
    required this.speakingController,
  });

  final Subject s;
  final GlobalKey listKey;
  final int index1;
  final int index2;
  final int reorderIndex;
  final Function() rebuild;
  final TextEditingController nameController;
  final TextEditingController coeffController;
  final TextEditingController speakingController;

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile> {
  Future<void> showTutorial(BuildContext context) async {
    if (widget.index1 != 2 || Manager.termTemplate.length < 3 || !getPreference<bool>("showcase_subject_edit", true)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300), () {
        if (context.findAncestorWidgetOfExactType<ShowCaseWidget>() == null) return;

        ShowCaseWidget.of(context).startShowCase([showCaseKey1, showCaseKey2]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String coefficientString = Calculator.format(widget.s.coefficient, addZero: false, roundToOverride: 1);

    showTutorial(context);

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
          child: (widget.index1 == 1 && Manager.termTemplate.length >= 3 && getPreference<bool>("showcase_subject_edit", true))
              ? Showcase(
                  key: showCaseKey1,
                  description: translations.showcase_tap_subject,
                  scaleAnimationCurve: Curves.easeInOut,
                  child: Showcase(
                    key: showCaseKey2,
                    description: translations.showcase_drag_subject,
                    scaleAnimationCurve: Curves.easeInOut,
                    child: IgnorePointer(child: ReorderableHandle(widget: widget)),
                  ),
                )
              : ReorderableHandle(widget: widget),
        ),
        onTap: () async {
          showListMenu(context, widget.listKey).then((result) {
            switch (result) {
              case MenuAction.edit:
                showSubjectDialog(
                  context,
                  widget.nameController,
                  widget.coeffController,
                  widget.speakingController,
                  index: widget.index1,
                  index2: widget.s.isChild ? widget.index2 : null,
                ).then((_) => widget.rebuild());
              case MenuAction.delete:
                final parent = Manager.termTemplate[widget.index1];
                Manager.sortAll(sortModeOverride: SortMode.name);
                int newIndex = Manager.termTemplate.indexOf(parent);

                if (widget.s.isChild) {
                  Manager.termTemplate[newIndex].children.removeWhere((element) => element.processedName == widget.s.processedName);
                } else {
                  Manager.termTemplate.removeWhere((element) => element.processedName == widget.s.processedName);
                }

                for (final Term t in Manager.getCurrentYear().terms) {
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
              default:
                break;
            }
          });
        },
      ),
    );
  }
}

class ReorderableHandle extends StatelessWidget {
  const ReorderableHandle({
    super.key,
    required this.widget,
  });

  final SubjectTile widget;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.drag_handle),
      onPressed: () {
        if (widget.index1 == 0 && !widget.s.isChild) return;
        List<List<Subject>> lists = [Manager.termTemplate];
        for (final Term term in Manager.getCurrentYear().terms) {
          lists.add(term.subjects);
        }

        bool isChild = widget.s.isChild;

        for (final List<Subject> list in lists) {
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
    );
  }
}
