import 'package:chaldea/components/datatypes/datatypes.dart';

import 'func_buff_type_base.dart';

class FuncType extends FuncBuffTypeBase<NiceFunction> {
  static final Map<String, FuncType> all = {};

  FuncType._(
      int index, String type, String nameCn, String nameJp, String nameEn,
      [bool Function(NiceFunction)? test])
      : super(true, index, type, nameCn, nameJp, nameEn, test) {
    FuncBuffTypeBase? _one = all[type];
    if (_one != null) {
      assert(_one.index == index &&
          _one.type == type &&
          _one.nameCn == nameCn &&
          _one.nameJp == nameJp &&
          _one.nameEn == nameEn &&
          _one.test == test);
    }
    all[type] = this;
  }
}

class _FuncTypes {
  static _FuncTypes? _instance;

  _FuncTypes._();

  factory _FuncTypes._singleton() => _instance ?? _FuncTypes._();

  Map<String, FuncType> get all => FuncType.all;

  Map<String, FuncType> get withoutAddState => Map.fromEntries([
        ...FuncTypes.all.entries.where((e) =>
            e.value != FuncTypes.addState &&
            e.value != FuncTypes.addStateShort),
      ]);

  FuncType none = FuncType._(0, 'none', '无', 'なし', 'none');
  FuncType addState =
      FuncType._(1, 'addState', '赋予状态', '状態を与える', 'Apply State');
  FuncType subState =
      FuncType._(2, 'subState', '解除状态', '状態を削除', 'Remove State');

  //  FuncType damage = FuncType._(3, 'damage', '', '', '');
  //  FuncType damageNp = FuncType._(4, 'damageNp', '宝具攻击', '', '');
  FuncType gainStar = FuncType._(5, 'gainStar', '暴击星获得', 'スター獲得', 'Gain Stars');
  FuncType gainHp = FuncType._(6, 'gainHp', 'HP回复', 'HP回復', 'Restore HP');
  FuncType gainNp = FuncType._(7, 'gainNp', 'NP増加', 'NP増加', 'Charge NP');
  FuncType lossNp = FuncType._(8, 'lossNp', 'NP減少', 'NP減少', 'Drain NP');
  FuncType shortenSkill =
      FuncType._(9, 'shortenSkill', '技能冷却减小', 'スキルターン減少', 'Reduce Cooldowns');

  //  FuncType extendSkill = FuncType._(10, 'extendSkill', '技能冷却增加', '', 'Increase Colldowns');
  //  FuncType releaseState = FuncType._(11, 'releaseState', '', '', '');
  FuncType lossHp = FuncType._(12, 'lossHp', 'HP減少', 'HP減少', 'Drain HP');
  FuncType instantDeath =
      FuncType._(13, 'instantDeath', '即死', '即死', 'Instant Death');
  FuncType damageNpPierce = FuncType._(
      14, 'damageNpPierce', '宝具-无视防御', '宝具-防御無視', 'NP damage-pierces Defence');
  FuncType damageNpIndividual = FuncType._(15, 'damageNpIndividual', '宝具-对特性特攻',
      '宝具-対特性特攻', 'NP damage-Bonus to Trait');
  FuncType addStateShort =
      FuncType._(16, 'addStateShort', '赋予状态_2', '状態を与える_2', 'Apply State_2');
  FuncType gainHpPer =
      FuncType._(17, 'gainHpPer', 'HP回复(%)', 'HP回復(%)', 'Restore HP(%)');
  FuncType damageNpStateIndividual = FuncType._(18, 'damageNpStateIndividual',
      '宝具-对状态特攻', '宝具-対状態特攻', 'NP damage-Bonus to State');
  FuncType hastenNpturn =
      FuncType._(19, 'hastenNpturn', '充能增加', 'チャージ増加', 'Increase Charge');
  FuncType delayNpturn =
      FuncType._(20, 'delayNpturn', '充能减少', 'チャージ減少', 'Drain Charge'); //enemy
  //  FuncType damageNpHpratioHigh = FuncType._(21, 'damageNpHpratioHigh', '', '', '');
  FuncType damageNpHpratioLow = FuncType._(22, 'damageNpHpratioLow',
      'HP越低宝具伤害越高', 'HPが少ないほど宝具威力の高い', 'NP damage-Bonus for Low HP');
  FuncType cardReset =
      FuncType._(23, 'cardReset', '洗牌', 'コマンドカードを配り直す', 'Shuffle Cards');

