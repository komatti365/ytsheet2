use strict;
#use warnings;
use utf8;
use open ":utf8";
use CGI::Cookie;
use List::Util qw/max min/;
use Fcntl;

### サブルーチン-AA #################################################################################

### ユニットステータス出力 --------------------------------------------------
sub createUnitStatus {
  my %pc = %{$_[0]};
  my @unitStatus = (
    { 'HP' => $pc{hpMax} || $pc{hp} || '25' },
    { 'テンション' => '0' },
    { 'SP' => '0' },
    { '弾数' => $pc{bulletMax} || $pc{bullet} || '2' },
    { '予備弾' => $pc{reserveBullet} || '0' },
  );
  
  foreach my $key (split ',', $pc{unitStatusNotOutput}){
    @unitStatus = grep { !exists $_->{$key} } @unitStatus;
  }

  foreach my $num (1..$pc{unitStatusNum}){
    next if !$pc{"unitStatus${num}Label"};
    push(@unitStatus, { $pc{"unitStatus${num}Label"} => $pc{"unitStatus${num}Value"} });
  }

  return \@unitStatus;
}

### テキスト整形ルール --------------------------------------------------
## 複数行対応欄
our %multilineTargets = (
  ''  => '「容姿・経歴・その他メモ」「履歴（自由記入）」「EXスキル効果」「武装スキル効果」「パーソナルスキル効果」「フルバーストスキル効果」',
);

### バージョンアップデート --------------------------------------------------
sub upgradeCharaData {
  my %pc = %{$_[0]};
  my $ver = $pc{ver};
  delete $pc{updateMessage};
  $ver =~ s/^([0-9]+)\.([0-9]+)\.([0-9]+)$/$1.$2$3/;
  
  $pc{lasttimever} = $pc{ver};
  $pc{ver} = $main::ver;
  return %pc;
}

1;
