################## チャットパレット用サブルーチン ##################
use strict;
#use warnings;
use utf8;

### プリセット #######################################################################################
sub palettePreset {
  my $tool = shift;
  my $type = shift;
  my $text = '';
  
  # 能力値判定（【1 + 使用タグ数】D6 >= 4）
  $text .= "### ■ 能力値判定（目標値:4 / 出目6でクリティカル / 出目1でファンブル）\n";
  $text .= "({華やか}+1)D6>=4 【華やか判定】(全タグ使用)\n";
  $text .= "{華やか}D6>=4 【華やか判定】\n";
  $text .= "({だる}+1)D6>=4 【だる判定】(全タグ使用)\n";
  $text .= "{だる}D6>=4 【だる判定】\n";
  $text .= "({勇敢}+1)D6>=4 【勇敢判定】(全タグ使用)\n";
  $text .= "{勇敢}D6>=4 【勇敢判定】\n";
  $text .= "({クール}+1)D6>=4 【クール判定】(全タグ使用)\n";
  $text .= "{クール}D6>=4 【クール判定】\n";
  $text .= "({率直}+1)D6>=4 【率直判定】(全タグ使用)\n";
  $text .= "{率直}D6>=4 【率直判定】\n";
  $text .= "({秘密主義}+1)D6>=4 【秘密主義判定】(全タグ使用)\n";
  $text .= "{秘密主義}D6>=4 【秘密主義判定】\n";
  $text .= "1D6>=4 【基本判定】(タグ不使用)\n";
  $text .= "\n";

  # 戦闘判定・攻撃・ダメージ
  my $wName = $::pc{weaponSkillName} || $::pc{weaponName} || '';
  $wName = "$wName / " if $wName;
  $text .= "### ■ 戦闘判定・攻撃・ダメージ\n";
  $text .= "2D6>=4 【命中判定】\n";
  $text .= "2D6>=4 【回避判定】\n";
  $text .= "{武器ダメージ} 【武器攻撃ダメージ】（$wName$::pc{weaponType} / $::pc{attackType}）\n";
  $text .= "4D6 【フルバーストダメージ】（$::pc{fullBurstSkillName}）\n";
  $text .= "\n";

  # 学園フェイズ・テンション・トラブル
  $text .= "### ■ 学園フェイズ・テンション・トラブル\n";
  $text .= "1D6 【テンション上昇】\n";
  $text .= "1D6 【アピール・テンション上昇】\n";
  $text .= "1D6 【トラブル表】\n";
  $text .= "\n";

  # 応援（お友達・知り合い）
  $text .= "### ■ 応援（感情値D6）\n";
  foreach my $i (1 .. ($::pc{friendNum} || 3)) {
    my $name = $::pc{"friend${i}Name"};
    my $emo  = $::pc{"friend${i}Emotion"};
    if ($name && $emo) {
      $text .= "${emo}D6 【応援：${name}】\n";
    }
  }
  foreach my $i (1 .. ($::pc{acquaintanceNum} || 3)) {
    my $name = $::pc{"acquaintance${i}Name"};
    my $emo  = $::pc{"acquaintance${i}Emotion"};
    if ($name && $emo) {
      $text .= "${emo}D6 【応援：${name}】\n";
    }
  }
  $text .= "\n";

  # リアクション表
  $text .= "### ■ リアクション表\n";
  $text .= "1D6 【リアクション表】\n";
  foreach my $i (1..6) {
    my $r = $::pc{"reaction$i"};
    $r =~ s/<br>/ /g if $r;
    if($r) {
      $text .= "[$i] $r\n";
    }
  }
  $text .= "\n";

  # スキル
  $text .= "### ■ スキル\n";
  if($::pc{exSkillName}) {
    $text .= "【EXスキル：$::pc{exSkillName}】(コスト:$::pc{exSkillCost}) $::pc{exSkillNote}\n";
  }
  if($::pc{weaponSkillName}) {
    $text .= "【武装スキル：$::pc{weaponSkillName}】 $::pc{weaponSkillNote}\n";
  }
  if($::pc{fullBurstSkillName}) {
    $text .= "【フルバーストスキル：$::pc{fullBurstSkillName}】 $::pc{fullBurstSkillNote}\n";
  }
  if($::pc{personalSkillName}) {
    $text .= "【パーソナルスキル：$::pc{personalSkillName}】(タグ:$::pc{personalSkillTag}) $::pc{personalSkillNote}\n";
  }

  $text =~ s/<br>/\n/g;
  return $text;
}