  //  FuncType replaceMember = FuncType._(24, 'replaceMember', '换人(Order Change)', 'オーダーチェンジ', 'Swap members');
  FuncType lossHpSafe = FuncType._(
      25, 'lossHpSafe', 'HP減少(safe)', 'HP減少(safe)', 'Drain HP(safe)');

  //  FuncType damageNpCounter = FuncType._(26, 'damageNpCounter', '', '', 'Reflect Damage Received');
  FuncType damageNpStateIndividualFix = FuncType._(
      27,
      'damageNpStateIndividualFix',
      '特攻-对状态宝具Fix',
      '宝具-対状態特攻Fix',
      'NP damage-Bonus to Trait(Fix)');

  //  FuncType damageNpSafe = FuncType._(28, 'damageNpSafe', '', '', '');
  //  FuncType callServant = FuncType._(29, 'callServant', '', '', '');
  //  FuncType ptShuffle = FuncType._(30, 'ptShuffle', '', '', '');
  FuncType lossStar =
      FuncType._(31, 'lossStar', '暴击星减少', 'スター減少', 'Remove Stars');

  //  FuncType changeServant = FuncType._(32, 'changeServant', '', '', '');
  //  FuncType changeBg = FuncType._(33, 'changeBg', '', '', '');
  //  FuncType damageValue = FuncType._(34, 'damageValue', '', '', '');
  //  FuncType withdraw = FuncType._(35, 'withdraw', '', '', '');
  FuncType fixCommandcard =
      FuncType._(36, 'fixCommandcard', '固定发牌', '手札を固定', 'Lock Command Cards');

  //  FuncType shortenBuffturn = FuncType._(37, 'shortenBuffturn', '', '', '');
  //  FuncType extendBuffturn = FuncType._(38, 'extendBuffturn', '', '', '');
  //  FuncType shortenBuffcount = FuncType._(39, 'shortenBuffcount', '', '', '');
  //  FuncType extendBuffcount = FuncType._(40, 'extendBuffcount', '', '', '');
  //  FuncType changeBgm = FuncType._(41, 'changeBgm', '', '', '');
  //  FuncType displayBuffstring = FuncType._(42, 'displayBuffstring', '', '', '');
  //  FuncType resurrection = FuncType._(43, 'resurrection', '', '', '');
  FuncType gainNpBuffIndividualSum = FuncType._(44, 'gainNpBuffIndividualSum',
      '根据状态数增加NP', 'NPを状態の数だけ増やす', 'Charge NP per State/Buff'); //Kingprotea&梵高
  //  FuncType setSystemAliveFlag = FuncType._(45, 'setSystemAliveFlag', '', '', '');
  FuncType forceInstantDeath = FuncType._(
      46, 'forceInstantDeath', '即死(强制)', '即死(強制)', 'Instant Death(force)');

  FuncType damageNpRare = FuncType._(47, 'damageNpRare', '宝具-对稀有度特攻',
      '宝具-〔低レア〕特攻', 'NP damage-Bonus to Rarity');
  FuncType gainNpFromTargets = FuncType._(
      48, 'gainNpFromTargets', 'NP吸收', 'NP吸収', 'Absorb NP Charge'); // player
  FuncType gainHpFromTargets =
      FuncType._(49, 'gainHpFromTargets', 'HP吸收', 'HP吸収', 'Absorb HP');

  // FuncType lossHp = FuncType._(12, 'lossHp', 'HP減少', 'HP減少', 'Drain HP');

  FuncType lossHpPer =
      FuncType._(50, 'lossHpPer', 'HP減少(%)', 'HP減少(%)', 'Drain HP(%)');
  FuncType lossHpPerSafe = FuncType._(
      51, 'lossHpPerSafe', 'HP減少(%,safe)', 'HP減少(%,safe)', 'Drain HP(%,safe)');

  //  FuncType shortenUserEquipSkill = FuncType._(52, 'shortenUserEquipSkill', '', '', '');
  //  FuncType quickChangeBg = FuncType._(53, 'quickChangeBg', '', '', '');
  //  FuncType shiftServant = FuncType._(54, 'shiftServant', '', '', '');
  //  FuncType damageNpAndCheckIndividuality = FuncType._(55, 'damageNpAndCheckIndividuality', '', '', '');
  //  FuncType absorbNpturn = FuncType._(56, 'absorbNpturn', 'NP吸收', 'NP吸収', 'Absorb NP Charge'); //enemy

