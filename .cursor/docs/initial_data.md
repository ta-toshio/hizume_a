# チャクラと武道の馬育成ゲーム - 初期データサンプル

このファイルは実装開始時に使用するマスターデータのサンプルです。
これらのデータを基にしてゲームの基本機能を実装することができます。

## 馬データサンプル

以下は`data/horses/`ディレクトリに配置するJSONファイルの例です。

```json
[
  {
    "id": "horse_001",
    "name": "風華",
    "baseStats": {
      "speed": 25,
      "stamina": 20,
      "technique": 18,
      "mental": 15,
      "flexibility": 22,
      "intellect": 16,
      "secondaryStats": {
        "reaction": 20,
        "balance": 18,
        "focus": 15,
        "adaptability": 16,
        "judgment": 17,
        "recovery": 19
      }
    },
    "growthRates": {
      "speed": 1.2,
      "stamina": 1.0,
      "technique": 0.9,
      "mental": 0.8,
      "flexibility": 1.1,
      "intellect": 0.9
    },
    "aptitude": ["速力", "柔軟"],
    "description": "速さと柔軟性に優れた馬。特に始動がよく、機敏な動きが特徴。"
  },
  {
    "id": "horse_002",
    "name": "静竜",
    "baseStats": {
      "speed": 18,
      "stamina": 25,
      "technique": 20,
      "mental": 22,
      "flexibility": 15,
      "intellect": 20,
      "secondaryStats": {
        "reaction": 16,
        "balance": 22,
        "focus": 22,
        "adaptability": 18,
        "judgment": 20,
        "recovery": 24
      }
    },
    "growthRates": {
      "speed": 0.9,
      "stamina": 1.2,
      "technique": 1.0,
      "mental": 1.1,
      "flexibility": 0.8,
      "intellect": 1.0
    },
    "aptitude": ["精神", "持久"],
    "description": "精神力と持久力に優れた馬。落ち着きがあり、終盤まで安定した力を発揮する。"
  },
  {
    "id": "horse_003",
    "name": "技巧",
    "baseStats": {
      "speed": 20,
      "stamina": 18,
      "technique": 25,
      "mental": 18,
      "flexibility": 18,
      "intellect": 24,
      "secondaryStats": {
        "reaction": 22,
        "balance": 24,
        "focus": 18,
        "adaptability": 25,
        "judgment": 23,
        "recovery": 16
      }
    },
    "growthRates": {
      "speed": 1.0,
      "stamina": 0.9,
      "technique": 1.2,
      "mental": 0.9,
      "flexibility": 0.9,
      "intellect": 1.1
    },
    "aptitude": ["技術", "展開"],
    "description": "技術と展開力に優れた馬。状況判断が鋭く、戦略的な走りを得意とする。"
  }
]
```

## 装備データサンプル

以下は`data/equipment/`ディレクトリに配置するJSONファイルの例です。

```json
[
  {
    "id": "eq_rider_001",
    "name": "静心の装束",
    "category": "rider",
    "rarity": "SSR",
    "relatedTraining": "精神",
    "effects": [
      {
        "type": "trainingBoost",
        "value": 15
      },
      {
        "type": "skillSupport",
        "value": 1,
        "condition": "熟度Lv2以上"
      }
    ],
    "associatedSkillIds": ["skill_002", "skill_010"],
    "flavorText": "心を静め、精神の流れを感じるための特別な装束。"
  },
  {
    "id": "eq_horse_001",
    "name": "無音蹄",
    "category": "horse",
    "rarity": "SSR",
    "relatedTraining": "速力",
    "effects": [
      {
        "type": "trainingBoost",
        "value": 10
      },
      {
        "type": "eventBuff",
        "value": 20,
        "condition": "イベント発生時"
      }
    ],
    "associatedSkillIds": ["skill_001"],
    "flavorText": "音を立てず、風のように駆ける蹄。速さの奥義を宿している。"
  },
  {
    "id": "eq_manual_001",
    "name": "柔走体捌の書",
    "category": "manual",
    "rarity": "SSR",
    "relatedTraining": "柔軟",
    "effects": [
      {
        "type": "skillSupport",
        "value": 2
      },
      {
        "type": "trainingBoost",
        "value": 5
      }
    ],
    "associatedSkillIds": ["skill_003"],
    "flavorText": "古来より伝わる柔軟な体捌きの奥義が記された巻物。"
  }
]
```

