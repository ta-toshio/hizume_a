# チャクラと武道の馬育成ゲーム - 実装ガイドライン

## 📝 実装方針

このガイドラインは、Godot Engineを使用したゲーム開発の手順と主要機能の実装方法を示すものです。

### 開発環境セットアップ

1. **Godot Engine 4.x**をインストール
2. プロジェクトを新規作成（2D）
3. ディレクトリ構造の初期設定（`structure.md`参照）
4. 初期データファイルの配置（`initial_data.md`参照）

## 🔄 実装手順

### Phase 1: 基盤設計

#### Step 1: プロジェクト設定と基本データ構造

1. **GameManagerシングルトン作成**
   ```gdscript
   # scripts/core/game_manager.gd
   extends Node
   class_name GameManager
   
   var current_state: String = "title"
   var player_data: PlayerData
   var training_manager: TrainingManager
   var race_manager: RaceManager
   var data_loader: DataLoader
   
   func _ready():
       initialize_managers()
       data_loader.load_all_data()
   
   func initialize_managers():
       data_loader = DataLoader.new()
       add_child(data_loader)
       
       training_manager = TrainingManager.new()
       add_child(training_manager)
       
       race_manager = RaceManager.new()
       add_child(race_manager)
   
   func change_state(new_state: String) -> void:
       current_state = new_state
       # 状態変更に伴う処理
   ```

2. **データモデルの実装**

   StatBlockクラス実装例:
   ```gdscript
   # scripts/models/stat_block.gd
   extends Resource
   class_name StatBlock
   
   # 主要ステータス
   var speed: int = 0
   var stamina: int = 0
   var technique: int = 0
   var mental: int = 0
   var flexibility: int = 0
   var intellect: int = 0
   
   # 補助ステータス
   var secondary_stats = {
       "reaction": 0,
       "balance": 0,
       "focus": 0,
       "adaptability": 0,
       "judgment": 0,
       "recovery": 0
   }
   
   func get_main_stats() -> Dictionary:
       return {
           "speed": speed,
           "stamina": stamina,
           "technique": technique,
           "mental": mental,
           "flexibility": flexibility,
           "intellect": intellect
       }
       
   func get_all_stats() -> Dictionary:
       var all_stats = get_main_stats()
       all_stats.merge(secondary_stats)
       return all_stats
       
   func increase(stat_name: String, amount: int) -> void:
       if stat_name in get_main_stats():
           set(stat_name, get(stat_name) + amount)
       elif stat_name in secondary_stats:
           secondary_stats[stat_name] += amount
   
   func get_total() -> int:
       var total = 0
       for stat in get_main_stats().values():
           total += stat
       return total
   ```

3. **JSONローダーの実装**

   ```gdscript
   # scripts/core/data_loader.gd
   extends Node
   class_name DataLoader
   
   var horses_data: Dictionary = {}
   var equipment_data: Dictionary = {}
   var skills_data: Dictionary = {}
   var training_data: Dictionary = {}
   var events_data: Dictionary = {}
   
   func load_all_data() -> void:
       horses_data = load_json_file("res://data/horses/horses.json")
       equipment_data = load_json_file("res://data/equipment/equipment.json")
       skills_data = load_json_file("res://data/skills/skills.json")
       training_data = load_json_file("res://data/training/training.json")
       events_data = load_json_file("res://data/events/events.json")
       
   func load_json_file(path: String) -> Dictionary:
       var file = FileAccess.open(path, FileAccess.READ)
       var json_text = file.get_as_text()
       file.close()
       
       var json = JSON.new()
       var error = json.parse(json_text)
       if error == OK:
           return json.data
       else:
           print("JSON解析エラー: ", json.get_error_message())
           return {}
   
   func get_horse_by_id(id: String) -> Dictionary:
       for horse in horses_data:
           if horse.id == id:
               return horse
       return {}
   
   # 他の get_by_id メソッドも同様に実装
   ```

