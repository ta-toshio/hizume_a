extends Control

# UI要素の参照 - ヘッダー部分
@onready var race_name_label = $MarginContainer/MainLayout/HeaderPanel/HeaderContainer/RaceInfoContainer/RaceNameLabel
@onready var race_distance_label = $MarginContainer/MainLayout/HeaderPanel/HeaderContainer/RaceInfoContainer/RaceDistanceLabel
@onready var race_track_label = $MarginContainer/MainLayout/HeaderPanel/HeaderContainer/RaceInfoContainer/RaceTrackLabel

# 馬情報関連
@onready var horse_name_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorseNameLabel
@onready var horse_age_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/HorseAgeLabel
@onready var rider_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/EquipmentContainer/RiderLabel
@onready var horse_equip_label = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/EquipmentContainer/HorseEquipLabel

# ステータス表示
@onready var stat_grid_container = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/StatsContainer/StatGridContainer
@onready var speed_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/StatsContainer/StatGridContainer/SpeedValue
@onready var stamina_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/StatsContainer/StatGridContainer/StaminaValue
@onready var technique_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/StatsContainer/StatGridContainer/TechniqueValue
@onready var intellect_value = $MarginContainer/MainLayout/ContentContainer/LeftPanel/VBoxContainer/StatsContainer/StatGridContainer/IntellectValue

# レース進行状況
@onready var phase_label = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/RaceStatusContainer/PhaseLabel
@onready var start_position = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/RaceTrackContainer/TrackSegmentsContainer/StartSegment/PositionLabel
@onready var first_position = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/RaceTrackContainer/TrackSegmentsContainer/FirstSegment/PositionLabel
@onready var middle_position = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/RaceTrackContainer/TrackSegmentsContainer/MiddleSegment/PositionLabel
@onready var final_position = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/RaceTrackContainer/TrackSegmentsContainer/FinalSegment/PositionLabel
@onready var goal_position = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/RaceTrackContainer/TrackSegmentsContainer/GoalSegment/PositionLabel

# 結果パネル
@onready var result_panel = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/ResultPanel
@onready var result_position_label = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/ResultPanel/VBoxContainer/ResultPositionLabel
@onready var result_score_label = $MarginContainer/MainLayout/ContentContainer/CenterPanel/VBoxContainer/ResultPanel/VBoxContainer/ResultScoreLabel

# スキルログ
@onready var skill_log_list = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/SkillLogContainer/SkillLogList
@onready var log_event_template = $MarginContainer/MainLayout/ContentContainer/RightPanel/VBoxContainer/SkillLogContainer/SkillLogList/LogEventTemplate

# ボタン
@onready var start_race_button = $MarginContainer/MainLayout/BottomButtonsContainer/StartRaceButton
@onready var next_segment_button = $MarginContainer/MainLayout/BottomButtonsContainer/NextSegmentButton
@onready var back_to_training_button = $MarginContainer/MainLayout/BottomButtonsContainer/BackToTrainingButton

# レース情報
var race_data = {
	"name": "チャクラカップ",
	"distance": 1600,
	"track_type": "芝コース",
	"difficulty": 2  # 難易度 1-5
}

# レース進行状態
var current_segment = -1  # -1: レース前, 0: 発走, 1: 序盤, 2: 中盤, 3: 終盤, 4: ゴール
var race_positions = [0, 0, 0, 0, 0]  # 各区間の順位
var race_scores = [0, 0, 0, 0, 0]  # 各区間のスコア
var activated_skills = []  # 発動したスキル情報

# 競争馬情報（ダミーNPC）
var rival_horses = []