## スキルデータサンプル

以下は`data/skills/`ディレクトリに配置するJSONファイルの例です。

```json
[
  {
    "id": "skill_001",
    "name": "無音疾風",
    "description": "終盤、静かに加速し順位を上げやすくなる",
    "effect": {
      "timing": "final",
      "bonusType": "speed",
      "value": 15
    },
    "condition": {
      "trigger": "when_losing",
      "position": "mid",
      "section": "final"
    },
    "categoryTags": ["速力系"],
    "requiredTraining": ["速力", "技術"],
    "progressThreshold": 5,
    "rarity": "normal"
  },
  {
    "id": "skill_002",
    "name": "静心制圧",
    "description": "中盤、精神が安定して展開を読む力が強まる",
    "effect": {
      "timing": "middle",
      "bonusType": "control",
      "value": 10
    },
    "condition": {
      "trigger": "always",
      "section": "middle"
    },
    "categoryTags": ["精神系", "展開系"],
    "requiredTraining": ["精神", "展開"],
    "progressThreshold": 5,
    "rarity": "normal"
  },
  {
    "id": "skill_003",
    "name": "柔式転身",
    "description": "スタート時、柔軟な動きで有利な位置を取る",
    "effect": {
      "timing": "start",
      "bonusType": "control",
      "value": 8
    },
    "condition": {
      "trigger": "always",
      "section": "early"
    },
    "categoryTags": ["柔軟系"],
    "requiredTraining": ["柔軟", "精神"],
    "progressThreshold": 5,
    "rarity": "normal"
  },
  {
    "id": "skill_010",
    "name": "心身統合",
    "description": "終盤で集中を保ちつつスタミナ消費を抑える",
    "effect": {
      "timing": "final",
      "bonusType": "stamina",
      "value": 12
    },
    "condition": {
      "trigger": "low_stamina",
      "section": "final"
    },
    "categoryTags": ["精神系", "持久系"],
    "requiredTraining": ["精神", "持久"],
    "progressThreshold": 5,
    "rarity": "normal"
  },
  {
    "id": "skill_020",
    "name": "奥義・風刃走法",
    "description": "あらゆる区間で鋭い加速を可能にする究極の走法",
    "effect": {
      "timing": "all",
      "bonusType": "speed",
      "value": 25
    },
    "condition": {
      "trigger": "always",
      "section": "all"
    },
    "categoryTags": ["速力系", "技術系"],
    "requiredTraining": ["速力", "速力", "技術"],
    "progressThreshold": 8,
    "rarity": "secret",
    "requiredFamiliarity": 100
  }
]
```

## トレーニングデータサンプル

以下は`data/training/`ディレクトリに配置するJSONファイルの例です。

