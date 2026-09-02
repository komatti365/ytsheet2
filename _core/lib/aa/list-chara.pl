################## 一覧表示 ##################
use strict;
#use warnings;
use utf8;
use open ":utf8";
use HTML::Template;

require $set::lib_list;

### クエリ ###########################################################################################
my @queryKeys = qw(
  mode tag group image name player school grade club weapon position attack
);
setFields({
  id          => 0,
  date        => 3,
  name        => 4,
  player      => 5,
  group       => 6,
  image       => 7,
  tags        => 8,
  hide        => 9,
  school      => 10,
  grade       => 11,
  club        => 12,
  weaponType  => 13,
  position    => 14,
  attackType  => 15,
  hpMax       => 16,
  tensionMax  => 17,
  weakness    => 18,
  friends     => 19,
  acquaintance=> 20,
  session     => 21,
});

### テンプレート読み込み #############################################################################
my $INDEX = setupListTemplate(
  type     => '',
);
my ($indexMode, $qLinks) = listQueryInfo(
  queryKeys => \@queryKeys,
  excludeFromQLinks => { group => 1 },
);
my %groups = setupGroupList();

### ファイル読み込み #################################################################################
my @lines = loadLines();

### 検索フィルタ #####################################################################################
@lines = filterGroup(@lines)  if $::in{group} && $::in{group} ne 'all';
@lines = filterTag(@lines)    if $::in{tag};
@lines = filterImage(@lines)  if $::in{image};
@lines = filterContainsRegex(lines => \@lines, key => 'name', flags => 'i') if $::in{name};
@lines = filterContainsRegex(lines => \@lines, key => 'player', flags => 'i') if $::in{player};
@lines = filterContainsRegex(lines => \@lines, key => 'school', query => $_) foreach split /\s/,$::in{school};
@lines = filterContainsRegex(lines => \@lines, key => 'grade', query => $_) foreach split /\s/,$::in{grade};
@lines = filterContainsRegex(lines => \@lines, key => 'club', query => $_) foreach split /\s/,$::in{club};
@lines = filterFlagRegex(lines => \@lines, key => 'weaponType') if $::in{weapon};
@lines = filterFlagRegex(lines => \@lines, key => 'position') if $::in{position};
@lines = filterFlagRegex(lines => \@lines, key => 'attackType') if $::in{attack};

### ソート ###########################################################################################
if($::in{sort}){
  my $s = $::in{sort};
  if   ($s eq 'name')    { my @t = map { sortKeyName($_)       } @lines; @lines = @lines[sort {$t[$a] cmp $t[$b]} 0 .. $#t]; }
  elsif($s eq 'pl')      { my @t = map { capField($_,'player') } @lines; @lines = @lines[sort {$t[$a] cmp $t[$b]} 0 .. $#t]; }
  elsif($s eq 'date')    { my @t = map { capField($_,'date')   } @lines; @lines = @lines[sort {$t[$b] <=> $t[$a]} 0 .. $#t]; }
  elsif($s eq 'school')  { my @t = map { capField($_,'school') } @lines; @lines = @lines[sort {$t[$a] cmp $t[$b]} 0 .. $#t]; }
  elsif($s eq 'position'){ my @t = map { capField($_,'position')} @lines; @lines = @lines[sort {$t[$a] cmp $t[$b]} 0 .. $#t]; }
}

### ページ処理 #######################################################################################
my ($pageLines, $count, $page, $pageStart, $pageEnd, $shouldSkip) = prepareGroupedPage(
  lines => \@lines,
  selectedGroup => $::in{group},
  hasTagQuery   => $::in{tag},
  countExtraOf  => $set::playerlist ? sub {
    my $line = shift;
    return capField($line, 'player');
  } : undef,
);

my %groupedLists;
foreach (@$pageLines) {
  my %pc = %{ splitField($_) };
  
  # グループ
  $pc{group} = $set::group_default if (!$pc{group} || !$groups{$pc{group}});
  $pc{group} = 'all' if $::in{group} eq 'all';
  
  next if $shouldSkip->(
    group => $pc{group},
    extra => $pc{player},
  );
  
  ## シンプルリスト
  if($indexMode && $set::simplelist){
    my @characters;
    push(@characters, {
      ID     => $pc{id},
      NAME   => renderCharacterName($pc{name}),
      PLAYER => $pc{player},
      GROUP  => $pc{group},
    });
    push(@{$groupedLists{$pc{group}}}, \@characters);
  }
  ## フルリスト
  else {
    my @characters;
    push(@characters, {
      ID         => $pc{id},
      NAME       => renderCharacterName($pc{name}),
      PLAYER     => $pc{player},
      GROUP      => $pc{group},
      SCHOOL     => $pc{school},
      GRADE      => $pc{grade},
      CLUB       => $pc{club},
      WEAPON     => $pc{weaponType},
      POSITION   => $pc{position},
      ATTACK     => $pc{attackType},
      HP         => $pc{hpMax},
      TENSION    => $pc{tensionMax},
      TAGS       => renderTagLinks($pc{tags}, $pc{session}),
      DATE       => renderUpdateTime($pc{date}),
      HIDE       => $pc{hide},
    });
    push(@{$groupedLists{$pc{group}}}, @characters);
  }
}

### テンプレートへ入力 ###############################################################################
$INDEX->param(Lists => [ makeGroupedLists(
  groupOrder => [ sort { $groups{$a}{sort} <=> $groups{$b}{sort} } keys %groupedLists ],
  groupedLists => \%groupedLists,
  count => $count,
  
  makePager => sub {
    my (%args) = @_;

    return makePager(
      count     => $args{count},
      page      => $page,
      enabled   => ($args{id} || $::in{mode} eq 'mylist'),
      queryBase => "group=$::in{group}$qLinks",
    );
  },

  makeGroup => \&makeCharacterGroup,
) ]);

## 検索サマリー --------------------------------------------------
setSearchSummary(
  [ $::in{school},   '所属学園「%s」' ],
  [ $::in{club},     '部活「%s」' ],
  [ $::in{weapon},   '銃種「%s」' ],
  [ $::in{position}, 'ポジション「%s」' ],
);

### 出力 #############################################################################################
printFinalizedList();

1;