### プリセット（シンプル） ###########################################################################
sub palettePresetSimple {
  my $tool = shift;
  my $type = shift;
  my $text = '';

  my $h_dice = ($::pc{abilityHanayaka} || 0);
  my $d_dice = ($::pc{abilityDaru} || 0);
  my $y_dice = ($::pc{abilityYuukan} || 0);
  my $c_dice = ($::pc{abilityCool} || 0);
  my $s_dice = ($::pc{abilitySottyoku} || 0);
  my $m_dice = ($::pc{abilityHimitsu} || 0);

  $text .= "### ■ 能力値判定（目標値:4）\n";
  $text .= ($h_dice + 1)."D6>=4 【華やか判定】(全タグ使用)\n";
  $text .= ($d_dice + 1)."D6>=4 【だる判定】(全タグ使用)\n";
  $text .= ($y_dice + 1)."D6>=4 【勇敢判定】(全タグ使用)\n";
  $text .= ($c_dice + 1)."D6>=4 【クール判定】(全タグ使用)\n";
  $text .= ($s_dice + 1)."D6>=4 【率直判定】(全タグ使用)\n";
  $text .= ($m_dice + 1)."D6>=4 【秘密主義判定】(全タグ使用)\n";
  $text .= "1D6>=4 【基本判定】(タグ不使用)\n";
  $text .= "\n";

  $text .= "### ■ 戦闘判定・攻撃・ダメージ\n";
  $text .= "2D6>=4 【命中判定】\n";
  $text .= "2D6>=4 【回避判定】\n";
  $text .= ($::pc{damage} || '2D')." 【武器攻撃ダメージ】（$::pc{weaponType}）\n";
  $text .= "4D6 【フルバーストダメージ】\n";
  $text .= "\n";

  $text .= "### ■ 学園フェイズ・テンション・トラブル\n";
  $text .= "1D6 【テンション上昇】\n";
  $text .= "1D6 【アピール・テンション上昇】\n";
  $text .= "1D6 【トラブル表】\n";
  $text .= "1D6 【リアクション表】\n";
  foreach my $i (1..6) {
    my $r = $::pc{"reaction$i"};
    $r =~ s/<br>/ /g if $r;
    if($r) {
      $text .= "[$i] $r\n";
    }
  }

  $text =~ s/<br>/\n/g;
  return $text;
}

### デフォルト変数 ###################################################################################
sub paletteProperties {
  my $tool = shift;
  my $type = shift;
  my @properties = (
    "//華やか=" . ($::pc{abilityHanayaka} || 0),
    "//だる=" . ($::pc{abilityDaru} || 0),
    "//勇敢=" . ($::pc{abilityYuukan} || 0),
    "//クール=" . ($::pc{abilityCool} || 0),
    "//率直=" . ($::pc{abilitySottyoku} || 0),
    "//秘密主義=" . ($::pc{abilityHimitsu} || 0),
    "//HP=" . ($::pc{hpMax} || 25),
    "//テンション=" . ($::pc{tensionMax} || 12),
    "//SP=" . ($::pc{sp} || 0),
    "//SP最大=" . ($::pc{spMax} || 10),
    "//弾数=" . ($::pc{bulletMax} || 2),
    "//武器ダメージ=" . ($::pc{damage} || '2D'),
  );
  return @properties;
}

1;
