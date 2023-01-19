// Flutter imports:
import 'package:flutter/material.dart';

class TextRow extends StatelessWidget {
  const TextRow(
      {Key? key, this.listKey, this.leadingButton, this.onTap, required this.leading, required this.trailing, this.icon, this.isChild = false})
      : super(key: key);

  final Key? listKey;
  final Function()? onTap;
  final IconData? icon;
  final String leading;
  final String trailing;
  final bool isChild;
  final Widget? leadingButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isChild)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
          ),
        ListTile(
          key: listKey,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: leadingButton,
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
              if (icon != null) ...[
                const Padding(padding: EdgeInsets.only(right: 24)),
                Icon(
                  icon,
                  size: 24.0,
                ),
              ]
            ],
          ),
        ),
        if (!isChild)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Theme.of(context).colorScheme.surfaceVariant),
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
