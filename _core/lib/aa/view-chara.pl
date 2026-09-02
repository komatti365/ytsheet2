################## データ表示 ##################
use strict;
#use warnings;
use utf8;
use open ":utf8";

### データ読み込み ###################################################################################
# setupViewBase で読み込み
(my $pcRef, my $SHEET) = setupViewBase(
  generateType => 'AfterArchivePC',
  unescapeLinesKeys => [qw/freeNote freeHistory exSkillNote weaponSkillNote personalSkillNote fullBurstSkillNote/],
  updateSub      => \&upgradeCharaData,
);
our %pc = %{ $pcRef };

### 閲覧禁止データのマスク --------------------------------------------------
sub maskPcData {
  my ($pc, $forbidden) = @_;
  unless($forbidden eq 'battle'){
    $pc->{aka} = '';
    $pc->{characterName} = noiseText(6,14);
    $pc->{characterNameRuby} = '';
    $pc->{group} = $pc->{tags} = '';
  
    $pc->{school} = noiseText(4,8);
    $pc->{grade}  = noiseText(2,3);
    $pc->{age}    = noiseText(1,2);
    $pc->{club}   = noiseText(3,6);
    
    $pc->{words} = '';
    $pc->{freeNote} = '';
    foreach(1..int(rand 3)+2){
      $pc->{freeNote} .= '　'.noiseText(18,40)."<br>";
    }
    $pc->{freeHistory} = '';
  }
  
  $pc->{weaponName} = noiseText(5,10);
  $pc->{weaponType} = noiseText(2,3);
  $pc->{damage}     = noiseText(2,4);
  $pc->{exSkillName} = noiseText(6,12);
  $pc->{exSkillNote} = noiseText(15,30);
  $pc->{weaponSkillName} = noiseText(6,12);
  $pc->{weaponSkillNote} = noiseText(15,30);
  $pc->{personalSkillName} = noiseText(4,8);
  $pc->{personalSkillNote} = noiseText(15,30);
  $pc->{fullBurstSkillName} = noiseText(4,8);
  $pc->{fullBurstSkillNote} = noiseText(15,30);

  $pc->{historyNum} = 0;
}

### テンプレート用データ構築 --------------------------------------------------
# 学園・学年・部活の表記
$SHEET->param(
  schoolFull => ($pc{school} ? $pc{school} : '') . ($pc{grade} ? " $pc{grade}" : '') . ($pc{club} ? " / $pc{club}" : ''),
);

# 能力値・タグの表データ構築
my @abilities = (
  ['hanayaka', '華やか'],
  ['daru',     'だる'],
  ['yuukan',   '勇敢'],
  ['cool',     'クール'],
  ['sottyoku', '率直'],
  ['himitsu',  '秘密主義'],
);
my @columns = (
  ['haikei',    '背景'],
  ['miryoku',   '魅力'],
  ['chara',     'キャラ'],
  ['syumi',     '趣味'],
  ['senjyutsu', '戦術'],
);

my @ability_loop;
foreach my $ab (@abilities) {
  my ($ab_id, $ab_name) = @$ab;
  my $abKeyCapital = ucfirst($ab_id);
  my $dice = $pc{"ability$abKeyCapital"} // 0;
  my @tag_cells;
  foreach my $col (@columns) {
    my ($col_id, $col_name) = @$col;
    my $name = $pc{"tag_${ab_id}_${col_id}"} // '';
    push(@tag_cells, {
      TAG => $name,
    });
  }
  push(@ability_loop, {
    ID => $ab_id,
    NAME => $ab_name,
    DICE => $dice,
    TagCells => \@tag_cells,
  });
}
$SHEET->param(AbilityRows => \@ability_loop);

# お友達リスト
my @friends_loop;
foreach my $num (1 .. ($pc{friendNum} || 4)) {
  next if !$pc{"friend${num}Name"} && !$pc{"friend${num}Calling"} && !$pc{"friend${num}Emotion"};
  push(@friends_loop, {
    NUM      => $num,
    NAME     => $pc{"friend${num}Name"},
    CALLING  => $pc{"friend${num}Calling"},
    EMOTION  => $pc{"friend${num}Emotion"},
    RELATION => $pc{"friend${num}Relation"},
    SUPPORT  => $pc{"friend${num}Support"},
  });
}
$SHEET->param(FriendsLoop => \@friends_loop);

# 知り合いリスト
my @acquaintances_loop;
foreach my $num (1 .. ($pc{acquaintanceNum} || 3)) {
  next if !$pc{"acquaintance${num}Name"} && !$pc{"acquaintance${num}Calling"} && !$pc{"acquaintance${num}Emotion"};
  push(@acquaintances_loop, {
    NUM      => $num,
    NAME     => $pc{"acquaintance${num}Name"},
    CALLING  => $pc{"acquaintance${num}Calling"},
    EMOTION  => $pc{"acquaintance${num}Emotion"},
    RELATION => $pc{"acquaintance${num}Relation"},
    SUPPORT  => $pc{"acquaintance${num}Support"},
  });
}
$SHEET->param(AcquaintancesLoop => \@acquaintances_loop);

# リアクション表
my @reactions_loop;
foreach my $num (1 .. 6) {
  my $val = $pc{"reaction$num"};
  push(@reactions_loop, {
    NUM  => sprintf("%02d", $num),
    DICE => $num,
    TEXT => $val,
  });
}
$SHEET->param(ReactionsLoop => \@reactions_loop);

# 履歴リスト
my @history_loop;
foreach my $num (1 .. ($pc{historyNum} || 0)) {
  next if !$pc{"history${num}Title"} && !$pc{"history${num}Gm"} && !$pc{"history${num}Date"};
  push(@history_loop, {
    NUM    => $num,
    DATE   => $pc{"history${num}Date"},
    TITLE  => $pc{"history${num}Title"},
    GM     => $pc{"history${num}Gm"},
    MEMBER => $pc{"history${num}Member"},
    NOTE   => $pc{"history${num}Note"},
  });
}
$SHEET->param(HistoryLoop => \@history_loop);

### メニュー --------------------------------------------------
setSheetMenu();

### 出力 #############################################################################################
printFinalizedView();

1;
