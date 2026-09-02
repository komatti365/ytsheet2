################## JSONデータ追加 ##################
use strict;
#use warnings;
use utf8;
use open ":utf8";

sub addJsonData {
  my %pc = %{ $_[0] };
  my $type = $_[1];

  ### 簡易プロフィール
  my $school_grade = ($pc{school} ? "$pc{school}" : '').($pc{grade} ? " $pc{grade}" : '').($pc{club} ? "（$pc{club}）" : '');
  my $wName        = $pc{weaponSkillName} || $pc{weaponName} || '';
  my $battle_info  = "武器:$wName($pc{weaponType}/$pc{attackType}) ポジション:$pc{position} HP:$pc{hpMax} テンション:$pc{tensionMax} 弱点:$pc{weakness}";
  my $skills_info  = "EX:$pc{exSkillName} / 武装:$wName / 個人:$pc{personalSkillName} / FB:$pc{fullBurstSkillName}";

  $pc{sheetDescriptionS} = $school_grade . "\n" . $battle_info;
  $pc{sheetDescriptionM} = $school_grade . "\n" . $battle_info . "\n" . $skills_info;

  ## ユニット（コマ）用ステータス
  $pc{unitStatus} = createUnitStatus(\%pc);

  return \%pc;
}

1;