### Phase 2: コア機能実装

#### Step 1: 育成サイクル

1. **TrainingManagerの実装**

   ```gdscript
   # scripts/managers/training_manager.gd
   extends Node
   class_name TrainingManager
   
   signal month_started(month_data)
   signal training_completed(result)
   signal skill_progressed(skill_id, progress)
   
   var current_turn: int = 0
   var current_month: String = "3歳4月"
   var fatigue: int = 0
   var chakra_flow: String  # 現在のチャクラ気配カテゴリ
   var resonance_gauge: int = 0  # 補助ゲージ
   var stagnation_count: Dictionary = {}  # カテゴリごとの連続使用回数
   
   func start_new_month() -> void:
       current_turn += 1
       update_current_month_label()
       determine_chakra_flow()
       reset_stagnation_for_different_category()
       emit_signal("month_started", get_month_data())
   
   func determine_chakra_flow() -> void:
       # ランダムな気配カテゴリを選択
       var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
       chakra_flow = categories[randi() % categories.size()]
   
   func select_training(category: String) -> void:
       # 選択されたトレーニングカテゴリを記録
       if category in stagnation_count:
           stagnation_count[category] += 1
       else:
           stagnation_count[category] = 1
   
   func execute_training() -> void:
       # トレーニング実行ロジック
       var result = calculate_growth()
       update_skill_progress()
       update_familiarity()
       
       emit_signal("training_completed", result)
   ```

2. **チャクラ共鳴システム実装**

   ```gdscript
   # TrainingManager内に追加
   func check_resonance() -> bool:
       # 共鳴発生条件チェック
       if resonance_gauge >= 5:
           # 補助ゲージMAXで確定共鳴
           resonance_gauge = 0
           return true
       
       if chakra_flow == current_category and equipment_matches_category():
           # 通常の共鳴条件: 月の気配 + 装備一致
           var base_chance = 0.4  # 40%
           var familiarity_bonus = get_familiarity_resonance_bonus()
           
           return randf() < (base_chance + familiarity_bonus)
       
       return false
   
   func equipment_matches_category() -> bool:
       var equipped_items = GameManager.player_data.equipped_items
       return equipped_items.has(current_category)
   
   func update_resonance_gauge(category: String) -> void:
       if not equipment_matches_category():
           resonance_gauge = min(resonance_gauge + 1, 5)
       else:
           # 一致カテゴリ選択時は補助ゲージ増えない
           pass
   ```

#### Step 2: スキルシステム

1. **スキル進行処理**

   ```gdscript
   # TrainingManager内に追加
   func update_skill_progress() -> void:
       var progress_amount = 1  # 基本進行量
       
       if is_resonance_activated:
           progress_amount = 2  # 共鳴時は2倍
       
       # 熟度によるボーナス
       if get_current_familiarity_level() >= 2:
           progress_amount += 1
       
       # スキル進行
       for skill_id in active_skill_candidates:
           var current_progress = skill_progress.get(skill_id, 0)
           var new_progress = current_progress + progress_amount
           
           skill_progress[skill_id] = new_progress
           
           # スキル開花チェック
           var threshold = GameManager.data_loader.get_skill_by_id(skill_id).progressThreshold
           if new_progress >= threshold:
               bloom_skill(skill_id)
           
           emit_signal("skill_progressed", skill_id, new_progress)
   
   func bloom_skill(skill_id: String) -> void:
       # スキル開花処理
       GameManager.player_data.add_skill(skill_id)
       # UI通知など
   ```

### Phase 3: UI実装

#### Step 1: 基本画面構築

