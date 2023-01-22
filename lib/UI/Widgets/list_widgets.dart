// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../Calculations/calculator.dart';
import '../../Calculations/manager.dart';
import '../../Calculations/subject.dart';
import '../../Calculations/term.dart';
import 'dialogs.dart';
import 'popup_menus.dart';

class TextRow extends StatelessWidget {
  const TextRow(
      {Key? key,
      this.listKey,
      this.leadingIcon,
      this.onTap,
      required this.leading,
      required this.trailing,
      this.trailingIcon,
      this.padding = const EdgeInsets.symmetric(horizontal: 24)})
      : super(key: key);

  final Key? listKey;
  final Function()? onTap;
  final IconData? trailingIcon;
  final String leading;
  final String trailing;
  final Widget? leadingIcon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
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
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class GroupRow extends StatefulWidget {
  const GroupRow({Key? key, required this.children, required this.leading, required this.trailing, this.initiallyExpanded = false}) : super(key: key);

  final String leading;
  final String trailing;
  final List<Widget> children;
  final bool initiallyExpanded;

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
                    child: const Icon(Icons.expand_more),
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
            initiallyExpanded: widget.initiallyExpanded,
            children: widget.children,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 3, color: Theme.of(context).colorScheme.surfaceVariant),
          ),
        ],
      ),
    );
  }
}

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    Key? key,
    required this.s,
    required this.listKey,
    required this.index,
    this.index2 = 0,
    required this.reorderIndex,
    required this.rebuild,
    required this.nameController,
    required this.coeffController,
  }) : super(key: key);

  final Subject s;
  final GlobalKey listKey;
  final int index;
  final int index2;
  final int reorderIndex;
  final Function rebuild;
  final TextEditingController nameController;
  final TextEditingController coeffController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: UniqueKey(),
      padding: s.isChild ? const EdgeInsets.only(left: 16) : EdgeInsets.zero,
      child: TextRow(
        listKey: listKey,
        leading: s.name,
        padding: EdgeInsets.only(left: s.isChild ? 32 : 24, right: 24),
        trailing: Calculator.format(s.coefficient, ignoreZero: true),
        onTap: () async {
          showListMenu(context, listKey).then((result) {
            if (result == "edit") {
              showSubjectDialog(context, nameController, coeffController, index: index, index2: s.isChild ? index2 : null).then((_) => rebuild());
            } else if (result == "delete") {
              Manager.termTemplate.removeAt(index);
              Manager.sortSubjectsAZ();

              for (Term t in Manager.getCurrentYear().terms) {
                t.subjects.removeAt(index);
              }

              Manager.calculate();
              rebuild();
            }
          });
        },
      ),
    );
  }
}
