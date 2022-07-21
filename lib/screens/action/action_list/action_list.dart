import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/screens/action/action_list/action_list_bloc.dart';
import 'package:provenance_wallet/util/strings.dart';
import 'package:provider/provider.dart';

///
/// a widget that represents an action group's state
///
class ActionItemGroupStatus extends StatelessWidget {
  static const selectedLabel = Strings.actionListSelected;
  static const basicLabel = Strings.actionListBasicAccount;
  static const multiSigLabel = Strings.actionListMultiSigAccount;

  ActionItemGroupStatus({required this.group, Key? key})
      : label = (group.isSelected)
            ? selectedLabel
            : (group.isBasicAccount)
                ? basicLabel
                : multiSigLabel,
        super(key: key);

  final String label;
  final ActionListGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme as ProvenanceColorScheme;
    final color = (group.isSelected)
        ? colorScheme.actionListSelectedColor
        : colorScheme.actionNotListSelectedColor;

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
    final colorScheme = theme.colorScheme as ProvenanceColorScheme;

    return Container(
      color: colorScheme.actionListCellBackground,
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
                  "${group.subLabel} • ${group.items.length} ${group.items.length != 1 ? Strings.actionListActions : Strings.actionListAction}"),
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
  const ActionListCell(
      {required this.group, required this.onItemCliecked, Key? key})
      : super(key: key);

  final ActionListGroup group;
  final void Function(ActionListGroup group, ActionListItem item)
      onItemCliecked;

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
              return GestureDetector(
                child: ActionItemCell(item: item),
                onTap: () {
                  onItemCliecked(group, item);
                },
              );
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

          return ActionListCell(
            group: group,
            onItemCliecked: (ActionListGroup group, ActionListItem item) =>
                _handleOnItemClicked(context, group, item),
          );
        });
  }

  void _handleOnItemClicked(
      BuildContext context, ActionListGroup group, ActionListItem item) {
    final bloc = Provider.of<ActionListBloc>(context, listen: false);
    bloc.actionItemClicked(group, item);
  }
}
