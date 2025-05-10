extends Control

# UI要素 - 育成馬情報
@onready var horse_name_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/HorseNameLabel
@onready var speed_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/StatGridContainer/SpeedValue
@onready var flexibility_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/StatGridContainer/FlexibilityValue
@onready var mental_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/StatGridContainer/MentalValue
@onready var technique_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/StatGridContainer/TechniqueValue
@onready var intellect_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/StatGridContainer/IntellectValue
@onready var stamina_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorsePanel/VBoxContainer/StatGridContainer/StaminaValue

# UI要素 - 評価
@onready var rank_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/RankPanel/VBoxContainer/RankLabel
@onready var score_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/RankPanel/VBoxContainer/ScoreLabel

# UI要素 - スキル
@onready var skills_list = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/SkillsPanel/VBoxContainer/SkillsScrollContainer/SkillsList
@onready var skill_item_template = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/SkillsPanel/VBoxContainer/SkillsScrollContainer/SkillsList/SkillItemTemplate

# UI要素 - レース
@onready var races_grid = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer
@onready var race1_date_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race1DateLabel
@onready var race1_position_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race1PositionLabel
@onready var race1_score_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race1ScoreLabel
@onready var race2_date_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race2DateLabel
@onready var race2_position_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race2PositionLabel
@onready var race2_score_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race2ScoreLabel
@onready var race3_date_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race3DateLabel
@onready var race3_position_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race3PositionLabel
@onready var race3_score_label = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/RacesPanel/VBoxContainer/RacesGridContainer/Race3ScoreLabel

# ボタン
@onready var return_to_title_button = $MarginContainer/MainLayout/BottomButtonsContainer/ReturnToTitleButton
@onready var save_record_button = $MarginContainer/MainLayout/BottomButtonsContainer/SaveRecordButton

# 初期化
func _ready():
	# テンプレートを非表示に
	skill_item_template.visible = false
	
	# ボタンのシグナル接続
	return_to_title_button.pressed.connect(_on_return_to_title_button_pressed)
	save_record_button.pressed.connect(_on_save_record_button_pressed)
	
	# ゲームマネージャからデータ取得
	var game_manager = GameManager.get_instance()
	if game_manager:
		_load_result_data(game_manager)
	else:
		# デバッグモード: ダミーデータでテスト表示
		_load_debug_data()
	
	# UI更新
	_update_ui()

# ゲームマネージャからの育成結果データの読み込み
func _load_result_data(game_manager) -> void:
	# 計算済みの育成結果データを取得（calculate_training_resultの結果）
	var training_result = null
	if game_manager.has_meta("training_result"):
		training_result = game_manager.get_meta("training_result")
		print("DEBUG: GameManagerから計算済み育成結果を取得しました")
	
	# 馬のデータを取得
	var horse = game_manager.current_horse
	if horse:
		# 馬名
		horse_name_label.text = horse.name
		
		# ステータス
		if horse.current_stats:
			var stats = horse.current_stats
			speed_value.text = str(stats.speed)
			flexibility_value.text = str(stats.flexibility)
			mental_value.text = str(stats.mental)
			technique_value.text = str(stats.technique)
			intellect_value.text = str(stats.intellect)
			stamina_value.text = str(stats.stamina)
	
	# スキルデータを取得
	var unlocked_skills = game_manager.unlocked_skills
	if unlocked_skills:
		for i in range(unlocked_skills.size()):
			var skill = unlocked_skills[i]
			_add_skill_item(skill)
	
	# レース結果データを取得
	var race_records = game_manager.race_records
	if race_records:
		_display_race_records(race_records)
	
	# 総合スコアと評価を表示
	var total_score = 0
	var rank = "C"
	
	# 計算済み結果がある場合はそれを使用
	if training_result:
		total_score = training_result.total_score
		rank = training_result.rank
		print("DEBUG: 計算済み育成結果を使用: スコア=" + str(total_score) + ", ランク=" + rank)
	else:
		# ない場合は自分で計算
		total_score = _calculate_total_score(horse, unlocked_skills, race_records)
		rank = _determine_rank(total_score)
		print("DEBUG: 育成結果を再計算: スコア=" + str(total_score) + ", ランク=" + rank)
	
	# スコアと評価を表示
	score_label.text = "スコア: " + str(total_score)
	rank_label.text = rank
	
	# ランクに応じた色設定
	match rank:
		"S":
			rank_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))  # 金色
		"A":
			rank_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.1))  # 金色に近い
		"B":
			rank_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))  # 銀色
		"C":
			rank_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))  # 銅色
		_:
			rank_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))  # グレー

# レース記録の表示
func _display_race_records(race_records: Array) -> void:
	# レース日付（月齢）のマッピング
	var race_dates = ["3歳12月", "4歳12月", "5歳12月"]
	
	for i in range(min(race_records.size(), 3)):
		var race = race_records[i]
		
		# レース結果の表示
		match i:
			0:  # 最初のレース
				race1_date_label.text = race_dates[0]
				race1_position_label.text = str(race.position) + "着"
				race1_score_label.text = str(race.score)
			1:  # 2回目のレース
				race2_date_label.text = race_dates[1]
				race2_position_label.text = str(race.position) + "着"
				race2_score_label.text = str(race.score)
			2:  # 3回目のレース
				race3_date_label.text = race_dates[2]
				race3_position_label.text = str(race.position) + "着"
				race3_score_label.text = str(race.score)

