extends Control

# UI要素の参照 - 上部パネル
@onready var month_label = $MarginContainer/MainLayout/TopPanel/TopBarContainer/MonthLabel
@onready var turn_label = $MarginContainer/MainLayout/TopPanel/TopBarContainer/TurnLabel
@onready var chakra_category_label = $MarginContainer/MainLayout/TopPanel/TopBarContainer/ChakraFlowContainer/CategoryLabel

# ステータス関連
@onready var stat_grid_container = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/StatGridContainer
@onready var fatigue_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/FatigueContainer/FatigueLabel
@onready var fatigue_bar = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/FatigueContainer/FatigueBar
@onready var success_rate_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/FatigueContainer/SuccessRateLabel

# 熟度関連
@onready var rider_familiarity_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/RiderFamiliarityContainer/Label
@onready var rider_familiarity_bar = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/RiderFamiliarityContainer/ProgressBar
@onready var horse_familiarity_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/HorseFamiliarityContainer/Label
@onready var horse_familiarity_bar = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/HorseFamiliarityContainer/ProgressBar
@onready var manual_familiarity_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/ManualFamiliarityContainer/Label
@onready var manual_familiarity_bar = $MarginContainer/MainLayout/ContentContainer/LeftPanel/StatsScrollContainer/StatsContainer/ManualFamiliarityContainer/ProgressBar

# トレーニングカード関連
@onready var training_items_container = $MarginContainer/MainLayout/ContentContainer/CenterPanel/TrainingScrollContainer/TrainingContainer/TrainingItemsContainer
@onready var training_card_template = $MarginContainer/MainLayout/ContentContainer/CenterPanel/TrainingScrollContainer/TrainingContainer/TrainingItemsContainer/TrainingCardTemplate

# 詳細表示
@onready var detail_name_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/NameContainer/NameLabel
@onready var detail_category_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/NameContainer/CategoryLabel
@onready var detail_main_stat_effect = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/EffectsContainer/MainStatEffect
@onready var detail_sub_stat_effect = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/EffectsContainer/SubStatEffect
@onready var detail_fatigue_effect = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/EffectsContainer/FatigueEffect
@onready var detail_resonance_status = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/ResonanceContainer/ResonanceStatusLabel
@onready var detail_resonance_chance = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/ResonanceContainer/ResonanceChanceLabel
@onready var detail_familiarity_effect = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/FamiliarityContainer/FamiliarityEffectLabel
@onready var detail_familiarity_reason = $MarginContainer/MainLayout/ContentContainer/RightPanel/TrainingDetailContainer/SelectedTrainingDetailsPanel/MarginContainer/VBoxContainer/FamiliarityContainer/FamiliarityReasonLabel

# ボタン類
@onready var train_button = $MarginContainer/MainLayout/BottomButtonsContainer/TrainButton
@onready var rest_button = $MarginContainer/MainLayout/BottomButtonsContainer/RestButton
@onready var race_button = $MarginContainer/MainLayout/BottomButtonsContainer/RaceButton
@onready var log_button = $MarginContainer/MainLayout/BottomButtonsContainer/LogButton

# 状態管理
var current_horse = null  # 現在の馬
var current_equipment = {}  # 現在の装備（騎手/装備/指南書）
var training_options = []  # 今月のトレーニング選択肢
var selected_training = null  # 選択中のトレーニング
var selected_training_card = null  # 選択中のカードUI要素
var current_month = 0  # 現在の月（0から始まる）
var current_age = 3  # 現在の年齢
var current_fatigue = 0  # 現在の疲労度
var chakra_category = "速力"  # 今月のチャクラ気配

func _ready():
	# テンプレートを非表示に
	training_card_template.visible = false
	
	# ボタンのシグナル接続
	train_button.pressed.connect(_on_train_button_pressed)
	rest_button.pressed.connect(_on_rest_button_pressed)
	race_button.pressed.connect(_on_race_button_pressed)
	log_button.pressed.connect(_on_log_button_pressed)
	
	# ボタンのフォントサイズ設定
	train_button.add_theme_font_size_override("font_size", 24)
	rest_button.add_theme_font_size_override("font_size", 24)
	race_button.add_theme_font_size_override("font_size", 24)
	log_button.add_theme_font_size_override("font_size", 24)
	
	# ゲームマネージャからデータ取得
	var game_manager = GameManager.get_instance()
	if game_manager:
		_load_game_state(game_manager)
	else:
		# デバッグモード: ダミーデータでテスト表示
		_load_debug_data()
	
	# 初期表示更新
	_update_ui()
	
	# トレーニング選択肢を生成
	_generate_training_options()
	
	# トレーニング実行ボタンの更新
	_update_train_button_state()

