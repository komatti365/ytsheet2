############# フォーム・キャラクター #############
use strict;
#use warnings;
use utf8;
use open ":utf8";
use feature 'signatures';
no warnings 'experimental::signatures';

my $LOGIN_ID = $::LOGIN_ID;

### 読込前処理 #######################################################################################
require $set::lib_palette_sub;

### データ読み込み ###################################################################################
my ($data, $file, $message) = loadSheetData();
our %pc = %{ $data };

our $isNewSheet = isNewSheet();

### 出力準備 #########################################################################################
$message = applyMessageName($message, $pc{characterName} || '無題');

### 初期設定 --------------------------------------------------
if($isNewSheet){
  $pc{playerName} = (getPlayerName($LOGIN_ID))[0];
  $pc{protect} ||= $LOGIN_ID ? 'account' : 'password';
}

if($::mode eq 'edit' || ($::mode =~ /^(?:convert|copy)$/ && $pc{ver})){
  %pc = upgradeCharaData(\%pc);
  if($pc{updateMessage}){
    $message .= "<hr>" if $message;
    $message .= "<h2>アップデート通知</h2><dl>";
    foreach (sort keys %{$pc{updateMessage}}){
      $message .= '<dt>'.$_.'</dt><dd>'.$pc{updateMessage}{$_}.'</dd>';
    }
    $message .= "</dl><small>前回保存時のバージョン:$pc{lasttimever}</small>";
  }
}
elsif($::mode eq 'blanksheet'){
  $pc{group} = $set::group_default;

  $pc{position}   = 'ミドル';
  $pc{hpMax}      = 25;
  $pc{hp}         = 25;
  $pc{tensionMax} = 12;
  $pc{tension}    = 12;
  $pc{weakness}   = 'ノーマル、爆発';

  $pc{paletteUseBuff} = 1;

  %pc = applyCustomizedInitialValues(\%pc);
}

## 画像・セリフ位置
setDefaultImageStyle(\%pc);
setDefaultWordsPosition(\%pc);

## カラー
setDefaultColors(\%pc);

## その他
$pc{historyNum} ||= 3;
$pc{friendNum}  ||= 3;
$pc{acquaintanceNum} ||= 3;

### 改行処理 --------------------------------------------------
convertEscapedBrToNewlines(\%pc,
  qw/freeNote freeHistory chatPalette weaponSkillNote exSkillNote personalSkillNote fullBurstSkillNote/,
  ( map { 'words'.$_ } '', 2 .. ($set::image_maxcount || 1) ),
);

### フォーム表示 #####################################################################################
print renderEditPageStart(
  title => (removeTags removeRuby unescapeTags ($pc{characterName} || ($pc{aka} ? qq|“$pc{aka}”| : '') || '無題')),
);
print renderEditHeaderMenu(
  tabsHtml => <<~'HTML',
    <li onclick="sectionSelect('common');" class="sheet-main"><span>キャラ<span class="shorten">クター</span></span><span>データ</span>
    <li onclick="sectionSelect('palette');" class="unit-setting"><span><span class="shorten">ユニット(</span>コマ<span class="shorten">)</span></span><span>設定</span>
  HTML
);
print qq|<aside class="message">$message</aside>| if $message;

