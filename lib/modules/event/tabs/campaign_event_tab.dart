import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../campaign_detail_page.dart';
import '../event_base_page.dart';

class CampaignEventTab extends StatefulWidget {
  final bool reverse;
  final bool showOutdated;
  final bool showSpecialRewards;

  const CampaignEventTab(
      {Key? key,
      this.reverse = false,
      this.showOutdated = false,
      this.showSpecialRewards = false})
      : super(key: key);

  @override
  _CampaignEventTabState createState() => _CampaignEventTabState();
}

class _CampaignEventTabState extends State<CampaignEventTab> {
  late ScrollController _scrollController;

  Map<String, CampaignEvent> get campaigns => db.gameData.events.campaigns;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<CampaignEvent> events = campaigns.values.toList();
    if (!widget.showOutdated) {
      events.removeWhere((e) =>
          e.isOutdated() &&
          !db.curUser.events.limitEventOf(e.indexKey).enabled);
    }
    EventBase.sortEvents(events, reversed: widget.reverse);

    return ListView(
      controller: _scrollController,
      children: events.map((event) {
        final plan = db.curUser.events.limitEventOf(event.indexKey);
        bool outdated = event.isOutdated();
        String? subtitle;
        if (db.curUser.server == GameServer.cn) {
          subtitle = event.startTimeCn?.split(' ').first;
          if (subtitle != null) {
            subtitle = 'CN ' + subtitle;
          }
        }
        subtitle ??= 'JP ' + (event.startTimeJp?.split(' ').first ?? '???');
        Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
        Widget tile = ListTile(
          title: AutoSizeText(
            event.localizedName,
            maxFontSize: 16,
            maxLines: 2,
            style: outdated ? TextStyle(color: _outdatedColor) : null,
          ),
          subtitle: AutoSizeText(
            subtitle,
            maxLines: 1,
            style: outdated
                ? TextStyle(color: _outdatedColor?.withAlpha(200))
                : null,
          ),
          trailing: event.couldPlan
              ? db.streamBuilder(
                  (context) => Switch.adaptive(
                    value: plan.enabled,
                    onChanged: (v) => setState(() {
                      plan.enabled = v;
                      db.itemStat.updateEventItems();
                    }),
                  ),
                )
              : null,
          onTap: () {
            SplitRoute.push(
              context,
              CampaignDetailPage(event: event),
              popDetail: true,
            );
          },
        );
        if (widget.showSpecialRewards) {
          if (widget.showSpecialRewards) {
            tile = EventBasePage.buildSpecialRewards(context, event, tile);
          }
        }
        return tile;
      }).toList(),
    );
  }
}
