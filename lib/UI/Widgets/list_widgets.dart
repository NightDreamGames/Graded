// Flutter imports:
import 'package:flutter/material.dart';

class TextRow extends StatelessWidget {
  const TextRow({Key? key, this.listKey, this.onTap, required this.leading, required this.trailing, this.icon}) : super(key: key);

  final Key? listKey;
  final Function()? onTap;
  final IconData? icon;
  final String leading;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          key: listKey,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
              if (icon == null)
                Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                )
              else ...[
                Text(
                  trailing,
                  style: const TextStyle(fontSize: 20.0),
                ),
                const Padding(padding: EdgeInsets.only(right: 24)),
                Icon(
                  icon,
                  size: 24.0,
                ),
              ]
            ],
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