# ゲーム状態の読み込み
func _load_game_state(game_manager: Node) -> void:
	print("DEBUG: _load_game_state 開始")
	
	# game_managerが実際にGameManagerオブジェクトであることを確認
	print("DEBUG: game_managerの型: " + str(typeof(game_manager)))
	
	if game_manager.has_method("get_current_fatigue"):
		current_horse = game_manager.current_horse
		current_equipment = game_manager.current_equipment
		current_month = game_manager.current_month
		current_age = game_manager.current_age
		current_fatigue = game_manager.get_current_fatigue()
		
		# 馬のデータが正しく読み込まれたか確認
		if current_horse:
			print("DEBUG: 現在の馬のステータス: " + str(current_horse.current_stats.to_dict()))
		else:
			print("DEBUG: 警告: 馬データがnullです")
		
		# チャクラ気配を直接GameManagerから取得
		if game_manager.chakra_flow_category != "":
			chakra_category = game_manager.chakra_flow_category
		else:
			# デバッグ用: チャクラ気配が設定されていない場合はランダムに設定
			chakra_category = _get_random_chakra_category()
		
		print("DEBUG: _load_game_state 完了: 月=" + str(current_month) + ", 疲労=" + str(current_fatigue))
	else:
		print("DEBUG: 警告: game_managerが適切なオブジェクトではありません")
	
	print("DEBUG: _load_game_state 完了")

# デバッグ用データの読み込み
func _load_debug_data() -> void:
	current_month = 0
	current_age = 3
	current_fatigue = 25
	chakra_category = "速力"

# UI全体の更新
func _update_ui() -> void:
	print("DEBUG: _update_ui 呼び出し")
	print("DEBUG: 現在の馬のステータス: " + str(current_horse.current_stats.to_dict() if current_horse and current_horse.current_stats else "なし"))
	
	_update_month_display()
	_update_stats_display()
	_update_fatigue_display()
	_update_familiarity_display()
	_update_resonance_display()
	_update_race_button_state()  # レースボタンの状態も明示的に更新
	
	print("DEBUG: 現在の月: " + str(current_month) + " レースボタン状態: " + str(!race_button.disabled))
	print("DEBUG: _update_ui 完了")

# 月表示の更新
func _update_month_display() -> void:
	# 現在の月から表示する月を計算（4月から開始）
	var month_number = (current_month % 12) + 4
	if month_number > 12:
		month_number -= 12
	
	# 年齢と月を表示（フォントサイズを36ptに）
	var age_text = str(current_age) + "歳" + str(month_number) + "月"
	month_label.text = age_text
	month_label.add_theme_font_size_override("font_size", 36)
	
	# ターン残数の表示（33ヶ月育成の場合、フォントサイズを24ptに）
	var remaining_turns = 33 - current_month
	var turn_text = "残り" + str(remaining_turns) + "ターン"
	turn_label.text = turn_text
	turn_label.add_theme_font_size_override("font_size", 24)
	
	# デバッグログ
	print("月表示更新: " + age_text + ", " + turn_text)
	
	# チャクラ気配の表示（色付け、フォントサイズを24ptに）
	chakra_category_label.text = chakra_category
	chakra_category_label.add_theme_font_size_override("font_size", 24)
	
	# チャクラ気配の色を設定
	match chakra_category:
		"速力":
			chakra_category_label.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))
		"柔軟":
			chakra_category_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.6))
		"精神":
			chakra_category_label.add_theme_color_override("font_color", Color(0.8, 0.4, 1.0))
		"技術":
			chakra_category_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		"展開":
			chakra_category_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
		"持久":
			chakra_category_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.2))