  //  FuncType overwriteDeadType = FuncType._(57, 'overwriteDeadType', '', '', '');
  //  FuncType forceAllBuffNoact = FuncType._(58, 'forceAllBuffNoact', '', '', '');
  //  FuncType breakGaugeUp = FuncType._(59, 'breakGaugeUp', '', '', '');
  //  FuncType breakGaugeDown = FuncType._(60, 'breakGaugeDown', '', '', '');
  //  FuncType moveToLastSubmember = FuncType._(61, 'moveToLastSubmember', '', '', ''); //鹤小姐
  FuncType expUp =
      FuncType._(101, 'expUp', '御主EXP增加', 'マスターEXP増加', 'Increase Master EXP');
  FuncType qpUp =
      FuncType._(102, 'qpUp', 'QP增加(固定)', 'QP增加(固定)', 'Increase QP Reward');

  //  FuncType dropUp = FuncType._(103, 'dropUp', '', '', '');
  FuncType friendPointUp = FuncType._(
      104, 'friendPointUp', '友情点增加', 'フレンドポイント增加', 'Increase Friend Point');

  //  FuncType eventDropUp = FuncType._(105, 'eventDropUp', '', '', '');
  //  FuncType eventDropRateUp = FuncType._(106, 'eventDropRateUp', '', '', '');
  //  FuncType eventPointUp = FuncType._(107, 'eventPointUp', '', '', '');
  //  FuncType eventPointRateUp = FuncType._(108, 'eventPointRateUp', '', '', '');
  //  FuncType transformServant = FuncType._(109, 'transformServant', '改变从者(杰基尔)', '', '');
  FuncType qpDropUp =
      FuncType._(110, 'qpDropUp', 'QP掉落增加', 'QPドロップ增加', 'Increase QP Drops');
  FuncType servantFriendshipUp = FuncType._(
      111, 'servantFriendshipUp', '羁绊增加', '絆增加', 'Increase Bond Gain');
  FuncType userEquipExpUp = FuncType._(112, 'userEquipExpUp', '魔术礼装EXP增加',
      '魔術礼装EXP增加', 'Increase Mystic Code EXP');

  //  FuncType classDropUp = FuncType._(113, 'classDropUp', '', '', '');
  //  FuncType enemyEncountCopyRateUp = FuncType._(114, 'enemyEncountCopyRateUp', '', '', '');
  //  FuncType enemyEncountRateUp = FuncType._(115, 'enemyEncountRateUp', '', '', '');
  //  FuncType enemyProbDown = FuncType._(116, 'enemyProbDown', '', '', '');
  //  FuncType getRewardGift = FuncType._(117, 'getRewardGift', '', '', '');
  //  FuncType sendSupportFriendPoint = FuncType._(118, 'sendSupportFriendPoint', '', '', '');
  //  FuncType movePosition = FuncType._(119, 'movePosition', '', '', '');
  //  FuncType revival = FuncType._(120, 'revival', '', '', '');
  FuncType damageNpIndividualSum = FuncType._(121, 'damageNpIndividualSum',
      '宝具-根据状态数特攻', '宝具-状態の数特攻', 'NP damage-Bonus per Trait');

  //  FuncType damageValueSafe = FuncType._(122, 'damageValueSafe', '', '', '');
  FuncType friendPointUpDuplicate = FuncType._(123, 'friendPointUpDuplicate',
      '友情点增加(可叠加)', 'フレンドポイント增加(重複可能)', 'Increase Friend Point(stackable)');
//  FuncType moveState = FuncType._(124, 'moveState', '', '', '');//吸收诅咒之类的
//  FuncType changeBgmCostume = FuncType._(125, 'changeBgmCostume', '', '', '');
//  FuncType func126 = FuncType._(126, 'func126', '', '', '');
//  FuncType func127 = FuncType._(127, 'func127', '', '', '');
//  FuncType updateEntryPositions = FuncType._(128, 'updateEntryPositions', '', '', '');

}

// ignore: unused_element,non_constant_identifier_names
final FuncTypes = _FuncTypes._singleton();
