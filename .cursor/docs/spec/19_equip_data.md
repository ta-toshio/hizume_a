---
title: "装備データ仕様書（騎手・馬・導法書）"
free: false
---

## 🧾 装備データ仕様書（騎手・馬・導法書）

---

### ✅ 1. 装備の基本構造

```ts
Equipment {
  id: string;
  name: string;
  category: 'rider' | 'horse' | 'manual';
  rarity: 'SSR';
  effect: EquipmentEffect[];
  relatedTraining: string; // カテゴリ（例：速力、展開など）
  associatedSkillIds: string[]; // スキル候補（最大3）
  flavorText?: string;
}

EquipmentEffect {
  type: 'trainingBoost' | 'skillSupport' | 'eventBuff';
  value: number; // % or 固定値
  condition?: string; // 条件（共鳴時のみ、熟度Lv2以上など）
}
```

---

### ✅ 2. カテゴリ分類と役割

| カテゴリ | 対象        | 効果の方向性             |
| ---- | --------- | ------------------ |
| 騎手装備 | 育成者の型や構え  | トレーニング効果UP・熟度補正    |
| 馬装備  | 馬の資質や状態制御 | 疲労緩和・共鳴率UP・スキル発動補正 |
| 導法書  | 流派の奥義伝承   | スキル進行加速・共鳴条件緩和     |

---

### ✅ 3. データ例（3種）

```json
[
  {
    "id": "EQ001",
    "name": "静心の装束",
    "category": "rider",
    "rarity": "SSR",
    "relatedTraining": "精神",
    "effect": [
      { "type": "trainingBoost", "value": 15 },
      { "type": "skillSupport", "value": 1, "condition": "熟度Lv2以上" }
    ],
    "associatedSkillIds": ["SKL002", "SKL010"]
  },
  {
    "id": "EQ011",
    "name": "無音蹄",
    "category": "horse",
    "rarity": "SSR",
    "relatedTraining": "速力",
    "effect": [
      { "type": "trainingBoost", "value": 10 },
      { "type": "eventBuff", "value": 20, "condition": "イベント発生時" }
    ],
    "associatedSkillIds": ["SKL001"]
  },
  {
    "id": "EQ021",
    "name": "柔走体捌の書",
    "category": "manual",
    "rarity": "SSR",
    "relatedTraining": "柔軟",
    "effect": [
      { "type": "skillSupport", "value": 2 },
      { "type": "trainingBoost", "value": 5 }
    ],
    "associatedSkillIds": ["SKL003", "SKL012"]
  }
]
```

---

### ✅ 4. UI表示要素

| 項目      | 表示内容                          |
| ------- | ----------------------------- |
| アイコン    | 装備イラスト（巻物・馬具・衣装など）            |
| 名前・カテゴリ | SSR枠色（紫〜金）＋分類マーク              |
| 関連カテゴリ  | アイコンで「速力」など表示                 |
| 効果一覧    | 数値＋条件付きテキスト表示（例：「共鳴時さらに+10%」） |
| スキル候補   | 表示 or 非表示（選択前は？表示も可）          |

---

このデータ仕様により、装備ごとの育成効果・スキルとの関係・カテゴリ連携を一貫して設計・実装・UI提示まで統合できます。