extends Control

# UI要素の参照
@onready var rider_type_button = $MarginContainer/VBoxContainer/EquipmentTypeContainer/RiderTypeButton
@onready var horse_type_button = $MarginContainer/VBoxContainer/EquipmentTypeContainer/HorseTypeButton
@onready var manual_type_button = $MarginContainer/VBoxContainer/EquipmentTypeContainer/ManualTypeButton
@onready var equipment_grid = $MarginContainer/VBoxContainer/EquipmentScrollContainer/EquipmentGrid
@onready var equipment_item_template = $MarginContainer/VBoxContainer/EquipmentScrollContainer/EquipmentGrid/EquipmentItemTemplate
@onready var selected_rider_label = $MarginContainer/VBoxContainer/SelectedInfoContainer/SelectedRiderContainer/MarginContainer/VBoxContainer/SelectedLabel
@onready var selected_horse_label = $MarginContainer/VBoxContainer/SelectedInfoContainer/SelectedHorseContainer/MarginContainer/VBoxContainer/SelectedLabel
@onready var selected_manual_label = $MarginContainer/VBoxContainer/SelectedInfoContainer/SelectedManualContainer/MarginContainer/VBoxContainer/SelectedLabel
@onready var back_button = $MarginContainer/VBoxContainer/ButtonContainer/BackButton
@onready var next_button = $MarginContainer/VBoxContainer/ButtonContainer/NextButton

# 装備データ参照
var equipment_items = {}  # カテゴリごとの装備リスト
var selected_equipment = {}  # カテゴリごとの選択された装備
var current_category = "騎手"  # 現在選択中のカテゴリ
var selected_item_nodes = {}  # 選択中の装備UI要素を追跡

func _ready():
	# テンプレートを非表示にする
	equipment_item_template.visible = false
	
	# シグナル接続
	rider_type_button.pressed.connect(func(): _on_type_button_pressed("騎手"))
	horse_type_button.pressed.connect(func(): _on_type_button_pressed("装備"))
	manual_type_button.pressed.connect(func(): _on_type_button_pressed("指南書"))
	back_button.pressed.connect(_on_back_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	
	# データローダーから装備データを取得
	var data_loader = DataLoader.get_instance()
	if data_loader:
		_load_equipment_data(data_loader)
	else:
		print("警告: DataLoaderがロードされていません")
	
	# 初期表示
	_update_type_button_states()
	_load_category_equipment(current_category)
	
	# 初期状態ではトレーニング開始ボタンを無効化
	next_button.disabled = true

# タイプボタンの状態を更新
func _update_type_button_states():
	rider_type_button.button_pressed = current_category == "騎手"
	horse_type_button.button_pressed = current_category == "装備"
	manual_type_button.button_pressed = current_category == "指南書"

# 装備データのロード
func _load_equipment_data(data_loader: DataLoader) -> void:
	# カテゴリごとに装備を分類
	equipment_items = {
		"騎手": [],
		"装備": [],
		"指南書": []
	}
	
	# すべての装備IDを取得
	var all_equipment_ids = data_loader.get_all_equipment_ids()
	
	# 各装備をカテゴリごとに分類
	for equipment_id in all_equipment_ids:
		var equipment = data_loader.get_equipment(equipment_id)
		if equipment:
			# カテゴリに基づいて分類（日本語名に変換）
			var category_jp = "装備"  # デフォルト
			match equipment.category:
				"rider":
					category_jp = "騎手"
				"horse":
					category_jp = "装備"
				"manual":
					category_jp = "指南書"
			
			equipment_items[category_jp].append(equipment)

# タイプボタン押下時
func _on_type_button_pressed(category: String) -> void:
	current_category = category
	_update_type_button_states()
	_load_category_equipment(current_category)

# カテゴリ装備の表示
func _load_category_equipment(category: String) -> void:
	# 既存の装備アイテムをクリア（テンプレート以外）
	for child in equipment_grid.get_children():
		if child != equipment_item_template:
			child.queue_free()
	
	# カテゴリの装備を表示
	if equipment_items.has(category) and equipment_items[category].size() > 0:
		for equipment in equipment_items[category]:
			_add_equipment_item(equipment)
	else:
		print("カテゴリ「" + category + "」の装備はありません")
	
	# 装備を選択状態に
	_update_selection_ui()

# 装備アイテムをグリッドに追加
func _add_equipment_item(equipment: Equipment) -> void:
	# テンプレートを複製
	var item = equipment_item_template.duplicate()
	item.visible = true
	equipment_grid.add_child(item)
	
	# 装備情報を設定
	var name_label = item.get_node("MarginContainer/VBoxContainer/NameLabel")
	var rarity_label = item.get_node("MarginContainer/VBoxContainer/RarityLabel")
	var category_label = item.get_node("MarginContainer/VBoxContainer/CategoryLabel")
	var effect_preview = item.get_node("MarginContainer/VBoxContainer/EffectPreview")
	var selected_indicator = item.get_node("SelectedIndicator")
	
	if name_label:
		name_label.text = equipment.name
	if rarity_label:
		rarity_label.text = equipment.rarity
	if category_label:
		category_label.text = equipment.get_category_jp()
	if effect_preview and equipment.effects.size() > 0:
		var effect = equipment.effects[0]
		var sign = "+" if effect.value > 0 else ""
		var percent = "%" if effect.has("is_percentage") and effect.is_percentage else ""
		effect_preview.text = effect.type + " " + sign + str(effect.value) + percent
	
	# 選択中の装備をハイライト
	if selected_equipment.has(current_category) and selected_equipment[current_category].id == equipment.id:
		selected_indicator.visible = true
		selected_item_nodes[current_category] = item
	else:
		selected_indicator.visible = false
	
	# クリックイベント - 直接選択する
	item.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_equipment_item_selected(equipment, item)
	)