# ステータス表示の更新
func _update_stats_display() -> void:
	print("DEBUG: _update_stats_display 開始")
	
	if current_horse and current_horse.current_stats:
		# 実際の馬のステータスを表示
		var stats = current_horse.current_stats
		print("DEBUG: 更新に使用するステータス: " + str(stats.to_dict()))
		print("DEBUG: 直接参照: speed=" + str(stats.speed) + ", technique=" + str(stats.technique))
		
		# 存在するグリッドノードの確認
		print("DEBUG: ステータスグリッドの子ノード:")
		for child in stat_grid_container.get_children():
			print("DEBUG:  - " + child.name)
		
		# 必須ステータスのマッピング（日本語表示名とプロパティ名）
		var stat_mappings = {
			"Speed": {"property": "speed", "jp_name": "速力"},
			"Stamina": {"property": "stamina", "jp_name": "持久力"}, 
			"Technique": {"property": "technique", "jp_name": "技術"},
			"Intellect": {"property": "intellect", "jp_name": "展開力"},
			"Flexibility": {"property": "flexibility", "jp_name": "柔軟性"},
			"Mental": {"property": "mental", "jp_name": "精神力"}
		}
		
		# 存在するステータスのみ更新
		for grid_name in stat_mappings:
			var stat_info = stat_mappings[grid_name]
			var stat_property = stat_info.property
			
			if stat_grid_container.has_node(grid_name + "/Value"):
				var value_node = stat_grid_container.get_node(grid_name + "/Value")
				var progress_bar = stat_grid_container.get_node(grid_name + "/ProgressBar")
				var label_node = stat_grid_container.get_node(grid_name + "/Label")
				
				# プロパティ名に基づいて直接値を取得
				var stat_value = 0
				match stat_property:
					"speed": stat_value = stats.speed
					"stamina": stat_value = stats.stamina
					"technique": stat_value = stats.technique
					"intellect": stat_value = stats.intellect
					"flexibility": stat_value = stats.flexibility
					"mental": stat_value = stats.mental
					_: 
						# 直接アクセスできない場合はget_statを使う
						if stats.has_method("get_stat"):
							stat_value = stats.get_stat(stat_property)
				
				var old_value = value_node.text.to_int() if value_node.text else 0
				
				print("DEBUG: " + grid_name + " 更新: " + str(old_value) + " → " + str(stat_value) + " (プロパティ: " + stat_property + ")")
				
				# 値の更新
				value_node.text = str(stat_value)
				progress_bar.value = stat_value
				
				# 日本語表示名を設定
				label_node.text = stat_info.jp_name
				
				# デバッグ: 値の変更を確認
				if old_value != stat_value:
					print("DEBUG: ステータス更新: " + grid_name + " " + str(old_value) + " → " + str(stat_value))
				
				# フォントサイズ設定
				value_node.add_theme_font_size_override("font_size", 24)
				label_node.add_theme_font_size_override("font_size", 24)
			else:
				print("DEBUG: 警告: " + grid_name + " ノードが見つかりません。このステータスは表示されません。")
		
		# デバッグ出力
		print("DEBUG: 馬のステータス更新完了: 速力=" + str(stats.speed) + ", 持久力=" + str(stats.stamina) + 
			  ", 技術=" + str(stats.technique) + ", 展開力=" + str(stats.intellect) + 
			  ", 柔軟性=" + str(stats.flexibility) + ", 精神力=" + str(stats.mental))
	else:
		print("DEBUG: 現在の馬データがありません")
		# ダミーデータの場合は何もしない
		pass
	
	print("DEBUG: _update_stats_display 完了")

# 疲労表示の更新
func _update_fatigue_display() -> void:
	# 疲労値の表示
	fatigue_label.text = "疲労度: " + str(current_fatigue)
	fatigue_label.add_theme_font_size_override("font_size", 24)
	fatigue_bar.value = current_fatigue
	
	# 疲労に応じた色とバーの色を設定
	if current_fatigue < 60:
		fatigue_bar.add_theme_color_override("fill_color", Color(0.2, 0.7, 0.9))
		success_rate_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		success_rate_label.text = "成功率: 100%"
	elif current_fatigue < 80:
		fatigue_bar.add_theme_color_override("fill_color", Color(0.9, 0.7, 0.2))
		success_rate_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
		success_rate_label.text = "成功率: 70%"
	else:
		fatigue_bar.add_theme_color_override("fill_color", Color(0.9, 0.2, 0.2))
		success_rate_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
		success_rate_label.text = "成功率: 30%"
	
	# 成功率ラベルのフォントサイズ設定
	success_rate_label.add_theme_font_size_override("font_size", 24)