1. **TrainingScreenの実装**

   ```gdscript
   # scripts/ui/training_screen.gd
   extends Control
   class_name TrainingScreen
   
   # UI要素参照
   @onready var status_panel = $StatusPanel
   @onready var training_options = $TrainingOptions
   @onready var fatigue_bar = $FatigueBar
   @onready var resonance_gauge = $ResonanceGauge
   
   func _ready():
       connect_signals()
       update_ui()
   
   func connect_signals():
       GameManager.training_manager.connect("month_started", Callable(self, "_on_month_started"))
       GameManager.training_manager.connect("training_completed", Callable(self, "_on_training_completed"))
   
   func _on_month_started(month_data):
       update_training_options()
       update_status_display()
   
   func update_training_options():
       # トレーニング選択肢を表示
       var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
       
       for category in categories:
           var training_data = GameManager.data_loader.get_random_training(category)
           # トレーニングカードを作成して表示
           var card = create_training_card(training_data)
           training_options.add_child(card)
   
   func _on_training_completed(result):
       show_training_result(result)
       update_status_display()
       update_skill_progress()
       update_familiarity_bars()
   ```

2. **UI要素の作成**

   トレーニングカード生成:
   ```gdscript
   func create_training_card(training_data: Dictionary) -> Control:
       var card = preload("res://scenes/ui/training_card.tscn").instantiate()
       card.setup(training_data)
       card.connect("pressed", Callable(self, "_on_training_selected").bind(training_data))
       return card
   ```

   ステータス表示更新:
   ```gdscript
   func update_status_display():
       var stats = GameManager.player_data.current_horse.stats
       
       # 各ステータスバーを更新
       status_panel.update_stat_bars(stats)
       
       # 疲労バー更新
       var fatigue = GameManager.training_manager.fatigue
       fatigue_bar.value = fatigue
       
       # 疲労に応じてバーの色を変更
       if fatigue >= 80:
           fatigue_bar.modulate = Color(1, 0.3, 0.3)  # 赤
       elif fatigue >= 60:
           fatigue_bar.modulate = Color(1, 0.9, 0.3)  # 黄
       else:
           fatigue_bar.modulate = Color(0.3, 0.7, 1)  # 青
   ```

### Phase 4: レースシステム

1. **RaceManagerの実装**

   ```gdscript
   # scripts/managers/race_manager.gd
   extends Node
   class_name RaceManager
   
   signal section_started(section)
   signal skills_activated(skills)
   signal positions_updated(positions)
   signal race_finished(results)
   
   var current_section: int = 0  # 0=序盤, 1=中盤, 2=終盤
   var race_scores: Dictionary = {}  # 馬ID => スコア
   var activated_skills: Array = []  # 発動スキル一覧
   
   func start_race() -> void:
       current_section = 0
       race_scores.clear()
       activated_skills.clear()
       
       # NPCの馬を追加（ダミーデータ）
       add_npc_horses()
       
       # レース開始
       process_race()
   
   func process_race() -> void:
       # 各区間を順番に処理
       while current_section < 3:
           emit_signal("section_started", get_section_name())
           
           calculate_section_score()
           process_skills()
           update_positions()
           
           # 少し待機（演出用）
           await get_tree().create_timer(1.5).timeout
           
           current_section += 1
       
       # レース終了
       var results = finish_race()
       emit_signal("race_finished", results)
   
   func calculate_section_score() -> void:
       var section = get_section_name()
       var coefficients = get_section_coefficients(section)
       
       for horse_id in race_scores.keys():
           var horse_stats = get_horse_stats(horse_id)
           var score = 0.0
           
           # 各ステートの重みづけ計算
           for stat_name in coefficients.keys():
               score += horse_stats.get(stat_name, 0) * coefficients[stat_name]
           
           # 区間スコアを加算
           race_scores[horse_id] += score
   
   func process_skills() -> void:
       # スキル発動判定と効果適用
       for horse_id in race_scores.keys():
           var horse_skills = get_horse_skills(horse_id)
           
           for skill in horse_skills:
               if check_skill_activation_condition(skill):
                   apply_skill_effect(horse_id, skill)
                   activated_skills.append(skill)
                   emit_signal("skills_activated", [skill])
   
   func update_positions() -> void:
       # スコアに基づいて順位を更新
       var positions = {}
       var sorted_scores = []
       
       for horse_id in race_scores.keys():
           sorted_scores.append({"id": horse_id, "score": race_scores[horse_id]})
       
       # スコア降順でソート
       sorted_scores.sort_custom(func(a, b): return a.score > b.score)
       
       # 順位をマッピング
       for i in range(sorted_scores.size()):
           positions[sorted_scores[i].id] = i + 1
       
       emit_signal("positions_updated", positions)
   
   func finish_race() -> Dictionary:
       # 最終結果を集計
       var results = {}
       var positions = {}
       var sorted_scores = []
       
       for horse_id in race_scores.keys():
           sorted_scores.append({"id": horse_id, "score": race_scores[horse_id]})
       
       sorted_scores.sort_custom(func(a, b): return a.score > b.score)
       
       for i in range(sorted_scores.size()):
           positions[sorted_scores[i].id] = i + 1
       
       results = {
           "positions": positions,
           "scores": race_scores,
           "activated_skills": activated_skills
       }
       
       return results
   ```