func _ready():
	# テンプレートを非表示に
	log_event_template.visible = false
	
	# ボタンのシグナル接続
	start_race_button.pressed.connect(_on_start_race_button_pressed)
	next_segment_button.pressed.connect(_on_next_segment_button_pressed)
	back_to_training_button.pressed.connect(_on_back_to_training_button_pressed)
	
	# ボタンのフォントサイズ設定
	start_race_button.add_theme_font_size_override("font_size", 24)
	next_segment_button.add_theme_font_size_override("font_size", 24)
	back_to_training_button.add_theme_font_size_override("font_size", 24)
	
	# ラベルのフォントサイズ設定
	race_name_label.add_theme_font_size_override("font_size", 36)
	race_distance_label.add_theme_font_size_override("font_size", 24)
	race_track_label.add_theme_font_size_override("font_size", 24)
	
	horse_name_label.add_theme_font_size_override("font_size", 24)
	horse_age_label.add_theme_font_size_override("font_size", 24)
	rider_label.add_theme_font_size_override("font_size", 24)
	horse_equip_label.add_theme_font_size_override("font_size", 24)
	
	# ステータスラベルのフォントサイズ設定
	for child in stat_grid_container.get_children():
		if child is Label:
			child.add_theme_font_size_override("font_size", 24)
	
	# 位置表示ラベルのフォントサイズ設定
	phase_label.add_theme_font_size_override("font_size", 24)
	start_position.add_theme_font_size_override("font_size", 24)
	first_position.add_theme_font_size_override("font_size", 24)
	middle_position.add_theme_font_size_override("font_size", 24)
	final_position.add_theme_font_size_override("font_size", 24)
	goal_position.add_theme_font_size_override("font_size", 24)
	
	# ゲームマネージャからデータ取得
	var game_manager = GameManager.get_instance()
	if game_manager:
		_load_race_data(game_manager)
	else:
		# デバッグモード: ダミーデータでテスト表示
		_setup_debug_data()
	
	# 初期表示更新
	_update_ui()
	
	# ライバル馬の生成
	_generate_rival_horses()

# レースデータのロード
func _load_race_data(game_manager: Node) -> void:
	# 自分の馬情報をロード
	if game_manager.current_horse:
		var horse = game_manager.current_horse
		horse_name_label.text = "馬名：" + horse.name
		horse_age_label.text = "年齢：" + str(game_manager.current_age) + "歳"
		
		# ステータス表示
		speed_value.text = str(horse.current_stats.speed)
		stamina_value.text = str(horse.current_stats.stamina)
		technique_value.text = str(horse.current_stats.technique)
		intellect_value.text = str(horse.current_stats.intellect)
	
	# 装備情報をロード
	if game_manager.current_equipment:
		var equipment = game_manager.current_equipment
		if equipment.has("rider"):
			rider_label.text = "騎手：" + equipment.rider.name
		if equipment.has("horse"):
			horse_equip_label.text = "装備：" + equipment.horse.name
	
	# レース情報を設定（現在の育成ステージに応じたレース設定）
	var race_config = _determine_race_for_stage(game_manager.current_month)
	race_name_label.text = race_config.name
	race_distance_label.text = str(race_config.distance) + "m"
	race_track_label.text = race_config.track_type
	race_data = race_config

# 育成段階に応じたレース選定
func _determine_race_for_stage(current_month: int) -> Dictionary:
	var race_config = {
		"name": "クラスレース",
		"distance": 1600, 
		"track_type": "芝コース",
		"difficulty": 1
	}
	
	# 月に応じてレースの難易度を上げる
	if current_month < 12:  # 3歳
		race_config.name = "クラスレース"
		race_config.distance = 1600
		race_config.difficulty = 1
	elif current_month < 24:  # 4歳
		race_config.name = "チャクラカップ"
		race_config.distance = 1800
		race_config.difficulty = 2
	else:  # 5歳
		race_config.name = "チャクラG1"
		race_config.distance = 2000
		race_config.difficulty = 3
	
	return race_config

# デバッグデータのセットアップ
func _setup_debug_data() -> void:
	race_name_label.text = race_data.name
	race_distance_label.text = str(race_data.distance) + "m"
	race_track_label.text = race_data.track_type
	
	horse_name_label.text = "馬名：風神雷神"
	horse_age_label.text = "年齢：3歳"
	
	speed_value.text = "80"
	stamina_value.text = "70"
	technique_value.text = "65"
	intellect_value.text = "60"
	
	rider_label.text = "騎手：風水使い"
	horse_equip_label.text = "装備：風神具足"

