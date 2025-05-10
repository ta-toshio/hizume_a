class_name SaveLoadScreen
extends Control

# 定数
const MAX_SAVE_SLOTS = 3

# 変数
var current_mode = "load"  # "save" または "load"
var game_manager
var save_slots = []
var initialization_completed = false  # 初期化完了フラグ
var selected_slot_index = -1  # 選択中のスロットインデックス

# UI参照
@onready var title_label = $PanelContainer/VBoxContainer/TitleLabel
@onready var slots_container = $PanelContainer/VBoxContainer/SlotsContainer
@onready var back_button = $PanelContainer/VBoxContainer/ButtonsContainer/BackButton
@onready var action_button = $PanelContainer/VBoxContainer/ButtonsContainer/ActionButton
@onready var delete_button = $PanelContainer/VBoxContainer/ButtonsContainer/DeleteButton

# シグナル
signal back_requested
signal save_completed

func _ready():
	print("save_load_screen.gd スクリプトがロードされました")
	print("セーブ/ロード画面の_ready()が呼ばれました")
	print("シーンパス: " + get_tree().current_scene.scene_file_path)
	print("自身のクラス: " + get_class())
	print("スクリプトパス: " + get_script().resource_path)
	
	# 必要なノードが存在するか確認
	print("必要なノードの存在確認:")
	print("PanelContainer: " + str(has_node("PanelContainer")))
	if has_node("PanelContainer"):
		print("VBoxContainer: " + str(has_node("PanelContainer/VBoxContainer")))
		if has_node("PanelContainer/VBoxContainer"):
			print("TitleLabel: " + str(has_node("PanelContainer/VBoxContainer/TitleLabel")))
			print("SlotsContainer: " + str(has_node("PanelContainer/VBoxContainer/SlotsContainer")))
			print("ButtonsContainer: " + str(has_node("PanelContainer/VBoxContainer/ButtonsContainer")))
			
			if has_node("PanelContainer/VBoxContainer/ButtonsContainer"):
				print("BackButton: " + str(has_node("PanelContainer/VBoxContainer/ButtonsContainer/BackButton")))
				print("ActionButton: " + str(has_node("PanelContainer/VBoxContainer/ButtonsContainer/ActionButton")))
				print("DeleteButton: " + str(has_node("PanelContainer/VBoxContainer/ButtonsContainer/DeleteButton")))
	
	# GameManagerの参照を取得
	print("GameManager参照の取得を試みます")
	
	# 異なる方法でGameManagerを取得
	game_manager = get_node_or_null("/root/GameManager")  # 直接パスを試す
	
	if not game_manager:
		# 別の方法を試す
		print("直接パスでのGameManager取得に失敗。オートロードノードリストを確認します")
		for node in get_tree().root.get_children():
			print(" - ルートの子: " + node.name + " (" + node.get_class() + ")")
			if node.name == "GameManager":
				game_manager = node
				print("GameManagerを見つけました")
				break
	
	if not game_manager:
		# さらに別の方法を試す: スクリプトクラスでの検索
		print("名前でのGameManager取得に失敗。クラス名で探します")
		for node in get_tree().root.get_children():
			if node.get_class() == "GameManager" or (node.get_script() and node.get_script().get_path().find("game_manager.gd") != -1):
				game_manager = node
				print("スクリプトクラスでGameManagerを見つけました")
				break
	
	if not game_manager:
		print("エラー: GameManagerが見つかりません。ゲーム状態の保存/読み込みができません。")
		# 警告表示を追加
		var warning = Label.new()
		warning.text = "エラー: ゲーム状態管理システムに接続できません。"
		warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		warning.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		warning.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		warning.add_theme_font_size_override("font_size", 16)
		add_child(warning)
		
		# 5秒後に閉じる
		await get_tree().create_timer(5.0).timeout
		emit_signal("back_requested")
		return
	else:
		print("GameManager参照取得成功: " + str(game_manager))
	
	# ノードのキャッシュを確認
	if not title_label or not slots_container or not back_button or not action_button or not delete_button:
		print("警告: UI要素の参照取得に失敗しました")
		print("title_label: " + str(title_label))
		print("slots_container: " + str(slots_container))
		print("back_button: " + str(back_button))
		print("action_button: " + str(action_button))
		print("delete_button: " + str(delete_button))
		
		# 参照の再取得を試みる
		_reload_ui_references()
	
	# ボタンイベントを接続
	print("ボタンイベント接続を試みます")
	if back_button:
		if back_button.is_connected("pressed", _on_back_button_pressed):
			back_button.disconnect("pressed", _on_back_button_pressed)
		back_button.pressed.connect(_on_back_button_pressed)
		print("back_button.pressed接続成功")
	else:
		print("エラー: back_buttonが無効です")
		
	if action_button:
		if action_button.is_connected("pressed", _on_action_button_pressed):
			action_button.disconnect("pressed", _on_action_button_pressed)
		action_button.pressed.connect(_on_action_button_pressed)
		print("action_button.pressed接続成功")
	else:
		print("エラー: action_buttonが無効です")
		
	if delete_button:
		if delete_button.is_connected("pressed", _on_delete_button_pressed):
			delete_button.disconnect("pressed", _on_delete_button_pressed)
		delete_button.pressed.connect(_on_delete_button_pressed)
		print("delete_button.pressed接続成功")
	else:
		print("エラー: delete_buttonが無効です")
	
	# 初期化完了フラグをセット
	initialization_completed = true
	
	# 初期化
	call_deferred("_setup_ui")
	print("セーブ/ロード画面の初期化が完了しました")

