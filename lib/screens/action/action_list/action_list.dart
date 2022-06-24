import 'package:flutter/material.dart';
import 'package:provenance_wallet/common/widgets/pw_spacer.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';

///
/// a widget that represents an action group's state
///
class ActionItemGroupStatus extends StatelessWidget {
  static const selectedColor = Color.fromARGB(255, 0x01, 0x3C, 0x3B);
  static const notSelectedColor = Color.fromARGB(255, 0x3E, 0x41, 0x51);

  static const selectedLabel = "Selected";
  static const basicLabel = "Basic";
  static const multiSigLabel = "Multi-Sig";

  ActionItemGroupStatus({required ActionListGroup group, Key? key})
      : color = (group.isSelected) ? selectedColor : notSelectedColor,
        label = (group.isSelected)
            ? selectedLabel
            : (group.isBasicAccount)
                ? basicLabel
                : multiSigLabel,
        super(key: key);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(15), color: color),
      child: Text(label),
    );
  }
}

///
/// a widget that represents an individual action item
///
class ActionItemCell extends StatelessWidget {
  const ActionItemCell({required this.item, Key? key}) : super(key: key);

  final ActionListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: const Color.fromARGB(255, 0x2B, 0x2F, 0x3A),
      padding: const EdgeInsets.fromLTRB(
          Spacing.large, Spacing.xLarge, Spacing.small, Spacing.xLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label),
              VerticalSpacer.small(),
              Text(
                item.subLabel,
                style: theme.textTheme.caption,
              ),
            ],
          )),
          Icon(
            Icons.keyboard_arrow_right,
            color: theme.textTheme.caption!.color,
          )
        ],
      ),
    );
  }
}

class ActionGroupHeaderCell extends StatelessWidget {
  const ActionGroupHeaderCell({required this.group, Key? key})
      : super(key: key);

  final ActionListGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.label),
              VerticalSpacer.xSmall(),
              Text(
                  "${group.subLabel} • ${group.items.length} Action${group.items.length != 1 ? "s" : ""}"),
            ],
          )),
          ActionItemGroupStatus(
            group: group,
          )
        ],
      ),
    );
  }
}

class ActionListCell extends StatelessWidget {
  const ActionListCell({required this.group, Key? key}) : super(key: key);

  final ActionListGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionGroupHeaderCell(group: group),
        ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: group.items.length,
            separatorBuilder: (context, index) => const VerticalSpacer.xSmall(),
            itemBuilder: (context, index) {
              final item = group.items[index];
              return ActionItemCell(item: item);
            })
      ],
    );
  }
}

class ActionList extends StatelessWidget {
  const ActionList({required this.groups, Key? key}) : super(key: key);

  final List<ActionListGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: groups.length,
        separatorBuilder: (context, index) => const VerticalSpacer.medium(),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.medium, vertical: Spacing.small),
        itemBuilder: (context, index) {
          final group = groups[index];

          return ActionListCell(group: group);
        });
  }
}