# 熟度表示の更新
func _update_familiarity_display() -> void:
	if current_equipment.has("rider"):
		var familiarity = current_equipment.rider.familiarity
		var level = current_equipment.rider.get_familiarity_level_text()
		rider_familiarity_label.text = "騎手: " + level
		rider_familiarity_label.add_theme_font_size_override("font_size", 24)
		rider_familiarity_bar.value = familiarity
	
	if current_equipment.has("horse"):
		var familiarity = current_equipment.horse.familiarity
		var level = current_equipment.horse.get_familiarity_level_text()
		horse_familiarity_label.text = "装備: " + level
		horse_familiarity_label.add_theme_font_size_override("font_size", 24)
		horse_familiarity_bar.value = familiarity
	
	if current_equipment.has("manual"):
		var familiarity = current_equipment.manual.familiarity
		var level = current_equipment.manual.get_familiarity_level_text()
		manual_familiarity_label.text = "指南書: " + level
		manual_familiarity_label.add_theme_font_size_override("font_size", 24)
		manual_familiarity_bar.value = familiarity

# 共鳴状態の更新
func _update_resonance_display() -> void:
	if selected_training:
		var is_chakra_match = selected_training.category == chakra_category
		var equipment_match = _check_equipment_category_match(selected_training.category)
		
		# チャクラ気配一致の表示
		if is_chakra_match:
			detail_resonance_status.text = "チャクラ気配と一致"
			detail_resonance_status.add_theme_color_override("font_color", Color(0.4, 0.6, 0.9))
		else:
			detail_resonance_status.text = "チャクラ気配と不一致"
			detail_resonance_status.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		
		detail_resonance_status.add_theme_font_size_override("font_size", 24)
		
		# 装備一致の表示
		if equipment_match:
			detail_familiarity_effect.text = "装備熟度: +10pt"
			detail_familiarity_reason.text = "（カテゴリ一致ボーナス）"
		else:
			detail_familiarity_effect.text = "装備熟度: +2pt"
			detail_familiarity_reason.text = "（通常加算）"
		
		detail_familiarity_effect.add_theme_font_size_override("font_size", 24)
		detail_familiarity_reason.add_theme_font_size_override("font_size", 20)
		
		# 共鳴確率の表示
		if is_chakra_match and equipment_match:
			detail_resonance_chance.text = "共鳴率: 40%"
		else:
			detail_resonance_chance.text = "共鳴条件を満たしていません"
		
		detail_resonance_chance.add_theme_font_size_override("font_size", 24)

# 装備カテゴリ一致チェック
func _check_equipment_category_match(training_category: String) -> bool:
	if not current_equipment:
		return false
	
	# 装備のカテゴリに基づいてチェック
	for equip_type in ["rider", "horse", "manual"]:
		if current_equipment.has(equip_type):
			var equipment = current_equipment[equip_type]
			if equipment.related_training == _get_english_category_name(training_category):
				return true
	
	return false

# 日本語カテゴリ名から英語名への変換
func _get_english_category_name(jp_category: String) -> String:
	match jp_category:
		"速力": return "speed"
		"柔軟": return "flexibility"
		"精神": return "mental"
		"技術": return "technique" 
		"展開": return "intellect"
		"持久": return "stamina"
	return jp_category  # カテゴリが不明な場合は元の値を返す

# トレーニング選択肢の生成
func _generate_training_options() -> void:
	# 既存のカードをクリア（テンプレート以外）
	for child in training_items_container.get_children():
		if child != training_card_template:
			child.queue_free()
	
	# GameManagerからトレーニング選択肢を取得または生成
	var game_manager = GameManager.get_instance()
	if game_manager:
		# ゲームマネージャから現在月のチャクラ気配カテゴリを取得
		chakra_category = game_manager.chakra_flow_category
		
		# ゲームマネージャのデータを使用してトレーニング選択肢を生成
		# （ここではまだ実装されていないので、同じデバッグデータを使用）
		training_options = _generate_debug_training_options()
	else:
		# デバッグ用にダミーデータを生成
		training_options = _generate_debug_training_options()
	
	# 各トレーニングのカードを作成
	for training in training_options:
		_add_training_card(training)

