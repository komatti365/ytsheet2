"use strict";

var output = output || {};

output.generateUdonariumXmlDetailOfAfterArchivePC = (json, opt_url, defaultPalette, resources) => {
  const dataDetails = { 'リソース': resources };

  dataDetails['情報'] = [
    `        <data name="PL">${json.playerName || '?'}</data>`,
    `        <data name="所属学園">${json.school || ''}</data>`,
    `        <data name="学年">${json.grade || ''}</data>`,
    `        <data name="部活">${json.club || ''}</data>`,
    `        <data name="年齢">${json.age || ''}</data>`,
    `        <data name="性別">${json.gender || ''}</data>`,
    `        <data name="ポジション">${json.position || ''}</data>`,
    `        <data name="銃種">${json.weaponType || ''}</data>`,
    `        <data name="攻撃タイプ">${json.attackType || ''}</data>`,
    `        <data name="弱点">${json.weakness || ''}</data>`,
    `        <data type="note" name="説明">${(json.freeNote || '').replace(/<br>/g, '\n')}</data>`
  ];
  if(opt_url) { dataDetails['情報'].push(`        <data name="URL">${opt_url}</data>`); }

  return dataDetails;
};