print <<"HTML";
  <section id="section-common">
    @{[ renderProtectBlock() ]}
    @{[ renderVisibilityBlock() ]}

    <div class="box" id="group">
      <dl>
        <dt>グループ
        <dd><select name="group">@{[ renderGroupOptions ]}</select>
        <dt>タグ
        <dd>@{[ input 'tags' ]}
      </dl>
    </div>

    <div class="box in-toc" id="name-form" data-content-title="キャラクター名・プレイヤー名">
      <div>
        <dl id="character-name">
          <dt>キャラクター名
          <dd>@{[ input 'characterName','text',"setName",'id="main-name" required' ]}
          <dt class="ruby">ふりがな
          <dd>@{[ input 'characterNameRuby','text',"setName" ]}
        </dl>
        <dl id="aka">
          <dt>二つ名・通り名
          <dd>@{[ input 'aka','text',"setName" ]}
          <dt class="ruby">二つ名のフリガナ
          <dd>@{[ input 'akaRuby','text',"setName" ]}
        </dl>
      </div>
      <dl id="player-name">
        <dt>プレイヤー名
        <dd>@{[ input 'playerName' ]}
      </dl>
    </div>

    <div id="area-status">
      @{[ renderImageForm() ]}

      <div id="personal" class="in-toc" data-content-title="基本情報">
        <dl class="box" id="school"><dt>所属学園<dd>@{[ input 'school', 'text', '', 'list="list-school" placeholder="例）ミレニアムサイエンススクール"' ]}</dl>
        <dl class="box" id="grade"><dt>学年<dd>@{[ input 'grade', 'text', '', 'list="list-grade" placeholder="例）2年生"' ]}</dl>
        <dl class="box" id="club"><dt>部活<dd>@{[ input 'club', 'text', '', 'placeholder="例）セミナー"' ]}</dl>
        <dl class="box" id="gender"><dt>性別<dd>@{[ input 'gender', 'text', '', 'list="list-gender" placeholder="例）女"' ]}</dl>
        <dl class="box" id="age"><dt>年齢<dd>@{[ input 'age', 'text', '', 'placeholder="例）16歳"' ]}</dl>
        <dl class="box" id="height"><dt>身長<dd>@{[ input 'height', 'text', '', 'placeholder="例）156cm"' ]}</dl>
      </div>

      <datalist id="list-school">
        <option value="アビドス高等学校">
        <option value="ゲヘナ学園">
        <option value="トリニティ総合学園">
        <option value="ミレニアムサイエンススクール">
        <option value="百鬼夜行連合学院">
        <option value="山海経高級中学校">
        <option value="レッドウィンター連邦学園">
        <option value="ヴァルキューレ警察学校">
        <option value="SRT特殊学園">
        <option value="アリウス分校">
        <option value="ハイランダー鉄道学園">
        <option value="ワイルドハント芸術学院">
        <option value="オデュッセイア海洋高等学校">
        <option value="クロノススクール">
        <option value="連邦生徒会">
      </datalist>

      <datalist id="list-grade">
        <option value="1年生">
        <option value="2年生">
        <option value="3年生">
      </datalist>

      <datalist id="list-gender">
        <option value="女">
        <option value="男">
        <option value="その他">
      </datalist>

      <div id="status" class="in-toc" data-content-title="戦闘ステータス">
        <dl class="box" id="weapon-type">
          <dt>銃種
          <dd><select name="weaponType" onchange="applyWeaponPreset()">
            <option value="">選択してください
            <option value="SMG" @{[ $pc{weaponType} eq 'SMG' ? 'selected':'' ]}>SMG（サブマシンガン）
            <option value="AR" @{[ $pc{weaponType} eq 'AR' ? 'selected':'' ]}>AR（アサルトライフル）
            <option value="SG" @{[ $pc{weaponType} eq 'SG' ? 'selected':'' ]}>SG（ショットガン）
            <option value="SR" @{[ $pc{weaponType} eq 'SR' ? 'selected':'' ]}>SR（スナイパーライフル）
            <option value="MG" @{[ $pc{weaponType} eq 'MG' ? 'selected':'' ]}>MG（マシンガン）
            <option value="HG" @{[ $pc{weaponType} eq 'HG' ? 'selected':'' ]}>HG（ハンドガン）
            <option value="GL" @{[ $pc{weaponType} eq 'GL' ? 'selected':'' ]}>GL（グレネードランチャー）
            <option value="RG" @{[ $pc{weaponType} eq 'RG' ? 'selected':'' ]}>RG（レールガン）
            <option value="RL" @{[ $pc{weaponType} eq 'RL' ? 'selected':'' ]}>RL（ロケットランチャー）
            <option value="MT" @{[ $pc{weaponType} eq 'MT' ? 'selected':'' ]}>MT（モーター）
            <option value="FT" @{[ $pc{weaponType} eq 'FT' ? 'selected':'' ]}>FT（フレイムスロワー）
          </select>
        </dl>
        <dl class="box" id="position">
          <dt>隊列
          <dd><select name="position" onchange="applyPositionPreset()">
            <option value="フロント" @{[ $pc{position} eq 'フロント' ? 'selected':'' ]}>フロント
            <option value="ミドル" @{[ $pc{position} eq 'ミドル' ? 'selected':'' ]}>ミドル
            <option value="バッグ" @{[ $pc{position} eq 'バッグ' ? 'selected':'' ]}>バッグ
          </select>
        </dl>
        <dl class="box" id="attack-type">
          <dt>攻撃属性
          <dd><select name="attackType">
            <option value="">選択してください
            <option value="ノーマル" @{[ $pc{attackType} eq 'ノーマル' ? 'selected':'' ]}>ノーマル
            <option value="爆発" @{[ $pc{attackType} eq '爆発' ? 'selected':'' ]}>爆発
            <option value="貫通" @{[ $pc{attackType} eq '貫通' ? 'selected':'' ]}>貫通
            <option value="ストッピング" @{[ $pc{attackType} eq 'ストッピング' ? 'selected':'' ]}>ストッピング
            <option value="振動" @{[ $pc{attackType} eq '振動' ? 'selected':'' ]}>振動
            <option value="白兵" @{[ $pc{attackType} eq '白兵' ? 'selected':'' ]}>白兵
            <option value="神秘" @{[ $pc{attackType} eq '神秘' ? 'selected':'' ]}>神秘
          </select>
        </dl>
        <dl class="box" id="damage">
          <dt>攻撃ダメージ
          <dd>@{[ input 'damage', 'text', '', 'placeholder="2D"' ]}
        </dl>
        <dl class="box" id="hp-box">
          <dt>HP
          <dd>最大 @{[ input 'hpMax', 'number', '', 'style="width:3.5em;"' ]} / 現在 @{[ input 'hp', 'number', '', 'style="width:3.5em;"' ]}
        </dl>
        <dl class="box" id="tension-box">
          <dt>テンション
          <dd>最大 @{[ input 'tensionMax', 'number', '', 'style="width:3.5em;"' ]} / 現在 @{[ input 'tension', 'number', '', 'style="width:3.5em;"' ]}
        </dl>
        <dl class="box" id="weakness-box">
          <dt>弱点
          <dd><select name="weakness">
            <option value="">選択してください
            <option value="ノーマル" @{[ $pc{weakness} eq 'ノーマル' ? 'selected':'' ]}>ノーマル
            <option value="爆発" @{[ $pc{weakness} eq '爆発' ? 'selected':'' ]}>爆発
            <option value="貫通" @{[ $pc{weakness} eq '貫通' ? 'selected':'' ]}>貫通
            <option value="ストッピング" @{[ $pc{weakness} eq 'ストッピング' ? 'selected':'' ]}>ストッピング
            <option value="振動" @{[ $pc{weakness} eq '振動' ? 'selected':'' ]}>振動
            <option value="白兵" @{[ $pc{weakness} eq '白兵' ? 'selected':'' ]}>白兵
            <option value="神秘" @{[ $pc{weakness} eq '神秘' ? 'selected':'' ]}>神秘
          </select>
        </dl>
        <dl class="box" id="bullet-box">
          <dt>弾数 / 予備弾
          <dd>@{[ input 'bullet', 'number', '', 'style="width:3em;"' ]} / @{[ input 'bulletMax', 'number', '', 'style="width:3em;"' ]} (予備 @{[ input 'reserveBullet', 'number', '', 'style="width:3em;"' ]})
        </dl>
        <dl class="box" id="sp-box">
          <dt>SP
          <dd>最大 @{[ input 'spMax', 'number', '', 'style="width:3.5em;" placeholder="10"' ]} / 現在 @{[ input 'sp', 'number', '', 'style="width:3.5em;"' ]}
        </dl>
      </div>
    </div>

    <div class="box in-toc" id="section-abilities" data-content-title="能力値・タグ">
      <h2>能力値・タグ</h2>
      <table class="edit-table data-table" id="abilities-table">
        <thead>
          <tr>
            <th style="width:6.5em;">能力値</th>
            <th style="width:4.5em;">ダイス</th>
            <th>背景</th>
            <th>魅力</th>
            <th>キャラ</th>
            <th>趣味</th>
            <th>戦術</th>
          </tr>
        </thead>
        <tbody>
