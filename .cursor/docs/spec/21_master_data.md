---
title: "装備・スキル マスターデータ（初期版）"
free: false
---

## 📦 装備・スキル マスターデータ（初期版）

---

### ✅ SSR装備一覧（例：各カテゴリから1件ずつ）

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
    "associatedSkillIds": ["SKL002", "SKL005"]
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
    "associatedSkillIds": ["SKL003"]
  }
]
```

---

### ✅ スキル一覧（例：4件）

```json
[
  {
    "id": "SKL001",
    "name": "無音疾風",
    "description": "終盤、静かに加速し順位を上げやすくなる",
    "effect": { "timing": "final", "bonusType": "speed", "value": 15 },
    "condition": { "trigger": "when_losing", "position": "mid", "section": "final" },
    "categoryTags": ["速力系"],
    "requiredTraining": ["速力", "技術"],
    "progressThreshold": 5
  },
  {
    "id": "SKL002",
    "name": "静心制圧",
    "description": "中盤、精神が安定して展開を読む力が強まる",
    "effect": { "timing": "middle", "bonusType": "control", "value": 10 },
    "condition": { "trigger": "always", "section": "middle" },
    "categoryTags": ["精神系", "展開系"],
    "requiredTraining": ["精神", "展開"],
    "progressThreshold": 5
  },
  {
    "id": "SKL003",
    "name": "柔式転身",
    "description": "スタート時、柔軟な動きで有利な位置を取る",
    "effect": { "timing": "start", "bonusType": "control", "value": 8 },
    "condition": { "trigger": "always", "section": "early" },
    "categoryTags": ["柔軟系"],
    "requiredTraining": ["柔軟", "精神"],
    "progressThreshold": 5
  },
  {
    "id": "SKL005",
    "name": "心身統合",
    "description": "終盤で集中を保ちつつスタミナ消費を抑える",
    "effect": { "timing": "final", "bonusType": "stamina", "value": 12 },
    "condition": { "trigger": "low_stamina", "section": "final" },
    "categoryTags": ["精神系", "持久系"],
    "requiredTraining": ["精神", "持久"],
    "progressThreshold": 5
  }
]
```

---

このデータは初期開発・UI実装・スキル進行ロジックテストに使える最小構成のマスターデータとなります。
追加スキルや装備は、この構造をもとに順次拡張していくことが可能です。