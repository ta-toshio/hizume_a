extends Control

# UI要素の参照
@onready var category_tabs = $MarginContainer/VBoxContainer/CategoryTabs
@onready var equipment_grid = $MarginContainer/VBoxContainer/ContentContainer/EquipmentGrid
@onready var equipment_item_template = $MarginContainer/VBoxContainer/ContentContainer/EquipmentGrid/EquipmentItemTemplate
@onready var equipment_detail_panel = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel
@onready var name_label = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel/PanelContainer/MarginContainer/VBoxContainer/NameContainer/NameLabel
@onready var rarity_label = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel/PanelContainer/MarginContainer/VBoxContainer/NameContainer/RarityLabel
@onready var description_label = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel/PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var effects_container = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel/PanelContainer/MarginContainer/VBoxContainer/EffectsContainer
@onready var related_skills_container = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel/PanelContainer/MarginContainer/VBoxContainer/RelatedSkillsContainer
@onready var equip_button = $MarginContainer/VBoxContainer/ContentContainer/EquipmentDetailPanel/EquipButton
@onready var back_button = $MarginContainer/VBoxContainer/ButtonContainer/BackButton
@onready var next_button = $MarginContainer/VBoxContainer/ButtonContainer/NextButton

# 装備データ参照
var equipment_items = {}  # カテゴリごとの装備リスト
var selected_equipment = {}  # カテゴリごとの選択された装備
var current_category = "騎手"  # 現在選択中のカテゴリ
var selected_equipment_id = ""  # 現在選択中の装備ID

func _ready():
	# テンプレートを非表示にする
	equipment_item_template.visible = false
	
	# シグナル接続
	category_tabs.tab_changed.connect(_on_category_tab_changed)
	equip_button.pressed.connect(_on_equip_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	
	# データローダーから装備データを取得
	var data_loader = DataLoader.get_instance()
	if data_loader:
		_load_equipment_data(data_loader)
	else:
		print("警告: DataLoaderがロードされていません")
	
	# 初期表示
	_load_category_equipment(current_category)
	
	# 初期状態では選択ボタンとトレーニング開始ボタンを無効化
	equip_button.disabled = true
	next_button.disabled = true

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

# カテゴリタブ変更時
func _on_category_tab_changed(tab_idx: int) -> void:
	# タブインデックスからカテゴリ名を取得
	var categories = ["騎手", "装備", "指南書"]
	if tab_idx >= 0 and tab_idx < categories.size():
		current_category = categories[tab_idx]
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
	
	# 既に選択されている装備があれば、その情報を表示
	if selected_equipment.has(current_category):
		var selected = selected_equipment[current_category]
		_display_equipment_details(selected)
		selected_equipment_id = selected.id
	else:
		# 選択されていない場合は詳細をクリア
		_clear_equipment_details()
		selected_equipment_id = ""
	
	# 装備選択ボタンの更新
	equip_button.disabled = selected_equipment_id.is_empty()

# 装備アイテムをグリッドに追加
func _add_equipment_item(equipment: Equipment) -> void:
	# テンプレートを複製
	var item = equipment_item_template.duplicate()
	item.visible = true
	equipment_grid.add_child(item)
	
	# 装備情報を設定
	var name_label = item.get_node("MarginContainer/VBoxContainer/NameLabel")
	var rarity_label = item.get_node("MarginContainer/VBoxContainer/RarityLabel")
	
	if name_label:
		name_label.text = equipment.name
	if rarity_label:
		rarity_label.text = equipment.rarity
	
	# 選択中の装備をハイライト
	if equipment.id == selected_equipment_id:
		item.add_theme_color_override("background_color", Color(0.3, 0.5, 0.7, 0.5))
	
	# クリックイベント
	item.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_equipment_item_selected(equipment.id)
	)

# 装備アイテム選択時
func _on_equipment_item_selected(equipment_id: String) -> void:
	selected_equipment_id = equipment_id
	
	# データローダーから装備情報を取得
	var data_loader = DataLoader.get_instance()
	if data_loader:
		var equipment = data_loader.get_equipment(equipment_id)
		if equipment:
			_display_equipment_details(equipment)
			# 選択状態を更新
			_update_selection_state()
	
	# 装備選択ボタンを有効化
	equip_button.disabled = false

# 装備詳細の表示
func _display_equipment_details(equipment: Equipment) -> void:
	# 基本情報
	name_label.text = equipment.name
	rarity_label.text = equipment.rarity
	description_label.text = equipment.description
	
	# 効果
	_clear_container(effects_container)
	for effect in equipment.effects:
		var effect_label = Label.new()
		var percent_symbol = ""
		# is_percentageプロパティの存在を確認
		if effect.has("is_percentage") and effect.is_percentage:
			percent_symbol = "%"
		effect_label.text = "• " + effect.type + " " + ("+" if effect.value > 0 else "") + str(effect.value) + percent_symbol
		effects_container.add_child(effect_label)
	
	# 関連スキル
	_clear_container(related_skills_container)
	if equipment.associated_skill_ids.size() > 0:
		var data_loader = DataLoader.get_instance()
		for skill_id in equipment.associated_skill_ids:
			var skill = data_loader.get_skill(skill_id)
			if skill:
				var skill_label = Label.new()
				skill_label.text = "• " + skill.name
				related_skills_container.add_child(skill_label)
	else:
		var no_skill_label = Label.new()
		no_skill_label.text = "関連スキルはありません"
		related_skills_container.add_child(no_skill_label)

# コンテナの中身をクリア
func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

# 装備詳細をクリア
func _clear_equipment_details() -> void:
	name_label.text = ""
	rarity_label.text = ""
	description_label.text = "装備を選択してください"
	_clear_container(effects_container)
	_clear_container(related_skills_container)

# 選択状態の更新
func _update_selection_state() -> void:
	# 装備グリッドの選択状態を更新
	for child in equipment_grid.get_children():
		if child != equipment_item_template and child.visible:
			var item_name = child.get_node("MarginContainer/VBoxContainer/NameLabel").text
			var data_loader = DataLoader.get_instance()
			var selected = false
			
			for equipment in equipment_items[current_category]:
				if equipment.id == selected_equipment_id and equipment.name == item_name:
					selected = true
					break
			
			if selected:
				child.add_theme_color_override("background_color", Color(0.3, 0.5, 0.7, 0.5))
			else:
				child.remove_theme_color_override("background_color")
	
	# トレーニング開始ボタンの状態を更新
	_update_next_button_state()

# 装備選択ボタン押下時
func _on_equip_button_pressed() -> void:
	if selected_equipment_id.is_empty():
		return
	
	# データローダーから装備情報を取得
	var data_loader = DataLoader.get_instance()
	if data_loader:
		var equipment = data_loader.get_equipment(selected_equipment_id)
		if equipment:
			# 現在のカテゴリに装備を設定
			selected_equipment[current_category] = equipment
			print(current_category + "カテゴリに「" + equipment.name + "」を装備しました")
			
			# トレーニング開始ボタンの状態を更新
			_update_next_button_state()

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
		
		# トレーニング画面へ遷移（未実装の場合はタイトルに戻る）
		print("トレーニング画面は未実装です。タイトル画面に戻ります。")
		get_tree().change_scene_to_file("res://scenes/screens/title_screen.tscn")
	else:
		print("エラー: GameManagerが見つかりません") 
