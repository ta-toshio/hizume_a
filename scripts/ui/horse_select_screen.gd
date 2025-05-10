extends Control

# 馬リスト関連
@onready var horse_list_container = $MarginContainer/VBoxContainer/HBoxContainer/HorseList/ScrollContainer/VBoxContainer
@onready var horse_item_template = $MarginContainer/VBoxContainer/HBoxContainer/HorseList/ScrollContainer/VBoxContainer/HorseItemTemplate

# 馬詳細関連
@onready var name_label = $MarginContainer/VBoxContainer/HBoxContainer/HorseDetails/NameLabel
@onready var description_label = $MarginContainer/VBoxContainer/HBoxContainer/HorseDetails/DescriptionLabel
@onready var stats_grid = $MarginContainer/VBoxContainer/HBoxContainer/HorseDetails/StatsGrid
@onready var aptitude_label = $MarginContainer/VBoxContainer/HBoxContainer/HorseDetails/AptitudeLabel
@onready var select_button = $MarginContainer/VBoxContainer/HBoxContainer/HorseDetails/SelectButton
@onready var back_button = $MarginContainer/VBoxContainer/ButtonContainer/BackButton

# 現在選択中の馬ID
var selected_horse_id: String = ""

func _ready():
	# ボタンシグナル接続
	select_button.pressed.connect(_on_select_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# データローダーからダミー馬リストを取得して表示
	var data_loader = DataLoader.get_instance()
	if data_loader:
		_load_horse_list(data_loader)
	else:
		print("警告: DataLoaderがロードされていません")
		
	# 初期状態では選択ボタンを無効化
	select_button.disabled = true

# 馬リスト読み込み
func _load_horse_list(data_loader: DataLoader) -> void:
	var horse_ids = data_loader.get_all_horse_ids()
	
	if horse_ids.is_empty():
		print("警告: 馬データが存在しません")
		return
	
	# 各馬のボタンを作成
	for horse_id in horse_ids:
		var horse_data = data_loader._horses_data[horse_id]
		var horse_button = horse_item_template.duplicate()
		horse_button.visible = true
		horse_button.text = horse_data.name
		horse_button.pressed.connect(_on_horse_selected.bind(horse_id))
		horse_list_container.add_child(horse_button)
	
	# 最初の馬を自動選択
	if not horse_ids.is_empty():
		_on_horse_selected(horse_ids[0])

# 馬選択時
func _on_horse_selected(horse_id: String) -> void:
	selected_horse_id = horse_id
	
	# DataLoaderから馬データを取得して詳細を表示
	var data_loader = DataLoader.get_instance()
	if data_loader and data_loader._horses_data.has(horse_id):
		var horse_data = data_loader._horses_data[horse_id]
		_display_horse_details(horse_data)
		
		# 選択ボタンを有効化
		select_button.disabled = false
	else:
		print("エラー: 選択された馬IDが無効です: ", horse_id)

# 馬の詳細情報を表示
func _display_horse_details(horse_data: Dictionary) -> void:
	# 基本情報
	name_label.text = horse_data.name
	description_label.text = horse_data.description
	
	# ステータス情報
	if horse_data.has("base_stats"):
		var stats = horse_data.base_stats
		_set_stat_value("speed", stats.speed)
		_set_stat_value("stamina", stats.stamina)
		_set_stat_value("technique", stats.technique)
		_set_stat_value("mental", stats.mental)
		_set_stat_value("flexibility", stats.flexibility)
		_set_stat_value("intellect", stats.intellect)
	
	# 適性情報
	if horse_data.has("aptitude"):
		var aptitude_text = "得意カテゴリ: "
		for i in range(horse_data.aptitude.size()):
			if i > 0:
				aptitude_text += "、"
			aptitude_text += horse_data.aptitude[i]
		aptitude_label.text = aptitude_text

# ステータス値を設定
func _set_stat_value(stat_name: String, value: int) -> void:
	var value_label = stats_grid.get_node(stat_name.capitalize() + "Value")
	if value_label:
		value_label.text = str(value)

# 選択ボタン押下時
func _on_select_button_pressed() -> void:
	if selected_horse_id.is_empty():
		return
	
	print("選択された馬: " + selected_horse_id)
	
	# GameManagerに選択された馬を設定
	var data_loader = DataLoader.get_instance()
	var game_manager = GameManager.get_instance()
	
	if data_loader and game_manager:
		var horse = data_loader.get_horse(selected_horse_id)
		game_manager.current_horse = horse
		
		# 装備選択画面へ遷移
		get_tree().change_scene_to_file("res://scenes/screens/equipment_select_screen.tscn")
	else:
		print("エラー: GameManagerまたはDataLoaderが見つかりません")

# 戻るボタン押下時
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/title_screen.tscn") 