HTML

my @abilities = (
  { key => 'hanayaka', name => '華やか' },
  { key => 'daru',     name => 'だる' },
  { key => 'yuukan',   name => '勇敢' },
  { key => 'cool',     name => 'クール' },
  { key => 'sottyoku', name => '率直' },
  { key => 'himitsu',  name => '秘密主義' },
);

my @columns = (
  { key => 'haikei',    name => '背景' },
  { key => 'miryoku',   name => '魅力' },
  { key => 'chara',     name => 'キャラ' },
  { key => 'syumi',     name => '趣味' },
  { key => 'senjyutsu', name => '戦術' },
);

foreach my $ab (@abilities) {
  my $abKeyCapital = ucfirst($ab->{key});
  print "<tr><th>$ab->{name}</th>";
  print "<td style=\"text-align:center;\">" . input("ability$abKeyCapital", 'number', 'calcAbilities', 'style="width:3em;text-align:center;font-weight:bold;" min="0"') . "</td>";
  foreach my $col (@columns) {
    my $name = "tag_$ab->{key}_$col->{key}";
    print "<td>" . input($name, 'text', 'calcAbilities', 'style="width:100%;"') . "</td>";
  }
  print "</tr>\n";
}

print <<"HTML";
        </tbody>
        <tfoot>
          <tr class="total">
            <th>タグ合計</th>
            <th id="total-tags-count">0</th>
            <th colspan="5" style="text-align:left;padding-left:1em;font-weight:normal;color:#666;">※各行に入力されたタグの個数が自動的にダイス（能力値）として集計されます</th>
          </tr>
        </tfoot>
      </table>
    </div>

    <div class="box in-toc" id="section-skills" data-content-title="スキル">
      <h2>スキル</h2>
      <div class="skills-grid">
        <div class="skill-card skill-ex">
          <div class="skill-card-head">
            <h3>EXスキル</h3>
            <span class="skill-cost">コスト: @{[ input 'exSkillCost', 'number', '', 'style="width:3em;" placeholder="2"' ]}</span>
          </div>
          <dl>
            <dt>スキル名<dd>@{[ input 'exSkillName', 'text', '', 'placeholder="例）ドローン召喚：火力支援"' ]}
            <dt>効果<dd><textarea name="exSkillNote" rows="3" placeholder="効果を入力">$pc{exSkillNote}</textarea>
          </dl>
        </div>

        <div class="skill-card skill-weapon">
          <div class="skill-card-head">
            <h3>武装スキル</h3>
          </div>
          <dl>
            <dt>固有武器・武装名<dd>@{[ input 'weaponSkillName', 'text', '', 'placeholder="例）ロジック＆リーズン / WHITE FANG 465"' ]}
            <dt>効果<dd><textarea name="weaponSkillNote" rows="3" placeholder="効果を入力">$pc{weaponSkillNote}</textarea>
          </dl>
        </div>

        <div class="skill-card skill-fullburst">
          <div class="skill-card-head">
            <h3>フルバーストスキル</h3>
          </div>
          <dl>
            <dt>スキル名<dd>@{[ input 'fullBurstSkillName', 'text', '', 'placeholder="例）一点打撃"' ]}
            <dt>効果<dd><textarea name="fullBurstSkillNote" rows="3" placeholder="効果を入力">$pc{fullBurstSkillNote}</textarea>
          </dl>
        </div>

        <div class="skill-card skill-personal">
          <div class="skill-card-head">
            <h3>パーソナルスキル</h3>
          </div>
          <dl>
            <dt>スキル名<dd>@{[ input 'personalSkillName', 'text', '', 'placeholder="例）奇行"' ]}
            <dt>取得タグ<dd>@{[ input 'personalSkillTag', 'text', '', 'placeholder="例）マイペース"' ]}
            <dt>効果<dd><textarea name="personalSkillNote" rows="3" placeholder="効果を入力">$pc{personalSkillNote}</textarea>
          </dl>
        </div>
      </div>
    </div>

    <div class="box in-toc" id="section-reactions" data-content-title="リアクション表">
      <h2>リアクション表</h2>
      <table class="edit-table data-table">
        <thead>
          <tr><th style="width:4em;">出目</th><th>台詞 / リアクション</th></tr>
        </thead>
        <tbody>
          <tr><th>01</th><td>@{[ input 'reaction1', 'text', '', 'style="width:100%;" placeholder="例）ん。"' ]}</td></tr>
          <tr><th>02</th><td>@{[ input 'reaction2', 'text', '', 'style="width:100%;" placeholder="例）襲おう。"' ]}</td></tr>
          <tr><th>03</th><td>@{[ input 'reaction3', 'text', '', 'style="width:100%;" placeholder="例）なら勝負しよう。"' ]}</td></tr>
          <tr><th>04</th><td>@{[ input 'reaction4', 'text', '', 'style="width:100%;" placeholder="例）私より弱い人には従わない。"' ]}</td></tr>
          <tr><th>05</th><td>@{[ input 'reaction5', 'text', '', 'style="width:100%;" placeholder="例）火力支援を始める。"' ]}</td></tr>
          <tr><th>06</th><td>@{[ input 'reaction6', 'text', '', 'style="width:100%;" placeholder="例）作戦、完璧だったはずなのに……。"' ]}</td></tr>
        </tbody>
      </table>
    </div>

    <div class="box in-toc" id="section-friends" data-content-title="お友達・知り合い">
      <h2>お友達・知り合い</h2>
      <h3>お友達</h3>
      <table class="edit-table data-table" id="friends-table">
        <thead>
          <tr>
            <th>名前</th>
            <th>呼び方</th>
            <th style="width:5em;">感情値</th>
            <th style="width:5em;">関係</th>
            <th style="width:4em;">応援</th>
          </tr>
        </thead>
        <tbody id="friends-list">
