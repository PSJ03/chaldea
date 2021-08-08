import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/method_channel_chaldea.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';

import 'display_settings/svt_tab_sorting.dart';

class DisplaySettingPage extends StatefulWidget {
  const DisplaySettingPage({Key? key}) : super(key: key);

  @override
  _DisplaySettingPageState createState() => _DisplaySettingPageState();
}

class _DisplaySettingPageState extends State<DisplaySettingPage> {
  CarouselSetting get carousel => db.userData.carouselSetting;

  HiveItem<bool> alwaysOnTop = db.cfg.alwaysOnTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(S.current.display_setting),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: 'App',
            children: [
              if (Platform.isMacOS || Platform.isWindows)
                SwitchListTile.adaptive(
                  value: alwaysOnTop.get() ?? false,
                  title: Text(LocalizedText.of(
                      chs: '置顶显示', jpn: 'スティッキー表示', eng: 'Always On Top')),
                  onChanged: (v) async {
                    alwaysOnTop.put(v);
                    MethodChannelChaldea.setAlwaysOnTop(v);
                    setState(() {});
                  },
                ),
              // only show on mobile phone, not desktop and tablet
              // on Android, cannot detect phone or mobile
              if (AppInfo.isMobile && !AppInfo.isIPad || kDebugMode)
                SwitchListTile.adaptive(
                  value: db.appSetting.autorotate,
                  title: Text(S.current.setting_auto_rotate),
                  onChanged: (v) {
                    setState(() {
                      db.appSetting.autorotate = v;
                    });
                    db.notifyAppUpdate();
                  },
                ),
            ],
          ),
          TileGroup(
            header: S.current.filter,
            footer: '${S.current.servant}/${S.current.craft_essence}'
                '/${S.current.command_code}',
            children: [
              SwitchListTile.adaptive(
                value: db.appSetting.autoResetFilter,
                title: Text(LocalizedText.of(
                    chs: '自动重置', jpn: '自動リセット', eng: 'Auto Reset')),
                onChanged: (v) async {
                  db.appSetting.autoResetFilter = v;
                  setState(() {});
                },
              ),
            ],
          ),
          TileGroup(
            header: LocalizedText.of(
                chs: '从者列表页', jpn: 'サーヴァントリストページ', eng: 'Servant List Page'),
            children: [
              // SwitchListTile.adaptive(
              //   value: db.appSetting.showClassFilterOnTop,
              //   title: Text(LocalizedText.of(
              //       chs: '显示职阶筛选按钮',
              //       jpn: 'クラスフィルターを表示',
              //       eng: 'Show Class Filter')),
              //   onChanged: (v) async {
              //     db.appSetting.showClassFilterOnTop = v;
              //     setState(() {});
              //   },
              // ),
              ListTile(
                title: Text(LocalizedText.of(
                  chs: '「关注」按钮默认筛选',
                  jpn: '「フォロー」ボタンディフォルト',
                  eng: '「Favorite」Button Default',
                )),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, _FavOptionSetting());
                },
              ),
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '从者职阶筛选样式',
                    jpn: 'クラスフィルタースタイル ',
                    eng: 'Servant Class Filter Style')),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, _ClassFilterStyleSetting());
                },
              ),
            ],
          ),
          TileGroup(
            header: LocalizedText.of(
                chs: '从者详情页', jpn: 'サーヴァント詳細ページ', eng: 'Servant Detail Page'),
            children: [
              ListTile(
                title: Text(LocalizedText.of(
                    chs: '标签页排序', jpn: 'ページ表示順序', eng: 'Tabs Sorting')),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  SplitRoute.push(context, SvtTabsSortingSetting());
                },
              )
            ],
          ),
          TileGroup(
            header: S.current.carousel_setting,
            children: [
              CheckboxListTile(
                value: carousel.enableMooncell,
                title: Text('Mooncell News'),
                subtitle: Text('CN/JP'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    carousel.needUpdate = true;
                    carousel.enableMooncell = v ?? carousel.enableMooncell;
                  });
                },
              ),
              CheckboxListTile(
                value: carousel.enableJp,
                title: Text('JP News'),
                subtitle: Text('https://view.fate-go.jp/'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    carousel.needUpdate = true;
                    carousel.enableJp = v ?? carousel.enableJp;
                  });
                },
              ),
              CheckboxListTile(
                value: carousel.enableUs,
                title: Text('NA News'),
                subtitle: Text('https://webview.fate-go.us/'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) {
                  setState(() {
                    carousel.needUpdate = true;
                    carousel.enableUs = v ?? carousel.enableUs;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavOptionSetting extends StatefulWidget {
  const _FavOptionSetting({Key? key}) : super(key: key);

  @override
  __FavOptionSettingState createState() => __FavOptionSettingState();
}

class __FavOptionSettingState extends State<_FavOptionSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocalizedText.of(
        chs: '「关注」按钮默认筛选',
        jpn: '「フォロー」ボタンディフォルト',
        eng: '「Favorite」Button Default',
      ))),
      body: ListView(
        children: [
          TileGroup(
            children: [
              RadioListTile<bool?>(
                value: null,
                groupValue: db.appSetting.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '记住选择', jpn: '前の選択', eng: 'Remember')),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.favoritePreferred = null;
                  });
                },
              ),
              RadioListTile<bool?>(
                value: true,
                groupValue: db.appSetting.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '显示已关注', jpn: 'フォロー表示', eng: 'Show Favorite')),
                secondary: Icon(Icons.favorite),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.favoritePreferred = true;
                  });
                },
              ),
              RadioListTile<bool?>(
                value: false,
                groupValue: db.appSetting.favoritePreferred,
                title: Text(LocalizedText.of(
                    chs: '显示全部', jpn: 'すべて表示', eng: 'Show All')),
                secondary: Icon(Icons.remove_circle_outline),
                onChanged: (v) {
                  setState(() {
                    db.appSetting.favoritePreferred = false;
                  });
                },
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                SplitRoute.push(context, ServantListPage(), detail: false);
              },
              child: Text(S.current.preview),
            ),
          )
        ],
      ),
    );
  }
}

