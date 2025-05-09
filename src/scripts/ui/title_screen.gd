extends Control

# ボタン参照
@onready var start_button = $VBoxContainer/StartButton
@onready var skill_button = $VBoxContainer/SkillButton
@onready var records_button = $VBoxContainer/RecordsButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var title_label = $VBoxContainer/TitleLabel
@onready var subtitle_label = $VBoxContainer/SubtitleLabel
@onready var decorative_line = $DecorativeLine

func _ready():
	# ボタンシグナル接続
	start_button.pressed.connect(_on_start_button_pressed)
	skill_button.pressed.connect(_on_skill_button_pressed)
	records_button.pressed.connect(_on_records_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# 初期アニメーション
	_play_intro_animation()
	
	# データ状態確認
	_check_data_status()
	
	# ボタン状態の更新
	_update_button_states()

# タイトル入場アニメーション
func _play_intro_animation():
	# 初期状態を設定
	title_label.modulate.a = 0
	subtitle_label.modulate.a = 0
	decorative_line.modulate.a = 0
	start_button.modulate.a = 0
	skill_button.modulate.a = 0
	records_button.modulate.a = 0
	exit_button.modulate.a = 0
	
	# タイトルのフェードイン
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(decorative_line, "modulate:a", 1.0, 0.3)
	
	# 少し待ってからボタンのフェードイン
	tween.tween_interval(0.2)
	tween.tween_property(start_button, "modulate:a", 1.0, 0.3)
	tween.tween_property(skill_button, "modulate:a", 1.0, 0.3)
	tween.tween_property(records_button, "modulate:a", 1.0, 0.3)
	tween.tween_property(exit_button, "modulate:a", 1.0, 0.3)

# データ状態の確認
func _check_data_status():
	# DataLoaderを取得
	var data_loader = get_node("/root/DataLoader")
	if not data_loader:
		print("エラー: DataLoaderにアクセスできません")
		return
		
	# 必要なデータファイルが存在するか確認
	if not data_loader._check_data_files_exist():
		print("データファイルが見つかりません。起動時に自動生成を試みます。")
		data_loader.generate_dummy_data()
		data_loader.save_dummy_data_to_files()
	else:
		print("データファイルを確認しました。")
		# データを読み込み
		data_loader._load_all_data()

# ボタン状態の更新
func _update_button_states():
	# GameManagerからデータ状態を確認
	var game_manager = get_node("/root/GameManager")
	
	# スキル図鑑と育成記録は、データがある場合のみ有効化
	var has_skill_data = game_manager.unlocked_skills.size() > 0
	var has_race_records = game_manager.race_records.size() > 0
	
	# 現状は常に無効化（開発中）
	skill_button.disabled = true # !has_skill_data 
	records_button.disabled = true # !has_race_records
	
	# ボタンスタイルを調整（無効時は透明度を下げる）
	if skill_button.disabled:
		skill_button.modulate.a = 0.5
	if records_button.disabled:
		records_button.modulate.a = 0.5

# 育成開始ボタン
func _on_start_button_pressed():
	print("育成開始ボタンが押されました")
	
	# ボタンの簡易アニメーション
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_callback(func(): 
		# 馬選択画面へ遷移
		get_tree().change_scene_to_file("res://scenes/screens/horse_select_screen.tscn")
	)

# スキル図鑑ボタン
func _on_skill_button_pressed():
	if skill_button.disabled:
		return
		
	print("スキル図鑑ボタンが押されました")
	# スキル図鑑画面へ遷移（未実装）
	# get_tree().change_scene_to_file("res://scenes/screens/skill_book_screen.tscn")

# 育成記録ボタン
func _on_records_button_pressed():
	if records_button.disabled:
		return
		
	print("育成記録ボタンが押されました")
	# 育成記録画面へ遷移（未実装）
	# get_tree().change_scene_to_file("res://scenes/screens/training_records_screen.tscn")

# 終了ボタン
func _on_exit_button_pressed():
	print("終了ボタンが押されました")
	
	# フェードアウトアニメーション
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().quit()) 