# デバッグ用トレーニング選択肢生成
func _generate_debug_training_options() -> Array:
	var options = []
	var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
	
	for category in categories:
		var training = {
			"id": "training_" + category + "_debug",
			"name": _get_random_training_name(category),
			"category": category,
			"main_stat": _get_main_stat_for_category(category),
			"sub_stat": _get_sub_stat_for_category(category),
			"main_value": _get_main_value_for_category(category),
			"sub_value": _get_sub_value_for_category(category),
			"fatigue_increase": _get_fatigue_for_category(category),
			"description": "【" + category + "】系トレーニング"
		}
		options.append(training)
	
	return options

# カテゴリ別のランダムトレーニング名
func _get_random_training_name(category: String) -> String:
	var names = []
	
	match category:
		"速力":
			names = ["風走法", "疾光修練", "瞬勢鍛錬", "流星走法", "無影走術"]
		"柔軟":
			names = ["柔体錬成", "しなやか調律", "四肢調和術", "柔軸形成", "転身調整"]
		"精神":
			names = ["静心修行", "精神統一", "内観瞑想", "集中気法", "心意練磨"]
		"技術":
			names = ["型稽古", "技術研鑽", "動作熟達", "精緻動作練習", "術理体得"]
		"展開":
			names = ["局面読解", "先読修練", "展開鑑識", "形勢察知", "戦術思考"]
		"持久":
			names = ["持久鍛練", "忍耐走法", "体力増進", "長息修行", "体幹調整"]
	
	return names[randi() % names.size()]

# カテゴリ別のメインステータス
func _get_main_stat_for_category(category: String) -> String:
	match category:
		"速力": return "速力"
		"柔軟": return "柔軟性"
		"精神": return "精神"
		"技術": return "技術"
		"展開": return "展開力"
		"持久": return "持久力"
	return "速力"

# カテゴリ別のサブステータス
func _get_sub_stat_for_category(category: String) -> String:
	match category:
		"速力": return "反応"
		"柔軟": return "姿勢"
		"精神": return "集中力"
		"技術": return "対応力"
		"展開": return "判断力"
		"持久": return "体力"
	return "反応"

# カテゴリ別のメイン成長値
func _get_main_value_for_category(category: String) -> int:
	match category:
		"速力", "柔軟", "持久": return 6
		"技術", "展開": return 5
		"精神": return 4
	return 5

# カテゴリ別のサブ成長値
func _get_sub_value_for_category(category: String) -> int:
	match category:
		"精神": return 3
		"速力", "柔軟", "展開", "持久": return 2
		"技術": return 1
	return 2

# カテゴリ別の疲労値
func _get_fatigue_for_category(category: String) -> int:
	match category:
		"速力", "持久": return 30
		"技術", "展開": return 25
		"柔軟": return 20
		"精神": return 10
	return 20

# ランダムなチャクラ気配取得（デバッグ用）
func _get_random_chakra_category() -> String:
	var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
	return categories[randi() % categories.size()]