# UIを設定する
func _setup_ui():
	print("_setup_ui()が呼ばれました")
	
	if !initialization_completed:
		print("警告: 初期化が完了していない状態で_setup_ui()が呼ばれました")
		# それでも続行する
	
	if !is_instance_valid(title_label) || !is_instance_valid(action_button):
		print("警告: UIの参照が無効です")
		# UIの参照を再取得
		_reload_ui_references()
	
	# それでもUIの参照が無効ならエラーメッセージを表示して終了
	if !is_instance_valid(title_label) || !is_instance_valid(action_button):
		print("警告: UIの参照を取得できませんでした。手動で作成します")
		# 必要なUIを手動で作成
		_create_missing_ui_components()
	
	# モードに応じてUIを調整
	if current_mode == "save":
		if title_label:
			title_label.text = "ゲームをセーブ"
		if action_button:
			action_button.text = "セーブ"
	else:  # load モード
		if title_label:
			title_label.text = "ゲームをロード"
		if action_button:
			action_button.text = "ロード"
	
	# セーブスロット情報の取得
	call_deferred("_refresh_save_slots")

# 不足しているUI要素を作成
func _create_missing_ui_components():
	print("欠落しているUI要素を作成します")
	
	# まずPanelContainerを確認
	var panel = get_node_or_null("PanelContainer")
	if !panel:
		print("PanelContainerを作成")
		panel = PanelContainer.new()
		panel.name = "PanelContainer"
		panel.set_anchors_preset(PRESET_CENTER)
		panel.custom_minimum_size = Vector2(600, 500)
		add_child(panel)
	
	# VBoxContainerを確認
	var vbox = panel.get_node_or_null("VBoxContainer")
	if !vbox:
		print("VBoxContainerを作成")
		vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		vbox.custom_minimum_size = Vector2(580, 480)
		vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		vbox.size_flags_vertical = SIZE_EXPAND_FILL
		panel.add_child(vbox)
	
	# タイトルラベルを確認
	title_label = vbox.get_node_or_null("TitleLabel")
	if !title_label:
		print("TitleLabelを作成")
		title_label = Label.new()
		title_label.name = "TitleLabel"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.text = "ゲームをセーブ/ロード"
		vbox.add_child(title_label)
	
	# 区切り線1を確認
	if !vbox.get_node_or_null("Separator1"):
		print("Separator1を作成")
		var separator1 = HSeparator.new()
		separator1.name = "Separator1"
		vbox.add_child(separator1)
	
	# スロットコンテナを確認
	slots_container = vbox.get_node_or_null("SlotsContainer")
	if !slots_container:
		print("SlotsContainerを作成")
		slots_container = VBoxContainer.new()
		slots_container.name = "SlotsContainer"
		slots_container.size_flags_vertical = SIZE_EXPAND_FILL
		vbox.add_child(slots_container)
	
	# 区切り線2を確認
	if !vbox.get_node_or_null("Separator2"):
		print("Separator2を作成")
		var separator2 = HSeparator.new()
		separator2.name = "Separator2"
		vbox.add_child(separator2)
	
	# ボタンコンテナを確認
	var buttons = vbox.get_node_or_null("ButtonsContainer")
	if !buttons:
		print("ButtonsContainerを作成")
		buttons = HBoxContainer.new()
		buttons.name = "ButtonsContainer"
		buttons.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_child(buttons)
	
	# 戻るボタンを確認
	back_button = buttons.get_node_or_null("BackButton")
	if !back_button:
		print("BackButtonを作成")
		back_button = Button.new()
		back_button.name = "BackButton"
		back_button.text = "戻る"
		back_button.size_flags_horizontal = SIZE_EXPAND_FILL
		buttons.add_child(back_button)
		back_button.pressed.connect(_on_back_button_pressed)
	
	# 削除ボタンを確認
	delete_button = buttons.get_node_or_null("DeleteButton")
	if !delete_button:
		print("DeleteButtonを作成")
		delete_button = Button.new()
		delete_button.name = "DeleteButton"
		delete_button.text = "削除"
		delete_button.size_flags_horizontal = SIZE_EXPAND_FILL
		buttons.add_child(delete_button)
		delete_button.pressed.connect(_on_delete_button_pressed)
	
	# アクションボタンを確認
	action_button = buttons.get_node_or_null("ActionButton")
	if !action_button:
		print("ActionButtonを作成")
		action_button = Button.new()
		action_button.name = "ActionButton"
		action_button.text = "セーブ"
		action_button.size_flags_horizontal = SIZE_EXPAND_FILL
		buttons.add_child(action_button)
		action_button.pressed.connect(_on_action_button_pressed)
	
	print("欠落していたUI要素の作成が完了しました")