HTML

for my $num (1 .. ($pc{friendNum} || 3)) {
  print <<"HTML";
          <tr id="friend-row-$num">
            <td>@{[ input "friend${num}Name", 'text', '', 'placeholder="名前"' ]}</td>
            <td>@{[ input "friend${num}Calling", 'text', '', 'placeholder="呼び方"' ]}</td>
            <td>@{[ input "friend${num}Emotion", 'number', '', 'style="width:100%;"' ]}</td>
            <td>
              <select name="friend${num}Relation">
                <option value="+" @{[ $pc{"friend${num}Relation"} eq '+' ? 'selected':'' ]}>+</option>
                <option value="-" @{[ $pc{"friend${num}Relation"} eq '-' ? 'selected':'' ]}>-</option>
              </select>
            </td>
            <td style="text-align:center;"><input type="checkbox" name="friend${num}Support" value="1" @{[ $pc{"friend${num}Support"} ? 'checked':'' ]}></td>
          </tr>
HTML
}

print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addFriend()">▼</a><a onclick="delFriend()">▲</a></div>
      @{[ input 'friendNum', 'hidden' ]}

      <h3 style="margin-top:20px;">知り合い</h3>
      <table class="edit-table data-table" id="acquaintance-table">
        <thead>
          <tr>
            <th>名前</th>
            <th>呼び方</th>
            <th style="width:5em;">感情値</th>
            <th style="width:5em;">関係</th>
            <th style="width:4em;">応援</th>
          </tr>
        </thead>
        <tbody id="acquaintance-list">
