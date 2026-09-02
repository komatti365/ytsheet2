"use strict";

var output = output || {};

output.generateCharacterTextOfAfterArchivePC = (json) => {
  const result = [];
  
  result.push(`キャラクター名：${json.characterName || ''}${json.aka ? '（“' + json.aka + '”）' : ''}
プレイヤー名　：${json.playerName || ''}

所属学園：${json.school || ''} ${json.grade || ''}
部活　　：${json.club || ''}
性別　　：${json.gender || ''}
年齢　　：${json.age || ''}
身長　　：${json.height || ''}

【HP】：${json.hp || json.hpMax || 25} / ${json.hpMax || 25}
【テンション】：${json.tension || json.tensionMax || 12} / ${json.tensionMax || 12}
【SP】：${json.sp || 0} / ${json.spMax || 10}
【ポジション】：${json.position || ''}
【銃種】：${json.weaponType || ''}（${json.attackType || ''}）
【弱点】：${json.weakness || ''}
【弾数】：${json.bullet || json.bulletMax || 2} / ${json.bulletMax || 2}

■能力値・タグ■
・華やか　：${json.abilityHanayaka || 0}
・だる　　：${json.abilityDaru || 0}
・勇敢　　：${json.abilityYuukan || 0}
・クール　：${json.abilityCool || 0}
・率直　　：${json.abilitySottyoku || 0}
・秘密主義：${json.abilityHimitsu || 0}

■スキル■
・EXスキル　　　　：${json.exSkillName || ''} (コスト:${json.exSkillCost || ''})
${(json.exSkillNote || '').replace(/<br>/g, '\n')}
・武装スキル　　　：${json.weaponSkillName || ''}
${(json.weaponSkillNote || '').replace(/<br>/g, '\n')}
・フルバースト　　：${json.fullBurstSkillName || ''}
${(json.fullBurstSkillNote || '').replace(/<br>/g, '\n')}
・パーソナルスキル：${json.personalSkillName || ''}
${(json.personalSkillNote || '').replace(/<br>/g, '\n')}

■リアクション表■
[01] ${(json.reaction1 || '').replace(/<br>/g, ' ')}
[02] ${(json.reaction2 || '').replace(/<br>/g, ' ')}
[03] ${(json.reaction3 || '').replace(/<br>/g, ' ')}
[04] ${(json.reaction4 || '').replace(/<br>/g, ' ')}
[05] ${(json.reaction5 || '').replace(/<br>/g, ' ')}
[06] ${(json.reaction6 || '').replace(/<br>/g, ' ')}

■容姿・経歴・その他メモ■
${(json.freeNote || '').replace(/<br>/g, '\n')}
`);

  return result.join('\n');
};