# UI参照を再読み込み
func _reload_ui_references():
	print("UI参照を再読み込みします")
	
	# 子ノードの一覧を出力（デバッグ用）
	print("直接の子ノード:")
	for child in get_children():
		print(" - " + child.name + " (" + child.get_class() + ")")
		
		# さらに子ノードを探索
		for subchild in child.get_children():
			print("   - " + subchild.name + " (" + subchild.get_class() + ")")
	
	# パネルコンテナを探す
	var panel = null
	if has_node("PanelContainer"):
		panel = get_node("PanelContainer")
	else:
		# 子ノード内を直接探索
		for child in get_children():
			if child is PanelContainer:
				panel = child
				break
	
	if !panel:
		print("エラー: PanelContainerが見つかりません")
		return
		
	# VBoxContainerを探す
	var vbox = null
	if panel.has_node("VBoxContainer"):
		vbox = panel.get_node("VBoxContainer")
	else:
		# 子ノード内を直接探索
		for child in panel.get_children():
			if child is VBoxContainer:
				vbox = child
				break
	
	if !vbox:
		print("エラー: VBoxContainerが見つかりません")
		return
	
	# 参照の再取得
	if vbox.has_node("TitleLabel"):
		title_label = vbox.get_node("TitleLabel")
	if vbox.has_node("SlotsContainer"):
		slots_container = vbox.get_node("SlotsContainer")
	
	# ボタンコンテナを探す
	var buttons_container = null
	if vbox.has_node("ButtonsContainer"):
		buttons_container = vbox.get_node("ButtonsContainer")
	
	if buttons_container:
		if buttons_container.has_node("BackButton"):
			back_button = buttons_container.get_node("BackButton")
		if buttons_container.has_node("ActionButton"):
			action_button = buttons_container.get_node("ActionButton")
		if buttons_container.has_node("DeleteButton"):
			delete_button = buttons_container.get_node("DeleteButton")
	
	print("UI参照再読み込み結果:")
	print(" - title_label: " + str(title_label))
	print(" - slots_container: " + str(slots_container))
	print(" - back_button: " + str(back_button))
	print(" - action_button: " + str(action_button))
	print(" - delete_button: " + str(delete_button))

