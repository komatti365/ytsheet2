################## データ保存 ##################
use strict;
#use warnings;
use utf8;

sub dataCalc {
  my %pc = %{$_[0]};
  ### アップデート --------------------------------------------------
  if($pc{ver}){
    %pc = upgradeCharaData(\%pc);
  }

  ### 能力値・タグ集計 --------------------------------------------------
  my @abilities = ('hanayaka', 'daru', 'yuukan', 'cool', 'sottyoku', 'himitsu');
  my @columns   = ('haikei', 'miryoku', 'chara', 'syumi', 'senjyutsu');

  my $total_tags = 0;

  foreach my $ab (@abilities) {
    my $count = 0;
    foreach my $col (@columns) {
      if($pc{"tag_${ab}_${col}"} ne '') {
        $count++;
        $total_tags++;
      }
    }
    my $abKeyCapital = ucfirst($ab);
    $pc{"ability${abKeyCapital}Calc"} = $count;
    # 未入力なら自動計算値をセット
    if($pc{"ability${abKeyCapital}"} eq '') {
      $pc{"ability${abKeyCapital}"} = $count;
    }
  }
  $pc{totalTagCount} = $total_tags;

  ### 武器・ポジション・ステータス --------------------------------------------------
  # 固有武器名・武装スキル名の相互同期
  if(!$pc{weaponName} && $pc{weaponSkillName}){ $pc{weaponName} = $pc{weaponSkillName}; }
  if(!$pc{weaponSkillName} && $pc{weaponName}){ $pc{weaponSkillName} = $pc{weaponName}; }

  # デフォルト補完（未入力時）
  if(!$pc{position}){
    if   ($pc{weaponType} =~ /^(?:SMG|SG|FT)$/) { $pc{position} = 'フロント'; }
    elsif($pc{weaponType} =~ /^(?:AR|MG|GL)$/) { $pc{position} = 'ミドル'; }
    elsif($pc{weaponType} =~ /^(?:SR|RG|RL|MT)$/) { $pc{position} = 'バッグ'; }
    else { $pc{position} = 'ミドル'; }
  }

  if(!$pc{hpMax} && !$pc{hp}){
    if   ($pc{position} eq 'フロント') { $pc{hpMax} = 33; $pc{hp} = 33; }
    elsif($pc{position} eq 'ミドル')   { $pc{hpMax} = 25; $pc{hp} = 25; }
    elsif($pc{position} eq 'バッグ')   { $pc{hpMax} = 15; $pc{hp} = 15; }
  }
  if(!$pc{tensionMax} && !$pc{tension}){
    if   ($pc{position} eq 'フロント') { $pc{tensionMax} = 10; $pc{tension} = 10; }
    elsif($pc{position} eq 'ミドル')   { $pc{tensionMax} = 12; $pc{tension} = 12; }
    elsif($pc{position} eq 'バッグ')   { $pc{tensionMax} = 16; $pc{tension} = 16; }
  }
  if(!$pc{weakness}){
    if   ($pc{position} eq 'フロント') { $pc{weakness} = 'ストッピング'; }
    elsif($pc{position} eq 'ミドル')   { $pc{weakness} = '爆発'; }
    elsif($pc{position} eq 'バッグ')   { $pc{weakness} = '貫通'; }
  }

  ### お友達・知り合い --------------------------------------------------
  my $friend_count = 0;
  foreach (1 .. ($pc{friendNum} || 4)){
    if($pc{"friend${_}Name"}){ $friend_count++; }
  }
  my $acquaintance_count = 0;
  foreach (1 .. ($pc{acquaintanceNum} || 3)){
    if($pc{"acquaintance${_}Name"}){ $acquaintance_count++; }
  }

  ### 改行を<br>に変換 --------------------------------------------------
  convertNewlinesToBrTag(\%pc,
    qw/freeNote freeHistory chatPalette exSkillNote weaponSkillNote personalSkillNote fullBurstSkillNote/,
    ( map { 'words'.$_ } '', 2 .. ($set::image_maxcount || 1) ),
    ( map { 'reaction'.$_ } 1..6 ),
  );

  #### 保存処理でなければここまで --------------------------------------------------
  if(!$::mode_save){ return %pc; }

  #### エスケープ --------------------------------------------------
  $pc{$_} = escapePcData($pc{$_}) foreach (keys %pc);
  $pc{tags} = normalizeHashtags($pc{tags});

  ### 最終参加卓 --------------------------------------------------
  foreach my $i (reverse 1 .. $pc{historyNum}){
    if($pc{"history${i}Gm"} && $pc{"history${i}Title"}){ $pc{lastSession} = removeTags unescapeTags $pc{"history${i}Title"}; last; }
  }

  ### updatedLine --------------------------------------------------
  my %NL;
  foreach ('characterName','playerName','school','grade','club','weaponType','position','attackType','weakness'){
    $NL{$_} = $pc{$_} =~ s/[|｜]([^|｜]+?)《.+?》/$1/gr;
    $NL{$_} = removeTags unescapeTags $NL{$_} =~ s/^\s|\s$//gr;
  }
  $NL{characterName} = substr($NL{characterName}, 0, 108).'..' if length($NL{characterName}) > 108;
  $NL{playerName}    = substr($NL{playerName}   , 0,  25).'..' if length($NL{playerName}   ) >  25;
  $NL{school}        = substr($NL{school}       , 0,  20).'..' if length($NL{school}       ) >  20;
  $NL{grade}         = substr($NL{grade}        , 0,  10).'..' if length($NL{grade}        ) >  10;
  $NL{club}          = substr($NL{club}         , 0,  20).'..' if length($NL{club}         ) >  20;
  $NL{weaponType}    = substr($NL{weaponType}   , 0,  10).'..' if length($NL{weaponType}   ) >  10;
  $NL{position}      = substr($NL{position}     , 0,  10).'..' if length($NL{position}     ) >  10;
  $NL{attackType}    = substr($NL{attackType}   , 0,  15).'..' if length($NL{attackType}   ) >  15;
  $NL{weakness}      = substr($NL{weakness}     , 0,  20).'..' if length($NL{weakness}     ) >  20;

  $::updatedLine =
    "$pc{id}<>$::file<>"
    . "$pc{birthTime}<>$::now<>$NL{characterName}<>$NL{playerName}<>$pc{group}<>"
    . setUpdatatLineImage(\%pc)."<> $pc{tags} <>$pc{hide}<>"
    . "$NL{school}<>$NL{grade}<>$NL{club}<>"
    . "$NL{weaponType}<>$NL{position}<>$NL{attackType}<>"
    . "$pc{hpMax}<>$pc{tensionMax}<>$NL{weakness}<>"
    . "$friend_count<>$acquaintance_count<>$pc{lastSession}<>";

  return %pc;
}

1;