HTML

for my $num (1 .. ($pc{acquaintanceNum} || 3)) {
  print <<"HTML";
          <tr id="acquaintance-row-$num">
            <td>@{[ input "acquaintance${num}Name", 'text', '', 'placeholder="名前"' ]}</td>
            <td>@{[ input "acquaintance${num}Calling", 'text', '', 'placeholder="呼び方"' ]}</td>
            <td>@{[ input "acquaintance${num}Emotion", 'number', '', 'style="width:100%;"' ]}</td>
            <td>
              <select name="acquaintance${num}Relation">
                <option value="+" @{[ $pc{"acquaintance${num}Relation"} eq '+' ? 'selected':'' ]}>+</option>
                <option value="-" @{[ $pc{"acquaintance${num}Relation"} eq '-' ? 'selected':'' ]}>-</option>
              </select>
            </td>
            <td style="text-align:center;"><input type="checkbox" name="acquaintance${num}Support" value="1" @{[ $pc{"acquaintance${num}Support"} ? 'checked':'' ]}></td>
          </tr>
HTML
}

print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addAcquaintance()">▼</a><a onclick="delAcquaintance()">▲</a></div>
      @{[ input 'acquaintanceNum', 'hidden' ]}
    </div>

    <div class="box in-toc" id="section-freenote" data-content-title="容姿・経歴・その他メモ">
      <h2>容姿・経歴・その他メモ</h2>
      <textarea name="freeNote" rows="10" style="width:100%;" placeholder="設定、経歴、メモなどを自由に入力できます">$pc{freeNote}</textarea>
    </div>

    <div class="box in-toc" id="section-history" data-content-title="セッション履歴">
      <h2>セッション履歴</h2>
      <table class="edit-table data-table" id="history-table">
        <thead>
          <tr>
            <th style="width:3em;">No.</th>
            <th style="width:8em;">日付</th>
            <th>タイトル</th>
            <th style="width:7em;">GM</th>
            <th>参加者</th>
            <th>メモ</th>
          </tr>
        </thead>
        <tbody id="history-list">