# スロット情報をリフレッシュ
func _refresh_save_slots():
	print("_refresh_save_slots()が呼ばれました")
	
	# GameManagerの有効性を確認
	if !is_instance_valid(game_manager):
		print("エラー: GameManagerが無効です")
		# GameManagerの再取得を試みる
		game_manager = get_node_or_null("/root/GameManager")
		if !is_instance_valid(game_manager):
			print("エラー: GameManagerを再取得できませんでした")
			_show_notification("エラー: ゲーム状態を読み込めません")
			return
	
	# slots_containerの有効性を確認
	if !is_instance_valid(slots_container):
		print("エラー: slots_containerが無効です")
		# slots_containerの再取得を試みる
		if has_node("PanelContainer/VBoxContainer/SlotsContainer"):
			slots_container = get_node("PanelContainer/VBoxContainer/SlotsContainer")
		else:
			print("エラー: slots_containerを再取得できませんでした")
			_show_notification("エラー: UIを正しく読み込めません")
			return
	
	# セーブスロット情報を取得
	save_slots = []
	print("セーブスロット情報の取得を開始")
	
	# GameManagerのメソッド呼び出しをtry-catchで保護
	if game_manager.has_method("get_available_save_slots"):
		# 例外を捕捉
		var success = false
		var error_message = ""
		
		save_slots = game_manager.get_available_save_slots(MAX_SAVE_SLOTS)
		success = save_slots != null && save_slots.size() > 0
		
		if success:
			print("セーブスロット情報を取得: " + str(save_slots.size()) + "個のスロット")
		else:
			print("エラー: get_available_save_slotsからの返却が無効です")
			# ダミーデータでUIだけ表示
			_create_dummy_save_slots()
	else:
		print("エラー: GameManagerにget_available_save_slotsメソッドがありません")
		# ダミーデータでUIだけ表示
		_create_dummy_save_slots()
	
	# スロットボタンの作成
	_create_slot_buttons()

# ダミーのセーブスロットデータを作成
func _create_dummy_save_slots():
	print("ダミーのセーブスロットデータを作成")
	save_slots = []
	for i in range(MAX_SAVE_SLOTS):
		save_slots.append({
			"slot": i + 1,
			"exists": false,
			"info": "スロット " + str(i + 1) + " (データなし)"
		})
	print("ダミーデータを作成しました: " + str(save_slots.size()) + "個のスロット")

# スロットボタンを作成
func _create_slot_buttons():
	print("スロットボタンを作成")
	
	if !is_instance_valid(slots_container):
		print("エラー: slots_containerが無効です")
		return
	
	# 既存のスロットボタンをクリア
	for child in slots_container.get_children():
		slots_container.remove_child(child)
		child.queue_free()
	
	# スロットボタンを作成
	for slot_data in save_slots:
		var slot_button = Button.new()
		slot_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_button.custom_minimum_size = Vector2(0, 80)
		
		var slot_text = "スロット " + str(slot_data.slot) + ": "
		slot_text += slot_data.info if "info" in slot_data else "データなし"
		
		print("スロット" + str(slot_data.slot) + "情報: " + str(slot_data))
		
		slot_button.text = slot_text
		slot_button.pressed.connect(_on_slot_button_pressed.bind(slot_data.slot))
		
		# 存在しないセーブデータの場合は表示を変更
		if current_mode == "load" && (!slot_data.has("exists") || !slot_data.exists):
			slot_button.disabled = true
			slot_button.modulate.a = 0.5
		
		slots_container.add_child(slot_button)
	
	# 初期状態ではアクションと削除ボタンを無効化
	if is_instance_valid(action_button):
		action_button.disabled = true
	if is_instance_valid(delete_button):
		delete_button.disabled = true
	
	print("スロットボタンの初期化完了")

# セーブモードを設定する
func set_save_mode():
	print("set_save_mode()が呼ばれました")
	current_mode = "save"
	_setup_ui()

# ロードモードを設定する
func set_load_mode():
	print("set_load_mode()が呼ばれました")
	current_mode = "load"
	_setup_ui()

