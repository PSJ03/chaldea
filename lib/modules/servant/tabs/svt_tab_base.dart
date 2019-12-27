import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';

abstract class SvtTabBaseWidget extends StatefulWidget {
  final ServantDetailPageState parent;
  final Servant svt;
  final ServantStatus status;

  SvtTabBaseWidget({Key key, this.parent, this.svt, this.status})
      : super(key: key);
}

abstract class SvtTabBaseState<T extends SvtTabBaseWidget> extends State<T> {
  Servant svt;
  ServantStatus status;

  SvtTabBaseState(
      {ServantDetailPageState parent, Servant svt, ServantStatus status})
      : assert(parent?.svt != null || svt != null) {
    this.svt = svt ?? parent?.svt;
    this.status = status ?? parent?.status ?? ServantStatus();
  }
}