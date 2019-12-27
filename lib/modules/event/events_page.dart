import 'package:chaldea/components/components.dart';

import 'tabs/exchange_ticket_tab.dart';
import 'tabs/limit_event_tab.dart';
import 'tabs/main_record_tab.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  final tabNames = ['限时活动', '主线记录', '素材交换券'];
  TabController _tabController;
  bool reverse = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
    db.runtimeData.itemStatistics.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).event_title),
        leading: SplitViewBackButton(),
        actions: <Widget>[
          IconButton(
              icon: Icon(reverse ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () => setState(() => reverse = !reverse))
        ],
        bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabs: tabNames.map((name) => Tab(text: name)).toList()),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          LimitEventTab(reverse: reverse),
          MainRecordTab(reverse: reverse),
          ExchangeTicketTab(reverse: reverse)
        ],
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    db.saveUserData();
  }
}