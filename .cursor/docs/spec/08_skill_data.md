---
title: "スキルデータ仕様書（構造・一覧例）"
free: false
---

## 📊 スキルデータ仕様書（構造・一覧例）

---

### ✅ スキルデータ構造（1件あたりの定義）

```ts
Skill {
  id: string;              // スキルID（例：SKL001）
  name: string;            // 表示名（例：無音疾風）
  description: string;     // 効果説明文
  effect: SkillEffect;     // レース中の効果（例：終盤加速+10）
  condition: SkillCondition; // 発動条件（例：終盤／3位以下）
  categoryTags: string[];  // タグ（速力系、精神系など）
  requiredTraining: string[]; // 開花に必要なカテゴリ（例：['速力', '精神']）
  progressThreshold: number; // 開花に必要な進行ポイント（例：5）
  rarity?: 'normal' | 'rare' | 'secret';
  unlockedBy?: string[];   // 習得可能な装備ID一覧
}
```

---

### ✅ SkillEffect構造（例）

```ts
SkillEffect {
  timing: 'start' | 'early' | 'middle' | 'final';
  bonusType: 'speed' | 'stamina' | 'control' | 'score';
  value: number;  // 加点 or 補正量（例：+10）
  duration?: number;  // 持続ターン（秒数換算 or 区間数）
  notes?: string;  // 補足説明（例：条件下のみ発動）
}
```

---

### ✅ SkillCondition構造（例）

```ts
SkillCondition {
  trigger: 'always' | 'when_losing' | 'when_ahead' | 'low_stamina';
  position?: 'top' | 'mid' | 'bottom';
  section?: 'early' | 'middle' | 'final';
}
```

---

### ✅ スキルデータ例（3種）

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
  }
]
```

---

この仕様により、スキルデータは構造化されてゲーム処理・演出・UI表示・条件ロジックに一貫して活用できます。
スキル図鑑や習得制限、レアスキル管理にもスムーズに連携可能です。