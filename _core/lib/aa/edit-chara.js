"use strict";

const gameSystem = 'aa';

// 銃種データプリセット
const weaponPresets = {
  'SMG': {
    position: 'フロント',
    attackTypes: ['ノーマル', 'ストッピング'],
    attackTypeDefault: 'ノーマル',
    bulletMax: 2,
    damage: '2D-1',
    hp: 33,
    tension: 10,
    weakness: 'ストッピング',
    weaponSkillName: 'サブマシンガン',
    weaponSkillNote: '各ラウンドの開始時に「予備弾」を1個獲得する。予備弾は攻撃には使用できないが、攻撃判定を行った後に予備弾または弾数を1発消費することで判定に再挑戦することができる。',
    fullBurstSkillName: '援護射撃',
    fullBurstSkillNote: '連携攻撃中、バーストではない敵への攻撃でもサイコロの出目が5の場合、クリティカルが発生する。'
  },
  'AR': {
    position: 'ミドル',
    attackTypes: ['爆発', '貫通'],
    attackTypeDefault: '爆発',
    bulletMax: 2,
    damage: '2D',
    hp: 25,
    tension: 12,
    weakness: '貫通',
    weaponSkillName: 'アサルトライフル',
    weaponSkillNote: '各ラウンドの開始時に「予備弾」を1個獲得する。予備弾は攻撃には使用できないが、攻撃に成功しダメージを与えた後に予備弾または弾数を1発消費することでダメージに+2Dできる。',
    fullBurstSkillName: '一点打撃',
    fullBurstSkillNote: 'F.B.攻撃判定成功時、即座に敵1体を指定する。その敵を「バースト」状態とする。'
  },
  'SG': {
    position: 'フロント',
    attackTypes: ['振動', '白兵'],
    attackTypeDefault: '振動',
    bulletMax: 2,
    damage: '2D+1',
    hp: 33,
    tension: 10,
    weakness: '振動',
    weaponSkillName: 'ショットガン',
    weaponSkillNote: '「近接エリア」にいるとき、ダメージに+2Dされる。',
    fullBurstSkillName: '散開作戦',
    fullBurstSkillNote: 'F.B.攻撃判定直前、すべてのキャラクターは即座に「近接エリア」または「カバーエリア」に移動することができる。'
  },
  'SR': {
    position: 'バッグ',
    attackTypes: ['爆発', '貫通'],
    attackTypeDefault: '貫通',
    bulletMax: 2,
    damage: '2D+3',
    hp: 15,
    tension: 16,
    weakness: '貫通',
    weaponSkillName: 'スナイパーライフル',
    weaponSkillNote: '「ショック」状態の敵を攻撃するとき、命中判定の出目が5であってもクリティカルが発生する。',
    fullBurstSkillName: '弱点狙撃',
    fullBurstSkillNote: 'F.B.攻撃判定成功時、敵1体を選び、対象に任意の攻撃タイプ1つを弱点として付与する（神秘は選べない）。この効果は銃撃戦の間持続する。'
  },
  'MG': {
    position: 'ミドル',
    attackTypes: ['ストッピング', '振動'],
    attackTypeDefault: 'ストッピング',
    bulletMax: 2,
    damage: '3D-4',
    hp: 25,
    tension: 12,
    weakness: 'ストッピング',
    weaponSkillName: 'マシンガン',
    weaponSkillNote: '連携攻撃中、自分がまた攻撃した場合、1回だけ弾丸を消費せずに攻撃できる。',
    fullBurstSkillName: '無差別乱射',
    fullBurstSkillNote: 'F.B.攻撃判定成功時、このF.B.のダメージで振ったダイスの出目と同じ数字の敵エリアのカバーを破壊する。'
  },
  'HG': {
    position: 'フロント',
    attackTypes: ['ノーマル', '白兵'],
    attackTypeDefault: 'ノーマル',
    bulletMax: 2,
    damage: '2D-2',
    hp: 33,
    tension: 10,
    weakness: 'ストッピング',
    weaponSkillName: 'ハンドガン',
    weaponSkillNote: 'セッション開始時にポジションを任意で選ぶことができる。またアイテム（補助武器）を2つまで持つことができる。「近接エリア」にいるとき、ダメージに+1D。',
    fullBurstSkillName: '後方支援',
    fullBurstSkillNote: '即座にSPを5回復し、自身のEXスキルを使用することができる。'
  },
  'GL': {
    position: 'ミドル',
    attackTypes: ['ノーマル', '貫通'],
    attackTypeDefault: '貫通',
    bulletMax: 1,
    damage: '2D',
    hp: 25,
    tension: 12,
    weakness: '爆発',
    weaponSkillName: 'グレネードランチャー',
    weaponSkillNote: '攻撃するとき対象を選択しない代わりに、攻撃判定のサイコロを1つ選び、その出目と同じ数字のエリアを対象とし、エリア内の全キャラクターにダメージを与える。',
    fullBurstSkillName: '広域爆破',
    fullBurstSkillNote: '任意のカバーエリアを全選択する。そのエリアにいるすべてのキャラクターを「近接エリア」に移動させる。'
  },
  'RG': {
    position: 'バッグ',
    attackTypes: ['貫通', '白兵'],
    attackTypeDefault: '貫通',
    bulletMax: 2,
    damage: '2D+2',
    hp: 15,
    tension: 16,
    weakness: '貫通',
    weaponSkillName: 'レールガン',
    weaponSkillNote: '最大弾数を超えて弾数を取得できる。攻撃時：全弾消費で消費弾数×1D追加、または攻撃の代わりに難易度4判定でチャージ（成功で弾1発獲得）。',
    fullBurstSkillName: '過充電一撃',
    fullBurstSkillNote: 'F.B.のダメージは[連携数D]になる。'
  },
  'RL': {
    position: 'バッグ',
    attackTypes: ['爆発', 'ストッピング'],
    attackTypeDefault: '爆発',
    bulletMax: 2,
    damage: '2D+6',
    hp: 15,
    tension: 16,
    weakness: '爆発',
    weaponSkillName: 'ロケットランチャー',
    weaponSkillNote: '2ラウンド以降のリロード時に1発だけリロードされる（1ラウンド目は2発）。攻撃時：エリア指定（エリア内全員ダメージ）または命中判定なし命中扱い（弱点突きのクリティカル扱い・連携ダイス選択不可）。',
    fullBurstSkillName: '集束爆破',
    fullBurstSkillNote: 'F.B.ダメージのダイス目と同じ数字の敵エリアの敵全部を「ブレイク」させる。'
  },
  'MT': {
    position: 'バッグ',
    attackTypes: ['爆発', '振動'],
    attackTypeDefault: '爆発',
    bulletMax: 2,
    damage: '3D',
    hp: 15,
    tension: 16,
    weakness: '爆発',
    weaponSkillName: 'モーター',
    weaponSkillNote: 'エリアを攻撃対象とし、そのエリアにいるすべてのキャラクターにダメージを与える。この武器を使用するキャラクターはラウンド終了時の移動を行わない。',
    fullBurstSkillName: '地形破壊',
    fullBurstSkillNote: 'カバーエリアを1つ選ぶ。そのエリアは銃撃戦の間「封鎖」される。'
  },
  'FT': {
    position: 'フロント',
    attackTypes: ['ノーマル', '振動'],
    attackTypeDefault: 'ノーマル',
    bulletMax: 4,
    damage: '1D',
    hp: 33,
    tension: 10,
    weakness: '振動',
    weaponSkillName: 'フレイムスロワー',
    weaponSkillNote: '弾数4発。「カバーエリア」で使って攻撃した場合、射程ペナルティが2倍になる。',
    fullBurstSkillName: '火焰鎮圧',
    fullBurstSkillNote: '1〜5の敵近接エリアにいるすべてのキャラクターを「ブレイク」させる。'
  }
};

