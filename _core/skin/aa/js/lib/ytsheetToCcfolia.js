"use strict";

var output = output || {};

output.generateCcfoliaJsonOfAfterArchivePC = (json, character, defaultPalette) => {
  character.name = json.namePlate || json.characterName;
  
  character.memo = '';
  character.memo += json.aka ? `“${json.aka}”\n` : '';
  character.memo += json.namePlate ? json.characterName + "\n" : '';
  character.memo += json.characterNameRuby ? '(' + json.characterNameRuby + ')\n' : '';
  character.memo += `PL: ${json.playerName || 'PL情報無し'}\n`;
  const weaponStr = json.weaponName ? `${json.weaponName} (${json.weaponType || ''} / ${json.attackType || ''})` : `${json.weaponType || ''} (${json.attackType || ''})`;
  character.memo += `ポジション: ${json.position || ''} / 武器: ${weaponStr}\n`;
  character.memo += `弱点: ${json.weakness || ''}\n`;
  character.memo += `\n`;
  character.memo += `${json.imageURL ? '立ち絵: ' + (json.imageCopyright || '権利情報なし') : ''}`;

  // ステータス（現在値 / 最大値）
  character.status = [
    { label: 'HP', value: Number(json.hp || json.hpMax || 25), max: Number(json.hpMax || 25) },
    { label: 'テンション', value: Number(json.tension || json.tensionMax || 12), max: Number(json.tensionMax || 12) },
    { label: 'SP', value: Number(json.sp || 0), max: Number(json.spMax || 10) },
    { label: '弾数', value: Number(json.bullet || json.bulletMax || 2), max: Number(json.bulletMax || 2) },
  ];

  // パラメータ（能力値など）
  character.params = character.params.concat(defaultPalette.parameters || []);

  return character;
};