# スロットボタンが押されたとき
func _on_slot_button_pressed(slot_number):
	print("スロットボタンが押されました: " + str(slot_number))
	
	# 選択されたスロット番号を保存
	var selected_slot = slot_number
	selected_slot_index = slot_number - 1
	
	# すべてのスロットボタンの見た目をリセット
	if is_instance_valid(slots_container):
		for i in range(slots_container.get_child_count()):
			var button = slots_container.get_child(i)
			if is_instance_valid(button):
				# 選択中のボタンには強調表示を適用
				if i + 1 == selected_slot:
					button.add_theme_color_override("font_color", Color(1, 0.5, 0))
					button.add_theme_color_override("font_focus_color", Color(1, 0.5, 0))
				else:
					button.remove_theme_color_override("font_color")
					button.remove_theme_color_override("font_focus_color")
	
	# ボタンを有効化
	if is_instance_valid(action_button):
		action_button.disabled = false
	
	# 削除ボタンは、スロットにデータがある場合のみ有効化
	if selected_slot - 1 < save_slots.size():
		var slot_data = save_slots[selected_slot - 1]
		if is_instance_valid(delete_button):
			delete_button.disabled = not (slot_data.has("exists") && slot_data.exists)
		
		# セーブモードでは常にセーブボタンを有効化、ロードモードではデータがある場合のみ
		if is_instance_valid(action_button):
			if current_mode == "save":
				action_button.disabled = false
			else:  # load モード
				action_button.disabled = not (slot_data.has("exists") && slot_data.exists)

# 戻るボタンが押されたとき
func _on_back_button_pressed():
	emit_signal("back_requested")

# アクションボタン（セーブ/ロード）が押されたとき
func _on_action_button_pressed():
	print("アクションボタンが押されました（モード: " + current_mode + "）")

	# 選択されているスロットを取得
	var selected_slot = -1
	if selected_slot_index >= 0 && selected_slot_index < slots_container.get_child_count():
		selected_slot = selected_slot_index + 1
	
	if selected_slot == -1:
		print("エラー: スロットが選択されていません")
		return
	
	print("選択されたスロット: " + str(selected_slot))
	
	if current_mode == "save":
		# セーブ処理
		print("セーブ処理を開始します（スロット: " + str(selected_slot) + "）")
		var success = game_manager.save_game(selected_slot)
		if success:
			# セーブ成功の通知表示
			print("セーブが成功しました")
			_show_notification("セーブが完了しました")
			# スロット情報を更新
			_refresh_save_slots()
			# セーブ完了シグナルを発行
			print("save_completedシグナルを発行します")
			emit_signal("save_completed")
		else:
			print("セーブに失敗しました")
			_show_notification("セーブに失敗しました")
	else:  # load モード
		# ロード処理
		var success = game_manager.load_game(selected_slot)
		if success:
			# ロード成功の通知表示
			_show_notification("ロードが完了しました")
			# トレーニング画面に戻る
			await get_tree().create_timer(1.0).timeout
			emit_signal("back_requested")
		else:
			_show_notification("ロードに失敗しました")

# 削除ボタンが押されたとき
func _on_delete_button_pressed():
	# 選択されているスロットを取得
	var selected_slot = -1
	if selected_slot_index >= 0 && selected_slot_index < slots_container.get_child_count():
		selected_slot = selected_slot_index + 1
	
	if selected_slot == -1:
		print("エラー: スロットが選択されていません")
		return
	
	# 削除確認ダイアログを表示
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "確認"
	confirm_dialog.dialog_text = "セーブデータを削除してもよろしいですか？"
	confirm_dialog.min_size = Vector2(300, 100)
	
	confirm_dialog.confirmed.connect(func():
		var success = game_manager.delete_save(selected_slot)
		if success:
			_show_notification("セーブデータを削除しました")
			_refresh_save_slots()
		else:
			_show_notification("削除に失敗しました")
	)
	
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

# 通知を表示する
func _show_notification(message):
	print("通知表示: " + message)
	
	# シンプルな方法を試す
	var notification = Label.new()
	notification.text = message
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification.add_theme_color_override("font_color", Color(1, 1, 1))
	notification.add_theme_font_size_override("font_size", 24)
	
	# パネルを作成
	var panel = PanelContainer.new()
	panel.add_child(notification)
	panel.custom_minimum_size = Vector2(300, 80)
	
	# 画面中央に配置
	var rect = get_viewport_rect().size
	panel.position = Vector2(
		(rect.x - panel.custom_minimum_size.x) / 2,
		(rect.y - panel.custom_minimum_size.y) / 2
	)
	
	# シーンツリーに追加
	add_child(panel)
	
	# 2秒後に通知を削除
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): 
		if is_instance_valid(panel):
			panel.queue_free()
	) 