// ポジションプリセット
const positionPresets = {
  'フロント': { hp: 33, tension: 10, weakness: 'ストッピング' },
  'ミドル':   { hp: 25, tension: 12, weakness: '爆発' },
  'バッグ':   { hp: 15, tension: 16, weakness: '貫通' }
};

// 銃種選択時の自動補完
function applyWeaponPreset() {
  const typeSelect = document.querySelector('select[name="weaponType"]');
  if (!typeSelect) return;
  const val = typeSelect.value;
  const data = weaponPresets[val];
  if (!data) return;

  const setIfEmptyOrConfirm = (name, value) => {
    const input = document.querySelector(`input[name="${name}"], select[name="${name}"], textarea[name="${name}"]`);
    if (input) {
      input.value = value;
    }
  };

  setIfEmptyOrConfirm('position', data.position);
  setIfEmptyOrConfirm('bulletMax', data.bulletMax);
  setIfEmptyOrConfirm('bullet', data.bulletMax);
  setIfEmptyOrConfirm('damage', data.damage);
  setIfEmptyOrConfirm('hpMax', data.hp);
  setIfEmptyOrConfirm('hp', data.hp);
  setIfEmptyOrConfirm('tensionMax', data.tension);
  setIfEmptyOrConfirm('tension', data.tension);
  setIfEmptyOrConfirm('weakness', data.weakness);

  const attackSelect = document.querySelector('select[name="attackType"]');
  if (attackSelect && (!attackSelect.value || attackSelect.value === '')) {
    attackSelect.value = data.attackTypeDefault;
  }

  const weaponSkillInput = document.querySelector('input[name="weaponSkillName"]');
  if (weaponSkillInput && !weaponSkillInput.value) {
    weaponSkillInput.value = data.weaponSkillName;
  }
  const weaponSkillNote = document.querySelector('textarea[name="weaponSkillNote"]');
  if (weaponSkillNote && !weaponSkillNote.value) {
    weaponSkillNote.value = data.weaponSkillNote;
  }

  const fbSkillInput = document.querySelector('input[name="fullBurstSkillName"]');
  if (fbSkillInput && !fbSkillInput.value) {
    fbSkillInput.value = data.fullBurstSkillName;
  }
  const fbSkillNote = document.querySelector('textarea[name="fullBurstSkillNote"]');
  if (fbSkillNote && !fbSkillNote.value) {
    fbSkillNote.value = data.fullBurstSkillNote;
  }
}