# 装備アイテム選択時
func _on_equipment_item_selected(equipment: Equipment, item_node: Node) -> void:
	# 以前の選択を解除
	if selected_item_nodes.has(current_category) and is_instance_valid(selected_item_nodes[current_category]):
		selected_item_nodes[current_category].get_node("SelectedIndicator").visible = false
	
	# 新しい選択を適用
	selected_equipment[current_category] = equipment
	item_node.get_node("SelectedIndicator").visible = true
	selected_item_nodes[current_category] = item_node
	
	# 選択表示を更新
	_update_selection_ui()
	
	# トレーニング開始ボタンの状態を更新
	_update_next_button_state()

# 選択表示の更新
func _update_selection_ui() -> void:
	# 騎手の選択状態
	if selected_equipment.has("騎手"):
		selected_rider_label.text = selected_equipment["騎手"].name
	else:
		selected_rider_label.text = "未選択"
	
	# 装備の選択状態
	if selected_equipment.has("装備"):
		selected_horse_label.text = selected_equipment["装備"].name
	else:
		selected_horse_label.text = "未選択"
	
	# 指南書の選択状態
	if selected_equipment.has("指南書"):
		selected_manual_label.text = selected_equipment["指南書"].name
	else:
		selected_manual_label.text = "未選択"

# トレーニング開始ボタンの状態を更新
func _update_next_button_state() -> void:
	# すべてのカテゴリに装備が選択されているかチェック
	var all_equipped = selected_equipment.has("騎手") and selected_equipment.has("装備") and selected_equipment.has("指南書")
	next_button.disabled = not all_equipped

# 戻るボタン押下時
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/horse_select_screen.tscn")

# トレーニング開始ボタン押下時
func _on_next_button_pressed() -> void:
	if next_button.disabled:
		return
	
	# GameManagerに選択された装備を設定
	var game_manager = GameManager.get_instance()
	if game_manager:
		# 選択された装備をGameManagerに設定
		var equipment_dict = {}
		for category in selected_equipment:
			var category_en = "horse"  # デフォルト
			match category:
				"騎手":
					category_en = "rider"
				"装備":
					category_en = "horse" 
				"指南書":
					category_en = "manual"
			
			equipment_dict[category_en] = selected_equipment[category]
		
		game_manager.current_equipment = equipment_dict
		
		# トレーニング開始
		game_manager.start_new_training(game_manager.current_horse, equipment_dict)
		
		# トレーニング画面へ遷移
		print("トレーニング画面へ遷移します")
		get_tree().change_scene_to_file("res://scenes/screens/training_screen.tscn")
	else:
		print("エラー: GameManagerが見つかりません") 