class _ClassFilterStyleSetting extends StatefulWidget {
  const _ClassFilterStyleSetting({Key? key}) : super(key: key);

  @override
  _ClassFilterStyleSettingState createState() =>
      _ClassFilterStyleSettingState();
}

class _ClassFilterStyleSettingState extends State<_ClassFilterStyleSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocalizedText.of(
              chs: '从者职阶筛选样式',
              jpn: 'クラスフィルタースタイル ',
              eng: 'Servant Class Filter Style'))),
      body: ListView(
        children: [
          TileGroup(
            children: [
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.auto,
                groupValue: db.appSetting.classFilterStyle,
                title:
                    Text(LocalizedText.of(chs: '自动适配', jpn: '自动', eng: 'Auto')),
                subtitle: Text(LocalizedText.of(
                    chs: '匹配屏幕尺寸', jpn: 'マッチ画面サイズ', eng: 'Match Screen Size')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.singleRow,
                groupValue: db.appSetting.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: '单行不展开Extra职阶',
                    jpn: '「Extraクラス」展開、単一行',
                    eng: '<Extra CLass> Collapsed\nSingle Row')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.singleRowExpanded,
                groupValue: db.appSetting.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: '单行并展开Extra职阶',
                    jpn: '単一行、「Extraクラス」を折り畳み',
                    eng: '<Extra CLass> Expanded\nSingle Row')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.twoRow,
                groupValue: db.appSetting.classFilterStyle,
                title: Text(LocalizedText.of(
                    chs: 'Extra职阶显示在第二行',
                    jpn: '「Extraクラス」は2行目に表示',
                    eng: '<Extra CLass> in Second Row')),
                onChanged: onChanged,
              ),
              RadioListTile<SvtListClassFilterStyle>(
                value: SvtListClassFilterStyle.doNotShow,
                groupValue: db.appSetting.classFilterStyle,
                title: Text(
                    LocalizedText.of(chs: '隐藏', jpn: '非表示', eng: 'Hidden')),
                onChanged: onChanged,
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                SplitRoute.push(context, ServantListPage(), detail: false);
              },
              child: Text(S.current.preview),
            ),
          )
        ],
      ),
    );
  }

  void onChanged(SvtListClassFilterStyle? v) {
    setState(() {
      if (v != null) db.appSetting.classFilterStyle = v;
    });
  }
}