# ライバル馬の生成
func _generate_rival_horses() -> void:
	rival_horses.clear()
	
	# レースの難易度に応じた頭数を生成
	var num_rivals = 7  # 基本は8頭立て（自分含めて）
	
	# ゲームマネージャからの情報を使用
	var game_manager = GameManager.get_instance()
	var base_stats = 60  # 基本ステータス値
	var player_avg_stats = base_stats
	
	if game_manager and game_manager.current_horse:
		# プレイヤーの馬のステータス平均を計算
		var horse_stats = game_manager.current_horse.current_stats
		player_avg_stats = (horse_stats.speed + horse_stats.stamina + 
						   horse_stats.technique + horse_stats.intellect) / 4
	
	# 難易度に応じたライバル馬を生成
	for i in range(num_rivals):
		var rival_level = race_data.difficulty  # 難易度ベース
		
		# 強さの多様性を出すための調整（上位2頭は強め、下位2頭は弱め）
		var strength_variance = 0
		if i < 2:  # 上位ライバル
			strength_variance = 10
		elif i > 4:  # 下位ライバル
			strength_variance = -10
		
		# ランダム要素（±5）
		var random_factor = randi() % 11 - 5
		
		# ライバルの強さ：プレイヤーの平均±調整値
		var rival_strength = player_avg_stats + (rival_level * 5) + strength_variance + random_factor
		
		var rival = {
			"name": _generate_rival_name(),
			"stats": {
				"speed": rival_strength + (randi() % 11 - 5),
				"stamina": rival_strength + (randi() % 11 - 5),
				"technique": rival_strength + (randi() % 11 - 5),
				"intellect": rival_strength + (randi() % 11 - 5)
			},
			"segment_scores": [0, 0, 0, 0, 0],  # 各区間のスコア
			"position": 0  # 最終順位
		}
		
		rival_horses.append(rival)

# ライバル馬の名前生成
func _generate_rival_name() -> String:
	var first_parts = ["疾風", "嵐", "流星", "紫電", "雷光", "風月", "雲龍", "天空", "月影", "雷神"]
	var second_parts = ["閃光", "疾走", "迅雷", "旋風", "飛翔", "幻影", "烈風", "閃", "迅", "駿"]
	
	var first = first_parts[randi() % first_parts.size()]
	var second = second_parts[randi() % second_parts.size()]
	
	return first + second

# UI全体の更新
func _update_ui() -> void:
	# レースフェーズの表示
	_update_phase_display()
	
	# 位置表示の更新
	_update_position_display()

# フェーズ表示の更新
func _update_phase_display() -> void:
	var phase_text = "出走直前"
	
	match current_segment:
		0: phase_text = "発走"
		1: phase_text = "序盤"
		2: phase_text = "中盤"
		3: phase_text = "終盤"
		4: phase_text = "ゴール"
	
	phase_label.text = phase_text

# 位置表示の更新
func _update_position_display() -> void:
	# 各区間の位置表示を更新
	if current_segment >= 0:
		start_position.text = "位置：" + str(race_positions[0]) + "番手"
	
	if current_segment >= 1:
		first_position.text = "位置：" + str(race_positions[1]) + "番手"
	
	if current_segment >= 2:
		middle_position.text = "位置：" + str(race_positions[2]) + "番手"
	
	if current_segment >= 3:
		final_position.text = "位置：" + str(race_positions[3]) + "番手"
	
	if current_segment >= 4:
		goal_position.text = "位置：" + str(race_positions[4]) + "着"

# レース開始ボタン押下時
func _on_start_race_button_pressed() -> void:
	current_segment = 0  # 発走区間へ
	
	# 発走区間のレース計算
	_calculate_segment_result()
	
	# UI更新
	_update_ui()
	
	# ボタン状態更新
	start_race_button.visible = false
	next_segment_button.visible = true

# 次の区間ボタン押下時
func _on_next_segment_button_pressed() -> void:
	current_segment += 1
	
	if current_segment <= 4:  # まだゴールしていない
		# 次の区間のレース計算
		_calculate_segment_result()
		
		# UI更新
		_update_ui()
		
		# 最終区間ならレース結果を表示
		if current_segment == 4:
			_show_race_result()
			
			# ボタン表示切り替え
			next_segment_button.visible = false
			back_to_training_button.visible = true
	else:
		# 既にゴールしている場合（想定外）
		_show_race_result()
		
		# ボタン表示切り替え
		next_segment_button.visible = false
		back_to_training_button.visible = true

