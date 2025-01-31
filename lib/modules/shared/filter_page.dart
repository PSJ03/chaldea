import 'package:chaldea/components/components.dart';

abstract class FilterPage<T> extends StatefulWidget {
  final T filterData;
  final ValueChanged<T>? onChanged;

  const FilterPage({Key? key, required this.filterData, this.onChanged})
      : super(key: key);

  static void show(
      {required BuildContext context, required WidgetBuilder builder}) {
    if (SplitRoute.isSplit(context)) {
      showDialog(context: context, builder: builder);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints:
                constraints.copyWith(maxHeight: constraints.maxHeight * 0.7),
            child: builder(context),
          );
        }),
      );
    }
  }
}

abstract class FilterPageState<T> extends State<FilterPage<T>> {
  T get filterData => widget.filterData;

  TextStyle textStyle = const TextStyle(fontSize: 16);
  bool? _useTabletView;

  bool get useSplitView {
    _useTabletView ??= SplitRoute.isSplit(context);
    return _useTabletView!;
  }

  void update() {
    if (widget.onChanged != null) {
      widget.onChanged!(filterData);
    }
    setState(() {});
  }

  Widget buildAdaptive(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return useSplitView
        ? _buildDialog(title: title, content: content, actions: actions)
        : _buildSheet(title: title, content: content, actions: actions);
  }

  Widget _buildSheet(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          toolbarHeight: 40,
          leading: const BackButton(),
          title: title,
          centerTitle: true,
          actions: actions,
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: min(400, MediaQuery.of(context).size.height * 0.4)),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _buildDialog(
      {Widget? title,
      required Widget content,
      List<Widget> actions = const []}) {
    return AlertDialog(
      title: Center(child: title),
      titlePadding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      actions: actions,
      content: Container(
        // for landscape, limit it's width
        width: defaultDialogWidth(context),
        // for portrait, limit it's height
        constraints: BoxConstraints(maxHeight: defaultDialogHeight(context)),
        child: content,
      ),
    );
  }

  List<Widget> getDefaultActions(
      {VoidCallback? onTapReset,
      bool? showOk,
      List<Widget> extraActions = const []}) {
    showOk ??= useSplitView;
    if (useSplitView) {
      return [
        ...extraActions,
        TextButton(
          child: Text(S.of(context).reset.toUpperCase(),
              style: const TextStyle(color: Colors.redAccent)),
          // textColor: Colors.redAccent,
          onPressed: onTapReset,
        ),
        if (showOk)
          TextButton(
            child: Text(S.of(context).ok.toUpperCase()),
            onPressed: () => Navigator.pop(context),
          ),
      ];
    } else {
      return [
        ...extraActions,
        IconButton(icon: const Icon(Icons.replay), onPressed: onTapReset),
        if (showOk)
          IconButton(
              icon: const Icon(Icons.done),
              onPressed: () => Navigator.pop(context))
      ];
    }
  }

  Widget getListViewBody({List<Widget> children = const []}) {
    final size = MediaQuery.of(context).size;
    return LimitedBox(
      maxHeight: min(420, size.height * 0.65),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 6),
        shrinkWrap: true,
        children: divideTiles(children,
            divider: const Divider(color: Colors.transparent, height: 5)),
      ),
    );
  }

  Widget getGroup({
    String? header,
    List<Widget> children = const [],
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 12),
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (header != null)
            CustomTile(
              title: Text(header, style: textStyle),
              contentPadding: EdgeInsets.zero,
            ),
          Wrap(
            spacing: 8,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        ],
      ),
    );
  }

  Widget getDisplayOptions({String? header, List<Widget> children = const []}) {
    header ??= S.current.filter_shown_type;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTile(
            title: Text(header, style: textStyle),
            contentPadding: EdgeInsets.zero,
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        ],
      ),
    );
  }

  Widget getSortButton<S>(
      {String? prefix,
      required S value,
      required Map<S, String> items,
      ValueChanged<S?>? onSortAttr,
      bool reversed = true,
      ValueChanged<bool>? onSortDirectional}) {
    return DropdownButton(
      isDense: true,
      value: value,
      icon: IconButton(
        icon: Icon(reversed ? Icons.south_rounded : Icons.north_rounded),
        onPressed: () {
          if (onSortDirectional != null) {
            onSortDirectional(!reversed);
          }
        },
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.loose(const Size.square(24)),
        iconSize: 20,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      items: items.entries
          .map((e) => DropdownMenuItem(
              child: Text(e.value, style: textStyle), value: e.key))
          .toList(),
      onChanged: onSortAttr,
    );
  }
}