# トレーニングカードの追加
func _add_training_card(training: Dictionary) -> void:
	# テンプレートの複製
	var card = training_card_template.duplicate()
	card.visible = true
	training_items_container.add_child(card)
	
	# カード情報の設定
	var name_label = card.get_node("MarginContainer/VBoxContainer/HeaderContainer/NameLabel")
	var category_label = card.get_node("MarginContainer/VBoxContainer/HeaderContainer/CategoryLabel")
	var main_stat_label = card.get_node("MarginContainer/VBoxContainer/StatsContainer/MainStatLabel")
	var sub_stat_label = card.get_node("MarginContainer/VBoxContainer/StatsContainer/SubStatLabel")
	var fatigue_label = card.get_node("MarginContainer/VBoxContainer/FatigueContainer/FatigueLabel")
	var resonance_label = card.get_node("MarginContainer/VBoxContainer/ResonanceContainer/ResonanceLabel")
	var selected_indicator = card.get_node("SelectedIndicator")
	
	# 各ラベルの設定
	name_label.text = training.name
	name_label.add_theme_font_size_override("font_size", 24)
	
	category_label.text = "【" + training.category + "】"
	category_label.add_theme_font_size_override("font_size", 20)
	
	# ステータス表示
	var main_value = training.main_value if "main_value" in training else _get_main_value_for_category(training.category)
	var sub_value = training.sub_value if "sub_value" in training else _get_sub_value_for_category(training.category)
	main_stat_label.text = training.main_stat + " +" + str(main_value)
	main_stat_label.add_theme_font_size_override("font_size", 20)
	
	sub_stat_label.text = training.sub_stat + " +" + str(sub_value)
	sub_stat_label.add_theme_font_size_override("font_size", 20)
	
	# 疲労表示
	fatigue_label.text = "疲労 +" + str(training.fatigue_increase)
	fatigue_label.add_theme_font_size_override("font_size", 20)
	
	# 共鳴候補表示
	if training.category == chakra_category:
		resonance_label.text = "共鳴候補"
		resonance_label.visible = true
	else:
		resonance_label.visible = false
	
	resonance_label.add_theme_font_size_override("font_size", 20)
	
	# 選択状態の初期化
	selected_indicator.visible = false
	
	# クリックイベント追加
	card.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_training_card_selected(training, card)
	)

# トレーニングカード選択時の処理
func _on_training_card_selected(training: Dictionary, card: Node) -> void:
	# 以前の選択を解除
	if selected_training_card and is_instance_valid(selected_training_card):
		selected_training_card.get_node("SelectedIndicator").visible = false
	
	# 新しい選択を設定
	selected_training = training
	selected_training_card = card
	card.get_node("SelectedIndicator").visible = true
	
	# 詳細情報の更新
	_update_training_details(training)
	
	# トレーニングボタンを有効化
	_update_train_button_state()

# トレーニング詳細情報の更新
func _update_training_details(training: Dictionary) -> void:
	# 詳細パネルの情報更新
	detail_name_label.text = training.name
	detail_name_label.add_theme_font_size_override("font_size", 30)
	
	detail_category_label.text = "【" + training.category + "】"
	detail_category_label.add_theme_font_size_override("font_size", 24)
	
	# ステータス効果
	var main_value = training.main_value if "main_value" in training else _get_main_value_for_category(training.category)
	var sub_value = training.sub_value if "sub_value" in training else _get_sub_value_for_category(training.category)
	
	detail_main_stat_effect.text = training.main_stat + ": +" + str(main_value)
	detail_main_stat_effect.add_theme_font_size_override("font_size", 24)
	
	detail_sub_stat_effect.text = training.sub_stat + ": +" + str(sub_value)
	detail_sub_stat_effect.add_theme_font_size_override("font_size", 24)
	
	detail_fatigue_effect.text = "疲労: +" + str(training.fatigue_increase)
	detail_fatigue_effect.add_theme_font_size_override("font_size", 24)
	
	# 共鳴状態の更新
	_update_resonance_display()

# トレーニング実行ボタンの状態更新
func _update_train_button_state() -> void:
	train_button.disabled = (selected_training == null)

# レース出走ボタンの状態更新
func _update_race_button_state() -> void:
	print("DEBUG: _update_race_button_state 呼び出し - 現在の月: " + str(current_month))
	var game_manager = GameManager.get_instance()
	
	# 現在の月が8以上ならボタンを有効化（最小限の条件）
	if current_month >= 8:
		race_button.disabled = false
		print("DEBUG: current_month >= 8 条件による有効化: " + str(current_month))
	elif game_manager and game_manager.get_training_state():
		var result = game_manager.get_training_state().check_race_availability(current_month)
		race_button.disabled = not result
		print("DEBUG: TrainingState判定結果: " + str(result))
	else:
		# デバッグ: 8ヶ月目以降はレース出走可能
		race_button.disabled = current_month < 8
		print("DEBUG: デフォルト判定: " + str(!race_button.disabled))
		
	print("DEBUG: 更新後のレースボタン状態: " + str(!race_button.disabled) + " (disabled=" + str(race_button.disabled) + ")")