# デバッグ用のダミーデータ読み込み
func _load_debug_data() -> void:
	# ダミーのスキルデータをいくつか追加
	var skill_names = ["無音疾風", "静心制圧", "柔式転身", "心身統合"]
	var skill_categories = ["速力系", "精神系", "柔軟系", "持久系"]
	
	for i in range(skill_names.size()):
		var dummy_skill = {
			"name": skill_names[i],
			"category": skill_categories[i]
		}
		_add_skill_item(dummy_skill)
	
	# ダミーのレース結果を表示
	var dummy_races = [
		{"position": 3, "score": 756},
		{"position": 1, "score": 932},
		{"position": 2, "score": 918}
	]
	_display_race_records(dummy_races)

# UI更新
func _update_ui() -> void:
	# 必要に応じてUIの追加更新を行う
	pass

# スキルアイテム追加
func _add_skill_item(skill) -> void:
	var skill_item = skill_item_template.duplicate()
	skill_item.visible = true
	skills_list.add_child(skill_item)
	
	var skill_name_label = skill_item.get_node("HBoxContainer/SkillNameLabel")
	var skill_category_label = skill_item.get_node("HBoxContainer/SkillCategoryLabel")
	
	# スキル名
	if skill is Object and skill.has_method("get_name"):
		skill_name_label.text = skill.name
	elif skill is Dictionary and skill.has("name"):
		skill_name_label.text = skill.name
	else:
		skill_name_label.text = "不明なスキル"
	
	# スキルカテゴリ
	if skill is Object and skill.has_method("get_tags"):
		var tags = skill.category_tags if "category_tags" in skill else []
		skill_category_label.text = tags[0] if tags.size() > 0 else "一般"
	elif skill is Dictionary and skill.has("category"):
		skill_category_label.text = skill.category
	else:
		skill_category_label.text = "一般"

# タイトルに戻るボタン押下時
func _on_return_to_title_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/title_screen.tscn")

# 育成記録を保存ボタン押下時
func _on_save_record_button_pressed() -> void:
	var notification = AcceptDialog.new()
	notification.title = "通知"
	notification.dialog_text = "育成記録が保存されました"
	notification.min_size = Vector2(200, 100)
	
	add_child(notification)
	notification.popup_centered()

# 総合スコアを計算
func _calculate_total_score(horse, skills, race_records) -> int:
	# 仕様書の評価システムに基づいて計算
	# ステータス合計 40%、スキル開花数 30%、レース成績 20%、育成バランス 10%
	
	var stats_score = 0
	var skills_score = 0
	var race_score = 0
	var balance_score = 0
	
	# 1. ステータス合計点 (最大400点)
	if horse and horse.current_stats:
		var stats = horse.current_stats
		var total_stats = stats.get_main_stats_total()
		# 600点を満点とした場合の割合（最大400点）
		stats_score = int(min(total_stats / 600.0 * 400, 400))
	
	# 2. スキル開花数 (最大300点)
	if skills:
		# 10個を満点とした場合の割合（最大300点）
		skills_score = int(min(skills.size() / 10.0 * 300, 300))
	
	# 3. レース成績 (最大200点)
	if race_records:
		for race in race_records:
			if race.has("position"):
				match race.position:
					1: race_score += 60  # 1位
					2: race_score += 40  # 2位
					3: race_score += 30  # 3位
					4: race_score += 20  # 4位
					_: race_score += 10  # 5位以下
	
	# 4. 育成バランス (最大100点)
	if horse and horse.training_count:
		var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
		var min_count = 999
		var max_count = 0
		var total_count = 0
		
		# 各カテゴリのトレーニング回数を確認
		for category in categories:
			var count = horse.training_count.get(category, 0)
			min_count = min(min_count, count)
			max_count = max(max_count, count)
			total_count += count
		
		# バランス係数 = 最小回数 / 最大回数（0.0～1.0）
		# トレーニング回数が足りない場合は0に
		if max_count > 0 and total_count >= 10:
			var balance_factor = float(min_count) / float(max_count)
			balance_score = int(balance_factor * 100)
	
	# 合計スコア（最大1000点）
	var total_score = stats_score + skills_score + race_score + balance_score
	
	# デバッグログ
	print("DEBUG: 総合評価計算")
	print("  ステータス合計: " + str(stats_score) + "/400点")
	print("  スキル開花数: " + str(skills_score) + "/300点")
	print("  レース成績: " + str(race_score) + "/200点")
	print("  育成バランス: " + str(balance_score) + "/100点")
	print("  総合スコア: " + str(total_score) + "/1000点")
	
	return total_score

# ランクを決定
func _determine_rank(score: int) -> String:
	if score >= 900:
		return "S"
	elif score >= 750:
		return "A"
	elif score >= 600:
		return "B"
	elif score >= 450:
		return "C"
	else:
		return "D" 