# チャクラと武道の馬育成ゲーム - プロジェクト構造設計書

## 📂 フォルダ構成

```
project_root/
│
├── 📂 assets/              # 全てのアセットファイル
│   ├── 📂 images/          # 画像・スプライト
│   │   ├── 📂 ui/          # UI要素画像
│   │   ├── 📂 characters/  # キャラクター画像
│   │   └── 📂 effects/     # エフェクト画像
│   │
│   ├── 📂 fonts/           # フォントファイル
│   ├── 📂 audio/           # サウンドファイル
│   │   ├── 📂 bgm/         # BGM
│   │   └── 📂 sfx/         # 効果音
│   │
│   └── 📂 shaders/         # シェーダーファイル
│
├── 📂 data/                 # JSONデータ（マスターデータ）
│   ├── 📂 horses/           # 馬データ
│   ├── 📂 equipment/        # 装備データ
│   ├── 📂 skills/           # スキルデータ
│   ├── 📂 training/         # トレーニングデータ
│   └── 📂 events/           # イベントデータ
│
├── 📂 scenes/               # シーン（画面）
│   ├── 📂 ui/               # UI共通コンポーネント
│   ├── 📂 training/         # トレーニング画面
│   ├── 📂 race/             # レース画面
│   └── 📂 common/           # 共通シーン
│
├── 📂 scripts/              # GDScriptファイル
│   ├── 📂 core/             # コアシステム
│   ├── 📂 models/           # データモデル
│   ├── 📂 managers/         # 状態管理
│   ├── 📂 ui/               # UI制御
│   ├── 📂 utils/            # ユーティリティ
│   └── 📂 effects/          # エフェクト処理
│
├── 📂 addons/               # プラグイン
└── 📂 saves/                # セーブデータ（ローカル）
```

## 🧩 クラス設計

### コア・管理システム

#### GameManager (シングルトン)
```gdscript
class_name GameManager extends Node
# ゲーム全体の状態管理

var current_state: String        # 現在のゲーム状態
var player_data: PlayerData      # プレイヤーデータ参照
var training_manager: TrainingManager  # トレーニング管理
var race_manager: RaceManager    # レース管理
var data_loader: DataLoader      # データローダー

# 主要メソッド
func change_state(new_state: String) -> void
func save_game() -> void
func load_game() -> void
func start_training() -> void
func start_race() -> void
```

#### TrainingManager
```gdscript
class_name TrainingManager extends Node
# 育成サイクル管理

var current_turn: int
var current_month: String
var fatigue: int
var chakra_flow: String  # 現在のチャクラ気配カテゴリ
var resonance_gauge: int  # 補助ゲージ
var stagnation_count: Dictionary  # カテゴリごとの連続使用回数

# 主要メソッド
func start_new_month() -> void  # 新しい月の処理開始
func select_training(category: String) -> void  # トレーニング選択
func execute_training() -> void  # トレーニング実行
func calculate_growth() -> Dictionary  # 成長計算
func check_resonance() -> bool  # 共鳴チェック
func update_skill_progress() -> void  # スキル進行更新
func update_familiarity() -> void  # 熟度更新
func rest() -> void  # 休養処理
```

#### RaceManager
```gdscript
class_name RaceManager extends Node
# レース処理管理

var current_section: int  # 現在の区間
var race_scores: Dictionary  # 各馬のスコア
var activated_skills: Array  # 発動スキル一覧

# 主要メソッド
func start_race() -> void
func calculate_section_score() -> void  # 区間スコア計算
func process_skills() -> void  # スキル発動処理
func update_positions() -> void  # 順位更新
func finish_race() -> Dictionary  # レース結果取得
```

#### DataLoader
```gdscript
class_name DataLoader extends Node
# マスターデータロード管理

var horses_data: Dictionary
var equipment_data: Dictionary
var skills_data: Dictionary
var training_data: Dictionary
var events_data: Dictionary

# 主要メソッド
func load_all_data() -> void
func get_horse_by_id(id: String) -> Dictionary
func get_equipment_by_id(id: String) -> Dictionary
func get_skill_by_id(id: String) -> Dictionary
func get_random_training(category: String) -> Dictionary
func get_random_event(condition: Dictionary) -> Dictionary
```

### データモデル

#### PlayerData
```gdscript
class_name PlayerData extends Resource
# プレイヤー進行データ

var player_name: String
var current_horse: Horse
var equipped_items: Dictionary  # カテゴリ→装備IDのマッピング
var acquired_skills: Array
var training_history: Array
var race_results: Array

# 主要メソッド
func equip_item(category: String, item_id: String) -> void
func add_skill(skill_id: String) -> void
func add_training_record(record: Dictionary) -> void
func add_race_result(result: Dictionary) -> void
func get_total_score() -> int
```

#### Horse
```gdscript
class_name Horse extends Resource
# 育成対象の馬データ

var id: String
var name: String
var stats: StatBlock
var aptitude: Array  # 得意カテゴリ
var growth_rates: Dictionary  # 成長率

# 主要メソッド
func increase_stat(stat_name: String, amount: int) -> void
func calculate_race_score(section: String) -> float
func get_best_category() -> String
```