# トレーニング実行ボタン押下時
func _on_train_button_pressed() -> void:
	if not selected_training:
		return
	
	print("DEBUG: ========== トレーニング実行開始 ==========")
	
	var game_manager = GameManager.get_instance()
	if game_manager:
		print("DEBUG: GameManager取得成功")
		print("トレーニング実行前: 月=" + str(current_month) + ", 残りターン=" + str(33 - current_month))
		
		# 現在のステータスを記録
		var before_stats = {}
		if current_horse and current_horse.current_stats:
			before_stats = current_horse.current_stats.to_dict()
			print("トレーニング前のステータス: " + str(before_stats))
		
		# 現在の疲労値を記録
		var before_fatigue = current_fatigue
		print("トレーニング前の疲労値: " + str(before_fatigue))
		
		# 選択したトレーニングのカテゴリを取得（日本語のまま）
		var category_jp = selected_training.category
		
		print("選択したトレーニング: " + selected_training.name + " (カテゴリ: " + category_jp + ")")
		
		# ゲームマネージャ経由でトレーニング実行
		print("トレーニング実行: カテゴリ=" + category_jp)
		var result = game_manager.execute_training(category_jp)
		print("トレーニング結果: " + str(result))
		
		# トレーニング結果を詳細に表示
		if result.has("stats_gains"):
			print("ステータス増加: " + str(result.stats_gains))
			for stat_name in result.stats_gains:
				var gain = result.stats_gains[stat_name]
				if before_stats.has(stat_name):
					var new_value = before_stats[stat_name] + gain
					print("  " + stat_name + ": " + str(before_stats[stat_name]) + " → " + str(new_value) + " (+" + str(gain) + ")")
		
		if result.has("log_messages"):
			print("ログメッセージ:")
			for msg in result.log_messages:
				print("  " + msg)
		
		# 月を進める
		print("月を進める前のcurrent_month: " + str(game_manager.current_month))
		game_manager.advance_month()
		print("月を進めた後のcurrent_month: " + str(game_manager.current_month))
		
		# 画面更新のため再度ゲーム状態をロード
		print("DEBUG: ロード前のHorse: " + str(current_horse.current_stats.to_dict() if current_horse and current_horse.current_stats else "なし"))
		_load_game_state(game_manager)
		print("DEBUG: ロード後のHorse: " + str(current_horse.current_stats.to_dict() if current_horse and current_horse.current_stats else "なし"))
		print("ゲーム状態ロード後: 月=" + str(current_month) + ", 残りターン=" + str(33 - current_month))
		
		# ステータス変化の確認
		if current_horse:
			var after_stats = current_horse.current_stats.to_dict()
			print("トレーニング後のステータス: " + str(after_stats))
			
			# 変化の表示
			print("ステータス変化:")
			for stat_name in after_stats:
				if before_stats.has(stat_name):
					var diff = after_stats[stat_name] - before_stats[stat_name]
					if diff != 0:
						print("  " + stat_name + ": " + str(before_stats[stat_name]) + " → " + str(after_stats[stat_name]) + " (" + (("+" + str(diff)) if diff > 0 else str(diff)) + ")")
					else:
						print("  " + stat_name + ": 変化なし (" + str(after_stats[stat_name]) + ")")
		
		# 疲労値が更新されているか確認
		print("トレーニング後の疲労値: " + str(current_fatigue) + " (変化: " + (("+" + str(current_fatigue - before_fatigue)) if current_fatigue > before_fatigue else str(current_fatigue - before_fatigue)) + ")")
		
		# UI強制更新（1回目）
		print("DEBUG: 1回目のUI更新開始")
		_update_ui()
		print("DEBUG: UI更新完了（1回目）")
		
		# トレーニング選択肢を再生成
		_generate_training_options()
		
		# 選択状態をリセット
		selected_training = null
		selected_training_card = null
		train_button.disabled = true
		
		# 一フレーム待ってからUI再更新（遅延更新 - 2回目）
		print("DEBUG: 1フレーム待機")
		await get_tree().process_frame
		
		# 2回目のゲーム状態ロード（最新の状態を確実に取得）
		print("DEBUG: 2回目のゲーム状態ロード前のHorse: " + str(current_horse.current_stats.to_dict() if current_horse and current_horse.current_stats else "なし"))
		_load_game_state(game_manager)
		print("DEBUG: 2回目のゲーム状態ロード後のHorse: " + str(current_horse.current_stats.to_dict() if current_horse and current_horse.current_stats else "なし"))
		print("2回目のゲーム状態ロード後: 月=" + str(current_month))
		
		# 2回目のUI更新
		print("DEBUG: 2回目のUI更新開始")
		_update_ui()
		_update_month_display()
		print("DEBUG: UI更新完了（2回目）: " + month_label.text + ", 残り" + str(33 - current_month) + "ターン")
	else:
		print("DEBUG: GameManagerの取得に失敗")
		# デバッグモード: 
		print("トレーニング実行: " + selected_training.name)
		_proceed_to_next_month()
	
	print("DEBUG: ========== トレーニング実行完了 ==========")