// ポジション選択時の自動補完
function applyPositionPreset() {
  const posSelect = document.querySelector('select[name="position"]');
  if (!posSelect) return;
  const val = posSelect.value;
  const data = positionPresets[val];
  if (!data) return;

  const hpMax = document.querySelector('input[name="hpMax"]');
  const hp = document.querySelector('input[name="hp"]');
  const tensionMax = document.querySelector('input[name="tensionMax"]');
  const tension = document.querySelector('input[name="tension"]');
  const weakness = document.querySelector('input[name="weakness"]');

  if (hpMax) hpMax.value = data.hp;
  if (hp && (!hp.value || hp.value === '0')) hp.value = data.hp;
  if (tensionMax) tensionMax.value = data.tension;
  if (tension && (!tension.value || tension.value === '0')) tension.value = data.tension;
  if (weakness) weakness.value = data.weakness;
}

// 能力値・タグの集計
function calcAbilities() {
  const abilities = ['hanayaka', 'daru', 'yuukan', 'cool', 'sottyoku', 'himitsu'];
  const columns = ['haikei', 'miryoku', 'chara', 'syumi', 'senjyutsu'];

  let totalTags = 0;

  abilities.forEach(ab => {
    let count = 0;
    columns.forEach(col => {
      const nameInput = document.querySelector(`input[name="tag_${ab}_${col}"]`);
      if (nameInput && nameInput.value.trim() !== '') {
        count++;
        totalTags++;
      }
    });

    const diceInput = document.querySelector(`input[name="ability${ab.charAt(0).toUpperCase() + ab.slice(1)}"]`);
    if (diceInput && !diceInput.dataset.manual) {
      diceInput.value = count;
    }
  });

  const totalEl = document.getElementById('total-tags-count');
  if (totalEl) totalEl.textContent = totalTags;
}

