extends Control

# ボタン参照
@onready var start_button = $VBoxContainer/StartButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var skill_button = $VBoxContainer/SkillButton
@onready var records_button = $VBoxContainer/RecordsButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var title_label = $VBoxContainer/TitleLabel
@onready var subtitle_label = $VBoxContainer/SubtitleLabel
@onready var decorative_line = $DecorativeLine

# シーン参照
var save_load_screen_scene = null  # 必要なときにロードする
var save_load_screen_instance = null

func _ready():
	# ボタンシグナル接続
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
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
	load_button.modulate.a = 0
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
	tween.tween_property(load_button, "modulate:a", 1.0, 0.3)
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

# ロードボタン
func _on_load_button_pressed():
	print("ロードボタンが押されました")
	
	# ボタンの簡易アニメーション
	var tween = create_tween()
	tween.tween_property(load_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(load_button, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_callback(func():
		_show_load_screen()
	)

# ロード画面を表示
func _show_load_screen():
	print("ロード画面表示関数呼び出し")
	
	# SaveLoadScreenスクリプトの読み込み
	var script_class = load("res://scripts/ui/save_load_screen.gd")
	if script_class == null:
		print("エラー: SaveLoadScreenスクリプトを読み込めませんでした")
		# エラーダイアログを表示
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "エラー"
		error_dialog.dialog_text = "セーブデータ読み込み機能の準備に失敗しました。\n開発者に問い合わせてください。"
		add_child(error_dialog)
		error_dialog.popup_centered()
		return
	
	print("SaveLoadScreenスクリプトを読み込みました: " + str(script_class))
	
	# 既存のインスタンスを削除
	if save_load_screen_instance != null:
		if is_instance_valid(save_load_screen_instance):
			print("既存のロード画面を削除します")
			if save_load_screen_instance.is_connected("back_requested", _on_load_screen_closed):
				save_load_screen_instance.disconnect("back_requested", _on_load_screen_closed)
			save_load_screen_instance.queue_free()
		save_load_screen_instance = null
	
	# 動的にロード画面を作成
	print("ロード画面を動的に作成します")
	
	# Controlノードを作成
	var screen = Control.new()
	if !is_instance_valid(screen):
		print("エラー: Controlノードの作成に失敗しました")
		return
		
	screen.set_script(script_class)
	if !screen.get_script():
		print("エラー: スクリプトの設定に失敗しました")
		screen.queue_free()
		return
		
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)  # 画面全体に広げる
	
	# UIを構築
	var background = ColorRect.new()
	background.color = Color(0.11, 0.3, 0.5)  # 青色の背景
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_child(background)
	
	# パネルコンテナを追加
	var panel = PanelContainer.new()
	panel.name = "PanelContainer"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(600, 500)
	panel.position = Vector2(-300, -250)
	screen.add_child(panel)
	
	# 垂直ボックスを追加
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.custom_minimum_size = Vector2(580, 480)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(vbox)
	
	# タイトルラベルを追加
	var title = Label.new()
	title.name = "TitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "ゲームをロード"
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)
	
	# 区切り線1
	var separator1 = HSeparator.new()
	separator1.name = "Separator1"
	vbox.add_child(separator1)
	
	# スロットコンテナ
	var slots = VBoxContainer.new()
	slots.name = "SlotsContainer"
	slots.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(slots)
	
	# 区切り線2
	var separator2 = HSeparator.new()
	separator2.name = "Separator2"
	vbox.add_child(separator2)
	
	# ボタンコンテナ
	var buttons = HBoxContainer.new()
	buttons.name = "ButtonsContainer"
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(buttons)
	
	# 戻るボタン
	var back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "戻る"
	back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(back_button)
	
	# 削除ボタン
	var delete_button = Button.new()
	delete_button.name = "DeleteButton"
	delete_button.text = "削除"
	delete_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(delete_button)
	
	# アクションボタン
	var action_button = Button.new()
	action_button.name = "ActionButton"
	action_button.text = "ロード"
	action_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(action_button)
	
	# インスタンスを保存
	save_load_screen_instance = screen
	print("ロード画面作成完了: " + str(save_load_screen_instance) + ", クラス: " + screen.get_class())
	
	# シーンツリーに追加
	add_child(save_load_screen_instance)
	print("ロード画面をシーンツリーに追加: 子ノード数=" + str(get_child_count()))
	
	# インスタンスの有効性を確認
	if is_instance_valid(save_load_screen_instance):
		print("ロード画面インスタンスは有効です")
		
		# シグナル確認と接続
		print("シグナル接続を開始...")
		
		# シグナルが存在するか確認
		if !save_load_screen_instance.has_signal("back_requested"):
			print("警告: back_requestedシグナルが見つかりません。手動で定義します。")
			save_load_screen_instance.add_user_signal("back_requested")
		
		save_load_screen_instance.connect("back_requested", _on_load_screen_closed)
		print("シグナル接続完了")
		
		# モード設定（_ready関数が実行された後に設定）
		print("ロードモードを設定します")
		call_deferred("_deferred_set_load_mode")
		
		# 画面を表示
		save_load_screen_instance.visible = true
		print("ロード画面の表示設定: " + str(save_load_screen_instance.visible))
	else:
		print("エラー: ロード画面インスタンスが無効です")
		# エラーダイアログ表示
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "エラー"
		error_dialog.dialog_text = "ロード画面の表示に失敗しました。"
		add_child(error_dialog)
		error_dialog.popup_centered()

# ロードモードを遅延設定（_readyの後に呼ばれる）
func _deferred_set_load_mode():
	if is_instance_valid(save_load_screen_instance):
		if save_load_screen_instance.has_method("set_load_mode"):
			save_load_screen_instance.set_load_mode()
			print("ロードモードを設定しました")
		else:
			print("警告: set_load_modeメソッドが見つかりません。手動で初期化します。")
			_manual_init_load_mode()
	else:
		print("エラー: 遅延初期化時にインスタンスが無効です")

# 手動でロードモードを初期化（メソッドが見つからないとき用）
func _manual_init_load_mode():
	if is_instance_valid(save_load_screen_instance):
		# タイトルラベルを設定
		var title_label = save_load_screen_instance.get_node_or_null("PanelContainer/VBoxContainer/TitleLabel")
		if title_label:
			title_label.text = "ゲームをロード"
		
		# アクションボタンを設定
		var action_button = save_load_screen_instance.get_node_or_null("PanelContainer/VBoxContainer/ButtonsContainer/ActionButton")
		if action_button:
			action_button.text = "ロード"
		
		# 必要ならスロットの更新を手動で呼び出す
		if save_load_screen_instance.has_method("_refresh_save_slots"):
			save_load_screen_instance._refresh_save_slots()

# ロード画面が閉じられたとき
func _on_load_screen_closed():
	if save_load_screen_instance:
		save_load_screen_instance.visible = false
		
		# ゲーム状態を確認してトレーニング画面に遷移
		var game_manager = GameManager.get_instance()
		if game_manager and game_manager.current_horse and game_manager.is_game_loaded:
			# データがロードされた場合のみトレーニング画面へ
			get_tree().change_scene_to_file("res://scenes/screens/training_screen.tscn")
		else:
			print("ロード画面を閉じましたが、ゲームデータは読み込まれていません")