// for filter items
typedef FilterCallBack<T> = bool Function(T data);

class FilterGroup extends StatelessWidget {
  final Widget? title;
  final List<String> options;
  final FilterGroupData values;
  final Widget Function(String value)? optionBuilder;
  final bool showMatchAll;
  final bool showInvert;
  final bool useRadio;
  final bool shrinkWrap;
  final void Function(FilterGroupData optionData)? onFilterChanged;

  final bool combined;
  final EdgeInsetsGeometry padding;
  final bool showCollapse;

  const FilterGroup({
    Key? key,
    this.title,
    required this.options,
    required this.values,
    this.optionBuilder,
    this.showMatchAll = false,
    this.showInvert = false,
    this.useRadio = false,
    this.shrinkWrap = false,
    this.onFilterChanged,
    this.combined = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.showCollapse = false,
  }) : super(key: key);

  Widget _buildCheckbox(
      BuildContext context, bool checked, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.grey,
          ),
          Text(text)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _optionChildren = [];
    for (int index = 0; index < options.length; index++) {
      String key = options[index];
      _optionChildren.add(FilterOption(
        selected: values.options[key] ?? false,
        value: key,
        child: optionBuilder == null ? Text(key) : optionBuilder!(key),
        shrinkWrap: shrinkWrap,
        borderRadius: combined
            ? BorderRadius.horizontal(
                left: Radius.circular(index == 0 ? 3 : 0),
                right: Radius.circular(index == options.length - 1 ? 3 : 0),
              )
            : BorderRadius.circular(3),
        onChanged: (v) {
          if (useRadio) {
            values.options.clear();
            values.options[key] = true;
          } else {
            values.options[key] = v;
            values.options.removeWhere((k, v) => v != true);
          }
          if (onFilterChanged != null) {
            onFilterChanged!(values);
          }
        },
      ));
    }

    Widget child = Wrap(
      spacing: combined ? 0 : 6,
      runSpacing: 3,
      children: _optionChildren,
    );

    Widget _getTitle([Widget? expandIcon]) {
      return CustomTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: DefaultTextStyle.merge(
              child: title!, style: const TextStyle(fontSize: 14)),
        ),
        contentPadding: EdgeInsets.zero,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showMatchAll)
              _buildCheckbox(
                  context, values.matchAll, S.current.filter_match_all, () {
                values.matchAll = !values.matchAll;
                if (onFilterChanged != null) {
                  onFilterChanged!(values);
                }
              }),
            if (showInvert)
              _buildCheckbox(context, values.invert, S.current.filter_revert,
                  () {
                values.invert = !values.invert;
                if (onFilterChanged != null) {
                  onFilterChanged!(values);
                }
              }),
            if (expandIcon != null) expandIcon,
          ],
        ),
      );
    }

    Widget _wrapExpandIcon(Widget _child) {
      return ValueStatefulBuilder<bool>(
        initValue: true,
        builder: (context, state) {
          Widget? expandIcon;
          if (showCollapse) {
            expandIcon = ExpandIcon(
              isExpanded: state.value,
              onPressed: (v) {
                state.value = !state.value;
                state.updateState();
              },
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getTitle(expandIcon),
              if (state.value) _child,
            ],
          );
        },
      );
    }

    if (title != null) {
      if (showCollapse) {
        child = _wrapExpandIcon(child);
      } else {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getTitle(),
            child,
          ],
        );
      }
    }

    return Padding(padding: padding, child: child);
  }
}

class FilterOption<T> extends StatelessWidget {
  final bool selected;
  final T value;
  final Widget? child;
  final ValueChanged<bool>? onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final BorderRadius borderRadius;
  final bool shrinkWrap;

  const FilterOption({
    Key? key,
    required this.selected,
    required this.value,
    this.child,
    this.onChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(3)),
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 30),
      child: OutlinedButton(
        onPressed: () {
          if (onChanged != null) {
            onChanged!(!selected);
          }
        },
        style: OutlinedButton.styleFrom(
          primary: selected || darkMode ? Colors.white : Colors.black,
          backgroundColor:
              selected ? selectedColor ?? Colors.blue : unselectedColor,
          minimumSize: shrinkWrap ? const Size(2, 2) : null,
          padding: shrinkWrap ? const EdgeInsets.all(0) : null,
          textStyle: const TextStyle(fontWeight: FontWeight.normal),
          tapTargetSize: shrinkWrap ? MaterialTapTargetSize.shrinkWrap : null,
          shape: ContinuousRectangleBorder(borderRadius: borderRadius),
        ),
        child: child ?? Text(value.toString()),
        // shape: ,
      ),
    );
  }
}