// お友達追加・削除
function addFriend() {
  const numInput = document.querySelector('input[name="friendNum"]');
  let num = parseInt(numInput.value || 0, 10) + 1;
  numInput.value = num;

  const tbody = document.getElementById('friends-list');
  const tr = document.createElement('tr');
  tr.id = `friend-row-${num}`;
  tr.innerHTML = `
    <td><input type="text" name="friend${num}Name" placeholder="名前"></td>
    <td><input type="text" name="friend${num}Calling" placeholder="呼び方"></td>
    <td><input type="number" name="friend${num}Emotion" min="0" style="width:100%"></td>
    <td>
      <select name="friend${num}Relation">
        <option value="+">+</option>
        <option value="-">-</option>
      </select>
    </td>
    <td style="text-align:center;"><input type="checkbox" name="friend${num}Support" value="1"></td>
  `;
  tbody.appendChild(tr);
}

function delFriend() {
  const numInput = document.querySelector('input[name="friendNum"]');
  let num = parseInt(numInput.value || 0, 10);
  if (num <= 1) return;
  const row = document.getElementById(`friend-row-${num}`);
  if (row) row.remove();
  numInput.value = num - 1;
}

// 知り合い追加・削除
function addAcquaintance() {
  const numInput = document.querySelector('input[name="acquaintanceNum"]');
  let num = parseInt(numInput.value || 0, 10) + 1;
  numInput.value = num;

  const tbody = document.getElementById('acquaintances-list');
  const tr = document.createElement('tr');
  tr.id = `acquaintance-row-${num}`;
  tr.innerHTML = `
    <td><input type="text" name="acquaintance${num}Name" placeholder="名前"></td>
    <td><input type="text" name="acquaintance${num}Calling" placeholder="呼び方"></td>
    <td><input type="number" name="acquaintance${num}Emotion" min="0" style="width:100%"></td>
    <td>
      <select name="acquaintance${num}Relation">
        <option value="+">+</option>
        <option value="-">-</option>
      </select>
    </td>
    <td style="text-align:center;"><input type="checkbox" name="acquaintance${num}Support" value="1"></td>
  `;
  tbody.appendChild(tr);
}

function delAcquaintance() {
  const numInput = document.querySelector('input[name="acquaintanceNum"]');
  let num = parseInt(numInput.value || 0, 10);
  if (num <= 1) return;
  const row = document.getElementById(`acquaintance-row-${num}`);
  if (row) row.remove();
  numInput.value = num - 1;
}

// 履歴追加・削除
function addHistory() {
  const numInput = document.querySelector('input[name="historyNum"]');
  let num = parseInt(numInput.value || 0, 10) + 1;
  numInput.value = num;

  const tbody = document.getElementById('history-list');
  const tr = document.createElement('tr');
  tr.id = `history-row-${num}`;
  tr.innerHTML = `
    <td>${num}</td>
    <td><input type="text" name="history${num}Date" placeholder="日付"></td>
    <td><input type="text" name="history${num}Title" placeholder="タイトル"></td>
    <td><input type="text" name="history${num}Gm" placeholder="GM名"></td>
    <td><input type="text" name="history${num}Member" placeholder="参加者"></td>
    <td><input type="text" name="history${num}Note" placeholder="メモ"></td>
  `;
  tbody.appendChild(tr);
}

function delHistory() {
  const numInput = document.querySelector('input[name="historyNum"]');
  let num = parseInt(numInput.value || 0, 10);
  if (num <= 1) return;
  const row = document.getElementById(`history-row-${num}`);
  if (row) row.remove();
  numInput.value = num - 1;
}

// 初期化
window.addEventListener('load', () => {
  try {
    setName();
    calcAbilities();
  } catch (e) {
    console.error(e);
  } finally {
    deleteLoadingArea();
  }
});
