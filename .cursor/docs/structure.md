# チャクラと武道の馬育成ゲーム - プロジェクト構造設計書

## 📂 フォルダ構成

```
hizume/
└── src/                  # プロジェクトルート
    ├── 📂 assets/           # 全てのアセットファイル
    │   ├── 📂 images/       # 画像・スプライト
    │   ├── 📂 fonts/        # フォントファイル
    │   └── 📂 sounds/       # サウンドファイル
    │
    ├── 📂 resources/        # リソースファイル
    │   └── 📂 data/         # JSONデータ（マスターデータ）
    │       ├── horses.json  # 馬データ
    │       ├── equipment.json # 装備データ
    │       └── skills.json  # スキルデータ
    │
    ├── 📂 scenes/            # シーン（画面）
    │   ├── 📂 autoloads/     # 自動読み込みシーン
    │   ├── 📂 screens/       # 画面シーン
    │   ├── 📂 ui_components/ # UI共通コンポーネント
    │   └── 📂 setup/         # 初期設定シーン
    │
    └── 📂 scripts/           # GDScriptファイル
        ├── 📂 data/          # データモデル
        ├── 📂 managers/      # 状態管理
        ├── 📂 ui/            # UI制御
        └── 📂 setup/         # 初期設定スクリプト
```

## 🧩 クラス設計

### コア・管理システム

#### GameManager (シングルトン)
```gdscript
class_name GameManager extends Node
# ゲーム全体の状態管理

var current_horse: Horse        # 現在の馬
var current_equipment: Dictionary = {}  # カテゴリごとの装備
var available_skills: Array[Skill] = []  # 利用可能なスキル
var unlocked_skills: Array[Skill] = []   # 習得したスキル
var race_records: Array[Dictionary] = [] # レース結果記録

# 主要メソッド
static func get_instance() -> GameManager  # シングルトンインスタンス取得
func save_game() -> void
func load_game() -> void
func start_training() -> void
func start_race() -> void
```

#### TrainingState (シングルトン)
```gdscript
class_name TrainingState extends Node
# 育成状態管理

var current_training_options: Array[Dictionary] = []  # 現在のトレーニング選択肢
var is_special_month: bool = false  # 特別月間フラグ
var is_race_available: bool = false  # レース参加可能フラグ
var last_training_result: Dictionary = {}  # 最後のトレーニング結果

# 主要メソッド
func get_training_categories() -> Array[String]  # トレーニングカテゴリ一覧取得
```

#### DataLoader (シングルトン)
```gdscript
class_name DataLoader extends Node
# マスターデータロード管理

var _horses_data: Dictionary = {}  # 馬データキャッシュ
var _equipment_data: Dictionary = {}  # 装備データキャッシュ
var _skills_data: Dictionary = {}  # スキルデータキャッシュ

# 主要メソッド
static func get_instance() -> DataLoader  # シングルトンインスタンス取得
func _load_all_data() -> void  # 全データ読み込み
func get_horse(horse_id: String) -> Horse  # 馬オブジェクト取得
func get_all_horse_ids() -> Array[String]  # 利用可能な馬ID一覧
func get_equipment(equipment_id: String) -> Equipment  # 装備オブジェクト取得
func get_skill(skill_id: String) -> Skill  # スキルオブジェクト取得
func generate_dummy_data() -> void  # ダミーデータ生成
func save_dummy_data_to_files() -> void  # ダミーデータをファイルに保存
```

### データモデル

#### Horse
```gdscript
class_name Horse extends Resource
# 育成対象の馬データ

var id: String = ""
var name: String = ""
var description: String = ""
var base_stats: StatBlock
var current_stats: StatBlock
var growth_rates: Dictionary = {}
var aptitude: Array[String] = []  # 得意カテゴリ
var fatigue: int = 0  # 疲労値（0-100）
var age_in_months: int = 36  # 月齢（初期値：3歳=36ヶ月）
var training_count: Dictionary = {}  # カテゴリごとのトレーニング回数

# 主要メソッド
func add_fatigue(amount: int) -> void
func reduce_fatigue(amount: int) -> void
func advance_month() -> void
func get_age_string() -> String
func record_training(category: String) -> void
func to_dict() -> Dictionary
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

# 補助ステータス
var reaction: int = 0
var balance: int = 0
var focus: int = 0
var adaptability: int = 0
var judgment: int = 0
var recovery: int = 0

# 主要メソッド
func to_dict() -> Dictionary
func from_dict(data: Dictionary) -> void
```

#### Equipment
```gdscript
class_name Equipment extends Resource
# 装備データ

var id: String = ""
var name: String = ""
var description: String = ""
var category: String = ""  # "rider", "horse", "manual"
var rarity: String = "SSR"
var effects: Array = []
var related_training: String = ""
var associated_skill_ids: Array = []

# 主要メソッド
func get_effect_value(effect_type: String) -> float
func to_dict() -> Dictionary
```

#### Skill
```gdscript
class_name Skill extends Resource
# スキルデータ

var id: String = ""
var name: String = ""
var description: String = ""
var effect: Dictionary = {}
var condition: Dictionary = {}
var category_tags: Array = []
var required_training: Array = []
var progress_threshold: int = 5

# 主要メソッド
func is_active(race_state: Dictionary) -> bool
func get_effect_value() -> float
func to_dict() -> Dictionary
```

### UI管理

#### TitleScreen
```gdscript
extends Control
# タイトル画面

# UI要素
@onready var start_button
@onready var skill_button
@onready var records_button
@onready var exit_button

# 主要メソッド
func _play_intro_animation() -> void
func _check_data_status() -> void
func _update_button_states() -> void
```

#### HorseSelectScreen
```gdscript
extends Control
# 馬選択画面

# UI要素
@onready var horse_list_container
@onready var horse_item_template
@onready var name_label
@onready var description_label
@onready var stats_grid
@onready var aptitude_label
@onready var select_button
@onready var back_button

# 主要メソッド
func _load_horse_list(data_loader: DataLoader) -> void
func _on_horse_selected(horse_id: String) -> void
func _display_horse_details(horse_data: Dictionary) -> void
```

#### EquipmentSelectScreen
```gdscript
extends Control
# 装備選択画面

# UI要素
@onready var category_tabs
@onready var equipment_grid
@onready var equipment_detail_panel
@onready var equip_button
@onready var back_button
@onready var next_button

# 主要メソッド
func _load_equipment_list(category: String) -> void
func _on_equipment_selected(equipment_id: String) -> void
func _display_equipment_details(equipment_data: Dictionary) -> void
```

## 🔄 主要データフロー

### 育成サイクル
1. `GameManager` → トレーニング画面表示
2. 月次チャクラ気配決定
3. トレーニング選択肢表示
4. プレイヤーがトレーニング選択
5. ステータス更新、スキル進行、熟度加算
6. UI演出と次の月へ

### レースフロー
1. レース画面表示
2. 区間ごとにスコア計算、スキル発動
3. 結果表示と記録

## 💾 保存システム

### セーブデータ構造
```gdscript
{
    "horse": Dictionary,  # 馬データ
    "equipment": Dictionary,  # 装備データ
    "skills": Array,  # 取得スキル一覧
    "race_records": Array,  # レース結果
    "training_history": Array  # トレーニング履歴
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