## 📋 コーディングガイドライン

### 命名規則

- **クラス名**: PascalCase (例: `GameManager`)
- **変数名/メソッド名**: snake_case (例: `current_turn`, `update_positions()`)
- **定数**: UPPER_SNAKE_CASE (例: `MAX_FATIGUE`)
- **ノード参照**: 変数名の前に `@onready var` を使用

### シグナルの活用

- 複数の箇所で状態変化を監視する場合はシグナルを活用
- 命名は「動詞_過去分詞」形式 (例: `training_completed`)

### データの管理

- プレイ中のデータは `GameManager` または各マネージャーで一元管理
- 永続化が必要なデータはJSON形式で保存
- セーブデータは `user://` ディレクトリに保存

### UI設計

- UIはシーン分割して再利用可能に設計
- 動的生成が必要なUI要素は明確なメソッドで実装
- テーマ設定を活用して一貫性のあるデザイン適用

### デバッグ補助

```gdscript
# デバッグ出力ユーティリティ関数
func debug_print(message: String, category: String = "INFO") -> void:
    if OS.is_debug_build():
        print("[%s] %s: %s" % [Time.get_time_string_from_system(), category, message])
```

## 🧪 テスト戦略

### 単体テスト

- 独立した機能（成長計算、スキル進行など）は単体で動作確認
- エッジケースのテスト（値の上限/下限、例外条件など）

### 統合テスト

- 複数システム連携の確認（トレーニング→スキル進行→開花）
- 状態遷移の検証（各画面間の正常な遷移）

### バランステスト

- 数値調整用のデバッグメニュー作成
- 典型的な育成パターンでのステータス増加量検証

## 🔧 最適化のヒント

1. **描画負荷の軽減**
   - 画面外の要素は `visible = false` で非表示に
   - 一時停止時は `process_mode = PROCESS_MODE_DISABLED` に設定

2. **メモリ管理**
   - シーン遷移時に不要なリソースは `queue_free()` で解放
   - テクスチャやオーディオは適切な圧縮設定を使用

3. **処理負荷の分散**
   - 重い計算は `_process()` ではなく必要な時だけ実行
   - アニメーション多用時は簡易表現のオプション提供

## 📝 ドキュメント化のポイント

1. **スクリプト内コメント**
   - 複雑なロジックには説明コメントを追加
   - 公開メソッドには引数と戻り値の説明を記載

2. **プロジェクト文書**
   - システム間の連携図を用意
   - データスキーマの定義書を維持
   - バグや解決済み問題のログを残す

## 📅 開発フロー

1. **基本機能の実装** → **データ構造確定** → **UI実装** → **レースシステム** → **バランス調整**

2. 各段階で動作確認を行い、必要に応じてリファクタリング

3. 最小機能セット (MVP) を優先し、後から拡張機能を追加 