#### StatBlock
```gdscript
class_name StatBlock extends Resource
# ステータスブロック

# 主要ステータス
var speed: int = 0
var stamina: int = 0
var technique: int = 0
var mental: int = 0
var flexibility: int = 0
var intellect: int = 0

# 補助ステータス（オプション）
var secondary_stats = {
    "reaction": 0,
    "balance": 0,
    "focus": 0,
    "adaptability": 0,
    "judgment": 0,
    "recovery": 0
}

# 主要メソッド
func get_main_stats() -> Dictionary
func get_all_stats() -> Dictionary
func increase(stat_name: String, amount: int) -> void
func get_total() -> int
```

#### Equipment
```gdscript
class_name Equipment extends Resource
# 装備データ

var id: String
var name: String
var category: String  # 'rider', 'horse', 'manual'
var rarity: String
var related_training: String
var effects: Array
var associated_skills: Array
var familiarity: int = 0  # 熟度値
var familiarity_level: int = 1  # 熟度レベル

# 主要メソッド
func get_effect_value(effect_type: String) -> float
func increase_familiarity(amount: int) -> bool  # レベルアップ時はtrue
func calculate_resonance_bonus() -> float
```

#### Skill
```gdscript
class_name Skill extends Resource
# スキルデータ

var id: String
var name: String
var description: String
var effect: Dictionary
var condition: Dictionary
var category_tags: Array
var required_training: Array
var progress: int = 0
var progress_threshold: int = 5
var is_bloomed: bool = false

# 主要メソッド
func increase_progress(amount: int) -> bool  # 開花時はtrue
func check_activation_condition(race_state: Dictionary) -> bool
func apply_effect(race_state: Dictionary) -> Dictionary
func get_effect_value() -> float
```

### UI管理

#### UIManager
```gdscript
class_name UIManager extends Node
# UI管理・画面遷移

var current_screen: String
var ui_stack: Array  # 画面スタック

# 主要メソッド
func change_screen(screen_name: String) -> void
func push_screen(screen_name: String) -> void  # 画面スタック追加
func pop_screen() -> void  # 画面スタック戻る
func show_popup(popup_name: String, data: Dictionary) -> void
func update_training_ui() -> void
func update_race_ui() -> void
func show_status_effect(effect_type: String, amount: int) -> void
```

#### TrainingScreen
```gdscript
class_name TrainingScreen extends Control
# トレーニング画面UI

# UI要素参照
var status_panel: Control
var training_options: Control
var fatigue_bar: ProgressBar
var resonance_gauge: Control

# 主要メソッド
func _ready() -> void
func update_training_options() -> void
func show_selected_training_detail(training_id: String) -> void
func show_training_result(result: Dictionary) -> void
func update_status_display() -> void
func update_skill_progress() -> void
func update_familiarity_bars() -> void
func show_resonance_effect() -> void
```

#### RaceScreen
```gdscript
class_name RaceScreen extends Control
# レース画面UI

# UI要素参照
var section_indicator: Control
var horse_positions: Control
var skill_log: RichTextLabel
var result_panel: Control

# 主要メソッド
func _ready() -> void
func start_race_animation() -> void
func update_section(section: String) -> void
func update_horse_positions() -> void
func show_skill_activation(skill_name: String) -> void
func show_section_result() -> void
func show_final_result() -> void
```

## 🔄 主要データフロー

### 育成サイクル
1. `GameManager` → `TrainingManager.start_new_month()`
2. 月次チャクラ気配決定
3. UI表示更新
4. プレイヤーがトレーニング選択
5. `TrainingManager.execute_training()`
6. ステータス・スキル・熟度の更新
7. UI演出と次の月へ

### レースフロー
1. `GameManager` → `RaceManager.start_race()`
2. 区間ごとにループ:
   - `RaceManager.calculate_section_score()`
   - `RaceManager.process_skills()`
   - `RaceManager.update_positions()`
   - UI更新と演出
3. `RaceManager.finish_race()`
4. 結果表示と記録

## 💾 保存システム

### セーブデータ構造
```gdscript
{
    "player_name": String,
    "current_horse": Dictionary,  # Horse データ
    "current_turn": int,
    "fatigue": int,
    "equipped_items": Dictionary,
    "stats": Dictionary,  # StatBlock データ
    "skills": Array,  # 取得スキル一覧
    "familiarity": Dictionary,  # 装備ID→熟度値のマップ
    "race_results": Array,  # レース結果履歴
    "skill_progress": Dictionary  # スキルID→進行値のマップ
}
```

### セーブロード処理
- `GameManager.save_game()` → JSONとしてファイル保存
- `GameManager.load_game()` → ファイルから読み込み＆状態復元

## 🔄 状態遷移

### ゲームステート
- `TitleState`: タイトル画面
- `HomeState`: ホーム画面
- `HorseSelectState`: 馬選択
- `EquipmentSelectState`: 装備選択
- `TrainingState`: トレーニング
- `EventState`: イベント発生中
- `RaceState`: レース実行中
- `ResultState`: 結果画面

### 条件遷移
- トレーニング → レース: プレイヤー選択 or 期間満了
- トレーニング → イベント: ランダム発生
- レース終了 → トレーニング: まだ育成期間内
- レース終了 → 結果: 育成期間終了 