```json
[
  {
    "id": "tr_speed_001",
    "name": "霞走法",
    "category": "速力系",
    "mainStatGain": {
      "stat": "speed",
      "value": 6
    },
    "subStatGain": {
      "stat": "reaction",
      "value": 2
    },
    "fatigueIncrease": 30,
    "description": "霞のように軽やかに走る技術を身につける。速力と反応速度が向上する。"
  },
  {
    "id": "tr_flex_001",
    "name": "水流身法",
    "category": "柔軟系",
    "mainStatGain": {
      "stat": "flexibility",
      "value": 6
    },
    "subStatGain": {
      "stat": "balance",
      "value": 2
    },
    "fatigueIncrease": 20,
    "description": "水の流れのように体を柔軟に動かす訓練。柔軟性とバランスが向上する。"
  },
  {
    "id": "tr_mental_001",
    "name": "静心呼吸法",
    "category": "精神系",
    "mainStatGain": {
      "stat": "mental",
      "value": 4
    },
    "subStatGain": {
      "stat": "focus",
      "value": 3
    },
    "fatigueIncrease": 10,
    "fatigueDecrease": 10,
    "description": "心を静め、呼吸を整える修練。精神力と集中力が向上し、軽い疲労回復効果もある。"
  },
  {
    "id": "tr_tech_001",
    "name": "型稽古",
    "category": "技術系",
    "mainStatGain": {
      "stat": "technique",
      "value": 5
    },
    "subStatGain": {
      "stat": "adaptability",
      "value": 1
    },
    "fatigueIncrease": 25,
    "description": "基本的な動きの型を反復練習する。技術と対応力が向上する。"
  },
  {
    "id": "tr_int_001",
    "name": "読図訓練",
    "category": "展開系",
    "mainStatGain": {
      "stat": "intellect",
      "value": 5
    },
    "subStatGain": {
      "stat": "judgment",
      "value": 2
    },
    "fatigueIncrease": 25,
    "description": "様々なコース取りの読み合いを学ぶ。展開力と判断力が向上する。"
  },
  {
    "id": "tr_stam_001",
    "name": "持久走",
    "category": "持久系",
    "mainStatGain": {
      "stat": "stamina",
      "value": 6
    },
    "subStatGain": {
      "stat": "recovery",
      "value": 2
    },
    "fatigueIncrease": 30,
    "description": "長距離を一定のペースで走り続ける。スタミナと回復力が向上する。"
  }
]
```

## イベントデータサンプル

以下は`data/events/`ディレクトリに配置するJSONファイルの例です。

```json
[
  {
    "id": "ev_001",
    "title": "古道場の試練",
    "description": "導士が不意に竹刀を構えてきた。あなたは？",
    "type": "choice",
    "choices": [
      {
        "text": "受けて立つ",
        "result": {
          "statChange": { "speed": 3 },
          "fatigueChange": 10,
          "skillProgress": "skill_001",
          "logText": "真っ向から受け止めたことで、速さの極意を垣間見た。"
        }
      },
      {
        "text": "かわして機を待つ",
        "result": {
          "statChange": { "intellect": 3 },
          "familiarityChange": 5,
          "resonanceBoost": true,
          "logText": "巧みにかわすことで、展開の妙を会得した。"
        }
      }
    ]
  },
  {
    "id": "ev_002",
    "title": "偶然の悟り",
    "description": "朝の稽古中、何気なく気の流れを掴んだような感覚があった。",
    "type": "situation",
    "result": {
      "statChange": { "mental": 2, "focus": 1 },
      "fatigueChange": -5,
      "resonanceBoost": true,
      "logText": "深い集中状態に入った。精神力が高まり、疲労も少し回復した。"
    }
  },
  {
    "id": "ev_003",
    "title": "チャクラの乱れ",
    "description": "体内のチャクラが不意に乱れ、走っていた型が一瞬崩れた。",
    "type": "situation",
    "result": {
      "statChange": { "technique": -1 },
      "fatigueChange": 5,
      "skillProgress": -1,
      "logText": "体内の気の流れに混乱が生じた。技術が少し低下し、疲労も増した。"
    },
    "probability": 0.2
  },
  {
    "id": "ev_004",
    "title": "奥義の啓示",
    "description": "夕暮れの練習場で、ふと浮かんだ走りの極意。",
    "type": "special",
    "condition": {
      "familiarityLevel": 4,
      "specificMonth": ["4歳10月", "5歳4月"]
    },
    "result": {
      "specialSkillUnlock": "skill_020",
      "logText": "深い悟りのもと、奥義の秘訣を掴んだ。「奥義・風刃走法」への道が開かれた。"
    },
    "probability": 0.3
  }
]
```