# トレーニング画面に戻るボタン押下時
func _on_back_to_training_button_pressed() -> void:
	# レース結果をGameManagerに保存
	var race_result = {
		"position": race_positions[4],  # ゴール時の順位
		"score": _calculate_total_score(),
		"activated_skills": activated_skills
	}
	
	var game_manager = GameManager.get_instance()
	if game_manager:
		game_manager.record_race_result(race_result)
		game_manager.advance_month()
		
		# トレーニング画面へ遷移
		get_tree().change_scene_to_file("res://scenes/screens/training_screen.tscn")
	else:
		# デバッグモード
		print("レース結果: " + str(race_positions[4]) + "位, スコア: " + str(_calculate_total_score()))
		get_tree().change_scene_to_file("res://scenes/screens/training_screen.tscn")

# 区間ごとのレース結果計算
func _calculate_segment_result() -> void:
	# プレイヤーの馬のスコア計算
	var player_score = _calculate_player_segment_score(current_segment)
	
	# スキル発動チェック
	var activated_skill = _check_skill_activation(current_segment)
	if activated_skill != null:
		# スキル効果を適用
		player_score += activated_skill.score_bonus
		
		# スキルログに追加
		_add_skill_log(activated_skill)
		
		# 発動スキルを記録
		activated_skills.append(activated_skill)
	
	# スコアを記録
	race_scores[current_segment] = player_score
	
	# ライバル馬のスコア計算と全体の順位決定
	var all_scores = []
	
	# プレイヤーのエントリー
	all_scores.append({
		"id": "player",
		"score": player_score,
		"is_player": true
	})
	
	# ライバル馬のエントリー
	for i in range(rival_horses.size()):
		var rival = rival_horses[i]
		var rival_score = _calculate_rival_segment_score(rival, current_segment)
		rival.segment_scores[current_segment] = rival_score
		
		all_scores.append({
			"id": "rival_" + str(i),
			"score": rival_score,
			"is_player": false
		})
	
	# スコアでソート（降順）
	all_scores.sort_custom(func(a, b): return a.score > b.score)
	
	# 順位を決定
	for i in range(all_scores.size()):
		var entry = all_scores[i]
		if entry.is_player:
			race_positions[current_segment] = i + 1
			break
	
	# ゴール区間の場合は他の馬の最終順位も記録
	if current_segment == 4:
		for i in range(all_scores.size()):
			var entry = all_scores[i]
			if not entry.is_player:
				var rival_index = int(entry.id.split("_")[1])
				rival_horses[rival_index].position = i + 1

# プレイヤーの区間スコア計算
func _calculate_player_segment_score(segment: int) -> int:
	var game_manager = GameManager.get_instance()
	var score = 0
	
	if game_manager and game_manager.current_horse:
		var horse = game_manager.current_horse
		var stats = horse.current_stats
		
		# 区間ごとに重視されるステータスを変える
		match segment:
			0:  # 発走
				score = stats.reaction * 0.7 + stats.technique * 0.3
			1:  # 序盤
				score = stats.speed * 0.6 + stats.technique * 0.4
			2:  # 中盤
				score = stats.stamina * 0.5 + stats.intellect * 0.5
			3:  # 終盤
				score = stats.speed * 0.4 + stats.stamina * 0.6
			4:  # ゴール
				score = stats.speed * 0.5 + stats.technique * 0.5
		
		# 装備ボーナス
		if game_manager.current_equipment:
			var equipment = game_manager.current_equipment
			var bonus = 1.0
			
			if equipment.has("rider"):
				bonus += 0.1
			if equipment.has("horse"):
				bonus += 0.1
			
			score *= bonus
		
		# ランダム要素（±10%）
		var random_factor = 0.9 + randf() * 0.2
		score *= random_factor
	else:
		# デバッグモード：固定スコア + ランダム要素
		var base_stats = [80, 70, 65, 60]  # 速力、持久力、技術、展開力
		score = base_stats[segment % 4] * (0.9 + randf() * 0.2)
	
	return int(score)

# ライバルの区間スコア計算
func _calculate_rival_segment_score(rival: Dictionary, segment: int) -> int:
	var stats = rival.stats
	var score = 0
	
	# 区間ごとに重視されるステータスを変える
	match segment:
		0:  # 発走
			score = stats.technique * 0.5 + stats.intellect * 0.5
		1:  # 序盤
			score = stats.speed * 0.7 + stats.technique * 0.3
		2:  # 中盤
			score = stats.stamina * 0.6 + stats.intellect * 0.4
		3:  # 終盤
			score = stats.speed * 0.5 + stats.stamina * 0.5
		4:  # ゴール
			score = stats.speed * 0.4 + stats.technique * 0.6
	
	# AIの得意不得意（ランダム±15%）
	var random_factor = 0.85 + randf() * 0.3
	score *= random_factor
	
	return int(score)

