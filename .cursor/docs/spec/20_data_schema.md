---
title: "データスキーマ設計書（キャラ／装備／スキル／育成進行）"
free: false
---

## 🗂️ データスキーマ設計書（キャラ／装備／スキル／育成進行）

---

### ✅ 1. キャラクター（育成馬）

```ts
Horse {
  id: string;
  name: string;
  baseStats: StatBlock;        // 初期ステータス
  growthRates: StatBlock;      // ステごとの成長補正係数（％）
  aptitude: string[];          // 得意カテゴリ（例：速力、柔軟）
  storyFlags?: string[];       // イベント用フラグ
}

StatBlock {
  speed: number;
  stamina: number;
  power: number;
  mind: number;
  intellect: number;
  technique: number;
  reaction: number;
  flexibility: number;
  balance: number;
  focus: number;
  adaptability: number;
  judgment: number;
}
```

---

### ✅ 2. 装備データ

※ 詳細は別仕様「装備データ仕様書」参照

```ts
Equipment {
  id: string;
  name: string;
  category: 'rider' | 'horse' | 'manual';
  rarity: 'SSR';
  relatedTraining: string;
  effect: EquipmentEffect[];
  associatedSkillIds: string[];
}
```

---

### ✅ 3. スキルデータ

※ 詳細は「スキルデータ仕様書」参照

```ts
Skill {
  id: string;
  name: string;
  description: string;
  effect: SkillEffect;
  condition: SkillCondition;
  categoryTags: string[];
  requiredTraining: string[];
  progressThreshold: number;
}
```

---

### ✅ 4. 育成進行データ

```ts
TrainingProgress {
  turn: number;
  dateLabel: string;        // "3歳4月" 等
  fatigue: number;
  chakraFlow: string;       // 当月のチャクラ気配カテゴリ
  selectedTraining: string; // トレーニングID
  status: StatBlock;        // 各ターン後のステータス
  skillProgress: { [skillId: string]: number }; // スキルごとの進行状況
  resonanceGauge: number;   // 補助ゲージ（0〜5）
  categoryCount: { [trainingCategory: string]: number }; // 各カテゴリの実行回数
  equipmentFamiliarity: { [equipmentId: string]: number }; // 熟度pt
  eventLog?: string[];      // 発生したイベントIDログ
}
```

---

### ✅ 5. プレイヤー育成ログ

```ts
TrainingRecord {
  id: string;
  horseId: string;
  resultRank: 'S' | 'A' | 'B' | 'C' | 'D';
  totalScore: number;
  acquiredSkills: string[];
  finalStats: StatBlock;
  races: RaceResult[];
  equipmentUsed: string[];
  memo?: string;
}

RaceResult {
  id: string;
  name: string;
  position: number;
  score: number;
  activatedSkills: string[];
}
```

---

このデータスキーマはゲーム全体の進行・分析・記録を一貫管理する構造であり、育成・装備・スキル・履歴を明確に区分して再利用性と拡張性を担保します。