# 休養ボタン押下時
func _on_rest_button_pressed() -> void:
	var game_manager = GameManager.get_instance()
	if game_manager:
		print("休養実行前: 月=" + str(current_month) + ", 残りターン=" + str(33 - current_month))
		print("休養実行前の疲労値: " + str(current_fatigue))
		
		# ゲームマネージャ経由で休養処理
		var result = game_manager.execute_rest()
		print("休養結果: " + str(result))
		
		# 月を進める
		print("月を進める前のcurrent_month: " + str(game_manager.current_month))
		game_manager.advance_month()
		print("月を進めた後のcurrent_month: " + str(game_manager.current_month))
		
		# 画面更新のため再度ゲーム状態をロード
		_load_game_state(game_manager)
		print("ゲーム状態ロード後: 月=" + str(current_month) + ", 残りターン=" + str(33 - current_month))
		print("休養実行後の疲労値: " + str(current_fatigue))
		
		# UI強制更新（1回目）
		_update_ui()
		print("UI更新完了（1回目）")
		
		# トレーニング選択肢を再生成
		_generate_training_options()
		
		# 選択状態をリセット
		selected_training = null
		selected_training_card = null
		train_button.disabled = true
		
		# 一フレーム待ってからUI再更新（遅延更新 - 2回目）
		await get_tree().process_frame
		
		# 2回目のゲーム状態ロード（最新の状態を確実に取得）
		_load_game_state(game_manager)
		print("2回目のゲーム状態ロード後: 月=" + str(current_month))
		
		# 2回目のUI更新
		_update_ui()
		_update_month_display()
		print("UI更新完了（2回目）: " + month_label.text + ", 残り" + str(33 - current_month) + "ターン")
	else:
		# デバッグモード
		print("休養実行: 疲労-50")
		current_fatigue = max(0, current_fatigue - 50)
		_proceed_to_next_month()

# レースボタン押下時
func _on_race_button_pressed() -> void:
	var game_manager = GameManager.get_instance()
	if game_manager:
		# レース画面に遷移
		get_tree().change_scene_to_file("res://scenes/screens/race_screen.tscn")
	else:
		# デバッグモード
		print("レース画面へ遷移")
		get_tree().change_scene_to_file("res://scenes/screens/race_screen.tscn")

# ログボタン押下時
func _on_log_button_pressed() -> void:
	var game_manager = GameManager.get_instance()
	if game_manager:
		# ログ画面表示処理
		print("ログ表示（未実装）")
	else:
		# デバッグモード
		print("ログ表示（未実装）")

# 次の月に進む処理
func _proceed_to_next_month() -> void:
	print("次の月に進む: 現在月=" + str(current_month))
	
	# 月を進める
	current_month += 1
	
	# 年齢の更新（12ヶ月ごと）
	if current_month > 0 and current_month % 12 == 0:
		current_age += 1
		print("年齢更新: " + str(current_age) + "歳")
	
	# チャクラ気配をランダムに更新
	chakra_category = _get_random_chakra_category()
	print("新しいチャクラ気配: " + chakra_category)
	
	# 各種UI更新
	_update_ui()
	print("UI更新完了")
	
	# トレーニング選択肢を再生成
	_generate_training_options()
	
	# 選択状態をリセット
	selected_training = null
	selected_training_card = null
	train_button.disabled = true
	
	# レースボタンの状態更新
	_update_race_button_state()
	
	# 月表示を強制的に再更新
	await get_tree().process_frame
	_update_month_display()
	print("月表示再更新: " + month_label.text)
	