HTML

for my $num (1 .. ($pc{historyNum} || 3)) {
  print <<"HTML";
          <tr id="history-row-$num">
            <td style="text-align:center;">$num</td>
            <td>@{[ input "history${num}Date", 'text', '', 'placeholder="日付"' ]}</td>
            <td>@{[ input "history${num}Title", 'text', '', 'placeholder="タイトル"' ]}</td>
            <td>@{[ input "history${num}Gm", 'text', '', 'placeholder="GM名"' ]}</td>
            <td>@{[ input "history${num}Member", 'text', '', 'placeholder="参加者"' ]}</td>
            <td>@{[ input "history${num}Note", 'text', '', 'placeholder="メモ"' ]}</td>
          </tr>
HTML
}

print <<"HTML";
        </tbody>
      </table>
      <div class="add-del-button"><a onclick="addHistory()">▼</a><a onclick="delHistory()">▲</a></div>
      @{[ input 'historyNum', 'hidden' ]}
    </div>
  </section>

  <section id="section-palette" style="display:none;">
    <div class="box">
      <h2>チャットパレット</h2>
      <dl>
        <dt>チャットパレット出力設定
        <dd>
          <label class="check-button"><input type="checkbox" name="paletteUseBuff" value="1" @{[ $pc{paletteUseBuff} ? 'checked':'' ]}><span>バフ・コマンドを出力する</span></label>
          <label class="check-button"><input type="checkbox" name="paletteUseVar" value="1" @{[ $pc{paletteUseVar} ? 'checked':'' ]}><span>能力値を変数として出力する</span></label>
        <dt>パレット内容（プレビュー・手動編集）
        <dd>
          <textarea name="chatPalette" rows="20" style="width:100%;font-family:monospace;">$pc{chatPalette}</textarea>
      </dl>
    </div>

    <div class="box">
      <h2>ココフォリア コマ（ユニット）設定</h2>
      <dl>
        <dt>ステータス非出力項目
        <dd>@{[ input 'unitStatusNotOutput', 'text', '', 'placeholder="例）SP,予備弾"' ]}
      </dl>
    </div>
  </section>
HTML

print renderEditPageEnd(
  notes => '「学園×青春×連携攻撃TRPG アフターアーカイブ」',
);

1;