# スキル発動チェック
func _check_skill_activation(segment: int) -> Variant:
	var game_manager = GameManager.get_instance()
	if not game_manager:
		return null
	
	# 解放済みスキルをチェック
	var available_skills = game_manager.unlocked_skills
	if available_skills.size() == 0:
		return null
	
	# 発動条件を満たすスキルをフィルタリング
	var eligible_skills = []
	
	for skill in available_skills:
		# スキルの発動区間が一致するかチェック
		var segment_condition_met = false
		
		match segment:
			0:  # 発走
				segment_condition_met = skill.get_meta("activation_timing", "") == "start"
			1:  # 序盤
				segment_condition_met = skill.get_meta("activation_timing", "") == "early"
			2:  # 中盤
				segment_condition_met = skill.get_meta("activation_timing", "") == "middle"
			3:  # 終盤
				segment_condition_met = skill.get_meta("activation_timing", "") == "late"
			4:  # ゴール
				segment_condition_met = skill.get_meta("activation_timing", "") == "goal"
		
		if segment_condition_met:
			eligible_skills.append(skill)
	
	# 対象スキルがなければnull
	if eligible_skills.size() == 0:
		return null
	
	# ランダムに1つ選ぶ
	var selected_skill = eligible_skills[randi() % eligible_skills.size()]
	
	# 発動率チェック
	var activation_chance = selected_skill.get_meta("activation_rate", 0.3)
	if randf() > activation_chance:
		return null
	
	# スキル効果を返す
	var skill_effect = {
		"name": selected_skill.name,
		"description": selected_skill.description,
		"score_bonus": selected_skill.get_meta("effect_value", 50),
		"segment": segment
	}
	
	return skill_effect

# スキルログの追加
func _add_skill_log(skill_effect: Dictionary) -> void:
	# テンプレートを複製
	var log_entry = log_event_template.duplicate()
	log_entry.visible = true
	skill_log_list.add_child(log_entry)
	
	# 区間名
	var segment_name = ""
	match skill_effect.segment:
		0: segment_name = "発走"
		1: segment_name = "序盤"
		2: segment_name = "中盤"
		3: segment_name = "終盤"
		4: segment_name = "ゴール"
	
	# ログ内容を設定
	var segment_label = log_entry.get_node("VBoxContainer/SegmentLabel")
	segment_label.text = "[" + segment_name + "]"
	segment_label.add_theme_font_size_override("font_size", 20)
	
	var skill_name_label = log_entry.get_node("VBoxContainer/SkillNameLabel")
	skill_name_label.text = skill_effect.name
	skill_name_label.add_theme_font_size_override("font_size", 22)
	
	var skill_effect_label = log_entry.get_node("VBoxContainer/SkillEffectLabel")
	skill_effect_label.text = "+ " + str(skill_effect.score_bonus) + " pt"
	skill_effect_label.add_theme_font_size_override("font_size", 20)

# レース結果表示
func _show_race_result() -> void:
	# レース結果パネルを表示
	result_panel.visible = true
	
	# 結果表示
	result_position_label.text = "最終順位: " + str(race_positions[4]) + "着"
	result_position_label.add_theme_font_size_override("font_size", 30)
	
	var total_score = _calculate_total_score()
	result_score_label.text = "レーススコア: " + str(total_score)
	result_score_label.add_theme_font_size_override("font_size", 24)
	
	# 結果に応じたスタイル設定
	if race_positions[4] <= 3:
		result_position_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.1))  # 金色（入賞）
	else:
		result_position_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))  # グレー

# 総合スコア計算
func _calculate_total_score() -> int:
	var total = 0
	for score in race_scores:
		total += score
	
	# 順位ボーナス
	var position_bonus = 0
	match race_positions[4]:  # ゴール時の順位
		1: position_bonus = 300
		2: position_bonus = 200
		3: position_bonus = 100
		4: position_bonus = 50
		5: position_bonus = 30
		_: position_bonus = 10
	
	total += position_bonus
	
	return total

# GameManagerにレース結果を記録する関数
func record_race_result(result: Dictionary) -> void:
	var game_manager = GameManager.get_instance()
	if game_manager:
		game_manager.race_records.append(result) 