## レーススコア係数データ

以下は`data/race/section_coefficients.json`に配置するデータの例です。

```json
{
  "sections": {
    "early": {
      "speed": 0.4,
      "flexibility": 0.15,
      "mental": 0.1,
      "technique": 0.1,
      "intellect": 0.15,
      "stamina": 0.1
    },
    "middle": {
      "speed": 0.25,
      "flexibility": 0.1,
      "mental": 0.15,
      "technique": 0.2,
      "intellect": 0.2,
      "stamina": 0.1
    },
    "final": {
      "speed": 0.3,
      "flexibility": 0.1,
      "mental": 0.15,
      "technique": 0.1,
      "intellect": 0.1,
      "stamina": 0.25
    }
  },
  "penalties": {
    "fatigue": {
      "high": {
        "threshold": 80,
        "value": -15
      },
      "medium": {
        "threshold": 60,
        "value": -5
      }
    },
    "mental": {
      "low": {
        "threshold": 50,
        "value": -10
      }
    }
  }
}
```

## UI設定サンプル

以下は`data/ui/theme_config.json`に配置するUIテーマ設定の例です。

```json
{
  "colors": {
    "primary": "#4A306D",
    "secondary": "#9069B3",
    "accent": "#FFD700",
    "background": "#1A1A2E",
    "text_normal": "#E1E1E6",
    "text_header": "#FFFFFF",
    "categories": {
      "speed": "#3B83BD",
      "flexibility": "#50C878",
      "mental": "#9370DB",
      "technique": "#D2691E",
      "intellect": "#6A5ACD",
      "stamina": "#CD5C5C"
    }
  },
  "fonts": {
    "title": "res://assets/fonts/SawarabiMincho-Regular.ttf",
    "body": "res://assets/fonts/NotoSansJP-Regular.ttf",
    "ui": "res://assets/fonts/MPLUSRounded1c-Medium.ttf"
  },
  "animations": {
    "transition_speed": 0.3,
    "skill_activation_time": 1.2,
    "chakra_effect_time": 0.8
  }
}
```

## チュートリアルテキストサンプル

以下は`data/tutorial/messages.json`に配置するチュートリアルテキストの例です。

```json
[
  {
    "id": "tut_intro_1",
    "screen": "home",
    "title": "馬と導法の世界へようこそ",
    "message": "このゲームでは、チャクラの力と武道の技を取り入れた馬育成を体験できます。様々なトレーニングを通じて、馬の能力を高めていきましょう。",
    "target_element": null,
    "position": "center"
  },
  {
    "id": "tut_training_1",
    "screen": "training",
    "title": "トレーニングの選択",
    "message": "6つのカテゴリからトレーニングを選び、馬のステータスを成長させましょう。カテゴリによって伸びるステータスが異なります。",
    "target_element": "training_options",
    "position": "right"
  },
  {
    "id": "tut_resonance_1",
    "screen": "training",
    "title": "チャクラ共鳴について",
    "message": "月のチャクラ気配と同じカテゴリのトレーニングを選ぶと、共鳴が発生することがあります。共鳴が起こると大きな成長が得られます。",
    "target_element": "chakra_flow_indicator",
    "position": "left"
  },
  {
    "id": "tut_familiarity_1",
    "screen": "training",
    "title": "装備熟度について",
    "message": "装備カテゴリに合ったトレーニングを行うと熟度が上がります。熟度が高いほど、装備の効果が高まり、特別なスキルが開花しやすくなります。",
    "target_element": "familiarity_bars",
    "position": "left"
  },
  {
    "id": "tut_race_1",
    "screen": "race",
    "title": "レースについて",
    "message": "レースでは育成の成果が試されます。序盤・中盤・終盤の3区間でステータスとスキルが影響し、順位が決まります。",
    "target_element": "section_indicator",
    "position": "top"
  }
]
``` 