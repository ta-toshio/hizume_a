extends Node

# クラスローダー
const DataLoaderScript = preload("res://scripts/managers/data_loader.gd")

# シングルトン設定
static var _instance = null
static func get_instance():
	return _instance

# ゲーム状態管理
var current_horse = null
var current_equipment: Dictionary = {}  # カテゴリごとの装備 {"rider": 装備オブジェクト, "horse": 装備オブジェクト, "manual": 装備オブジェクト}
var available_skills = []
var unlocked_skills = []

# トレーニング状態
var current_month: int = 0  # 現在の育成ターン（0-32）
var current_age: int = 3    # 現在の年齢（3歳からスタート）
var total_months: int = 33  # 育成期間（3歳4月〜5歳12月 = 33ヶ月）
var chakra_flow_category: String = ""  # 当月のチャクラ気配カテゴリ
var resonance_gauge: int = 0  # 補助ゲージ（0-5）
var consecutive_category: Dictionary = {}  # 各カテゴリの連続選択回数

# レース結果記録
var race_records = []

# ゲームデータ
var is_game_loaded = false  # ゲームデータがロードされたかどうか

# 初期化
func _ready():
	_instance = self
	
	# デバッグ用に初期データを設定
	if not current_horse:
		# 馬のデータがない場合はダミーデータを作成
		var horse_data = {
			"id": "debug_horse",
			"name": "風神雷神",
			"current_stats": {
				"speed": 70,
				"stamina": 65,
				"technique": 60,
				"intellect": 55,
				"flexibility": 60,
				"mental": 50,
				"reaction": 65,
				"balance": 60,
				"focus": 55,
				"adaptability": 60,
				"judgment": 55,
				"recovery": 60
			},
			"fatigue": 25
		}
		var horse_script = load("res://scripts/data/horse.gd")
		current_horse = horse_script.new(horse_data)
		
		# 装備も設定
		current_equipment = {
			"rider": _create_debug_equipment("rider", "風水使い", "speed"),
			"horse": _create_debug_equipment("horse", "風神具足", "stamina"),
			"manual": _create_debug_equipment("manual", "疾風の書", "technique")
		}
		
		# デバッグ用スキルデータを追加
		_setup_debug_skills()
		
		# チャクラ気配を設定
		_determine_chakra_flow()

# デバッグ用の装備作成ヘルパー関数
func _create_debug_equipment(type: String, name: String, related_training: String):
	var equip_data = {
		"id": "debug_" + type,
		"name": name,
		"type": type,
		"related_training": related_training,
		"familiarity": 10,
		"familiarity_level": 1,
		"associated_skill_ids": ["skill_1", "skill_2"]
	}
	var equipment_script = load("res://scripts/data/equipment.gd")
	return equipment_script.new(equip_data)

# デバッグ用のスキルデータをセットアップする関数
func _setup_debug_skills() -> void:
	print("DEBUG: デバッグ用スキルの設定")
	
	# Skillクラスのインスタンスを作成
	var skill_script = load("res://scripts/data/skill.gd")
	
	# 発走区間用スキル
	var start_skill = skill_script.new()
	start_skill.id = "skill_start"
	start_skill.name = "疾風の発進"
	start_skill.description = "発走時に素早くスタートする"
	# effectディクショナリに設定
	start_skill.effect = {
		"timing": "start",
		"bonus_type": "score",
		"value": 50
	}
	# race_screen.gdで参照できるよう追加のプロパティも設定
	start_skill.set_meta("activation_timing", "start")
	start_skill.set_meta("activation_rate", 0.7)
	start_skill.set_meta("effect_value", 50)
	# required_trainingの設定（1つずつ追加）
	start_skill.required_training.clear()
	start_skill.required_training.append("speed")
	start_skill.required_training.append("technique")
	start_skill.unlocked = true
	start_skill.progress = 100
	start_skill.progress_threshold = 100
	
	# 序盤区間用スキル
	var early_skill = skill_script.new()
	early_skill.id = "skill_early"
	early_skill.name = "序盤加速"
	early_skill.description = "序盤に加速力を増す"
	# effectディクショナリに設定
	early_skill.effect = {
		"timing": "early", 
		"bonus_type": "score",
		"value": 60
	}
	# race_screen.gdで参照できるよう追加のプロパティも設定
	early_skill.set_meta("activation_timing", "early")
	early_skill.set_meta("activation_rate", 0.6)
	early_skill.set_meta("effect_value", 60)
	# required_trainingの設定（1つずつ追加）
	early_skill.required_training.clear()
	early_skill.required_training.append("speed")
	early_skill.unlocked = true
	early_skill.progress = 100
	early_skill.progress_threshold = 100
	
	# 中盤区間用スキル
	var middle_skill = skill_script.new()
	middle_skill.id = "skill_middle"
	middle_skill.name = "中盤持久"
	middle_skill.description = "中盤で持久力を発揮する"
	# effectディクショナリに設定
	middle_skill.effect = {
		"timing": "middle",
		"bonus_type": "score",
		"value": 70
	}
	# race_screen.gdで参照できるよう追加のプロパティも設定
	middle_skill.set_meta("activation_timing", "middle")
	middle_skill.set_meta("activation_rate", 0.5)
	middle_skill.set_meta("effect_value", 70)
	# required_trainingの設定（1つずつ追加）
	middle_skill.required_training.clear()
	middle_skill.required_training.append("stamina")
	middle_skill.unlocked = true
	middle_skill.progress = 100
	middle_skill.progress_threshold = 100
	
	# 終盤区間用スキル
	var late_skill = skill_script.new()
	late_skill.id = "skill_late"
	late_skill.name = "終盤脚"
	late_skill.description = "終盤に加速力を発揮する"
	# effectディクショナリに設定
	late_skill.effect = {
		"timing": "late",
		"bonus_type": "score",
		"value": 80
	}
	# race_screen.gdで参照できるよう追加のプロパティも設定
	late_skill.set_meta("activation_timing", "late")
	late_skill.set_meta("activation_rate", 0.5)
	late_skill.set_meta("effect_value", 80)
	# required_trainingの設定（1つずつ追加）
	late_skill.required_training.clear()
	late_skill.required_training.append("stamina")
	late_skill.required_training.append("speed")
	late_skill.unlocked = true
	late_skill.progress = 100
	late_skill.progress_threshold = 100
	
	# スキルをunlocked_skillsに追加
	unlocked_skills.clear()
	unlocked_skills.append(start_skill)
	unlocked_skills.append(early_skill)
	unlocked_skills.append(middle_skill)
	unlocked_skills.append(late_skill)
	print("DEBUG: デバッグ用スキル追加完了: " + str(unlocked_skills.size()) + "個のスキル")

# 新しい育成サイクルを開始
func start_new_training(horse, equipments: Dictionary) -> void:
	current_horse = horse
	current_equipment = equipments
	current_month = 0
	current_age = 3  # 育成開始時は3歳
	
	# 初期スキル候補設定
	_setup_available_skills()
	
	# 最初の月のチャクラ気配を決定
	_determine_chakra_flow()
	
	# 連続カテゴリ選択回数初期化
	consecutive_category.clear()

# 月を進める
func advance_month() -> void:
	current_month += 1
	
	# 12ヶ月ごとに年齢を更新
	if current_month > 0 and current_month % 12 == 0:
		current_age += 1
	
	current_horse.advance_month()
	
	# 新しい月のチャクラ気配を決定
	_determine_chakra_flow()

# チャクラ気配を決定（簡易ランダム）
func _determine_chakra_flow() -> void:
	var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
	chakra_flow_category = categories[randi() % categories.size()]

# トレーニング選択実行
func execute_training(training_category: String) -> Dictionary:
	var result = {
		"stats_gains": {},
		"familiarity_gains": {},
		"skill_progress": [],
		"resonance": false,
		"success": true,
		"log_messages": []
	}
	
	# 日本語カテゴリ名を英語に変換
	var category = training_category
	match training_category:
		"速力": category = "speed"
		"柔軟": category = "flexibility"
		"精神": category = "mental"
		"技術": category = "technique" 
		"展開": category = "intellect"
		"持久": category = "stamina"
	
	print("GameManager: トレーニングカテゴリ = " + category + " (元: " + training_category + ")")
	print("DEBUG: 訓練前の馬ステータス = " + str(current_horse.get_current_stats_dict()))
	
	# 1. 疲労値加算
	var fatigue_increase = _get_fatigue_increase(category)
	var old_fatigue = current_horse.fatigue
	current_horse.add_fatigue(fatigue_increase)
	print("GameManager: 疲労値変化 " + str(old_fatigue) + " → " + str(current_horse.fatigue) + " (+" + str(fatigue_increase) + ")")
	result.log_messages.append("疲労が" + str(fatigue_increase) + "増加した")
	
	# 2. 成功判定
	var success_rate = _calculate_success_rate()
	result.success = randf() <= success_rate
	
	if not result.success:
		current_horse.add_fatigue(5)  # 失敗時は追加疲労
		result.log_messages.append("トレーニング失敗…型が乱れた…")
		return result
	
	# 3. 共鳴判定
	var resonance = _check_resonance(category)
	result.resonance = resonance
	
	if resonance:
		result.log_messages.append("チャクラが震えた…共鳴が発生！")
	
	# 4. ステータス成長計算
	var stats_gains = _calculate_stat_gains(category, resonance)
	result.stats_gains = stats_gains
	
	# 各ステータスの更新とログ
	# 最初に現在のステータスを取得
	if current_horse and is_instance_valid(current_horse):
		var stats_dict = current_horse.to_dict()
		if stats_dict.has("current_stats"):
			var current_stats = stats_dict["current_stats"]
			
			# 変更を保存する辞書を作成
			var updated_stats = current_stats.duplicate()
			
			# 各ステータスの更新
			for stat_name in stats_gains:
				var gain = stats_gains[stat_name]
				var old_value = current_stats.get(stat_name, 0)
				
				print("DEBUG: " + stat_name + "の更新前の値: " + str(old_value))
				
				# ステータス値を更新
				var new_value = old_value + gain
				updated_stats[stat_name] = new_value
				
				print("GameManager: " + stat_name + " 変化 " + str(old_value) + " → " + str(new_value) + " (+" + str(gain) + ")")
				
				# 実際の増加量が期待値と一致するか確認
				if new_value != old_value + gain:
					print("警告: ステータス増加量が期待値と一致しません: " + stat_name + 
						" 期待値=" + str(old_value + gain) + 
						" 実際=" + str(new_value))
				
				result.log_messages.append(stat_name + "が" + str(gain) + "上昇した")
			
			# 新しいステータスブロックを作成して馬に適用
			var new_stat_block_script = load("res://scripts/data/stat_block.gd")
			var new_stat_block = new_stat_block_script.new(updated_stats)
			current_horse.current_stats = new_stat_block
		else:
			print("DEBUG: current_stats データが見つかりません")
	else:
		print("DEBUG: current_horse が無効です")

	# 7. 連続トレーニング記録更新
	_update_consecutive_category(category)

	# ===== 最終検証 =====
	# 処理の前後で値が変わったことを検証
	print("DEBUG: === 最終検証 ===")

	if current_horse and is_instance_valid(current_horse):
		var stats_dict = current_horse.to_dict()
		if stats_dict.has("current_stats"):
			var current_stats = stats_dict["current_stats"]
			
			for stat_name in stats_gains:
				var original = stats_gains[stat_name]
				var current = current_stats.get(stat_name, 0)
				
				print("DEBUG: 最終検証: " + stat_name + ": " + str(original) + " → " + str(current) + 
					" (変化量: " + str(current - original) + ", 期待値: " + str(original) + ")")
				
				# 変化していない場合は警告
				if current == original:
					print("警告: " + stat_name + " が更新されていません！")
		else:
			print("DEBUG: current_stats データが見つかりません")
	else:
		print("DEBUG: current_horse が無効です")

	# StatBlockのclassを確認 - to_dictを使用
	if current_horse and is_instance_valid(current_horse):
		var stats_dict = current_horse.to_dict()
		print("DEBUG: StatBlock情報: " + str(stats_dict.get("current_stats", {})))
	else:
		print("DEBUG: current_horse が無効です")

	# Resource参照確認
	print("DEBUG: current_horse のアドレス: " + str(current_horse))
	
	# 5. 熟度加算
	var familiarity_gains = _calculate_familiarity_gains(category)
	result.familiarity_gains = familiarity_gains
	
	for equip_category in familiarity_gains:
		if current_equipment.has(equip_category):
			current_equipment[equip_category].add_familiarity(familiarity_gains[equip_category])
			result.log_messages.append(current_equipment[equip_category].name + "との調和が" + 
									  str(familiarity_gains[equip_category]) + "深まった")
	
	# 6. スキル進行更新
	var skill_progress = _update_skill_progress(category, resonance)
	result.skill_progress = skill_progress
	
	for skill_result in skill_progress:
		if skill_result.bloomed:
			result.log_messages.append("新たな技「" + skill_result.skill.name + "」が閃いた！")
		else:
			result.log_messages.append(skill_result.skill.name + "の習得が進んだ（あと" + 
									  str(skill_result.skill.progress_threshold - skill_result.skill.progress) + "）")
	
	return result

# 疲労上昇値を取得
func _get_fatigue_increase(category: String) -> int:
	match category:
		"速力", "持久":
			return 30
		"技術", "展開":
			return 25
		"柔軟":
			return 20
		"精神":
			return 10  # 精神カテゴリは疲労が少ない
		_:
			return 20

# 成功率計算
func _calculate_success_rate() -> float:
	var fatigue = current_horse.fatigue
	
	if fatigue < 60:
		return 1.0  # 100%
	elif fatigue < 80:
		return 0.7  # 70%
	else:
		return 0.3  # 30%

# 共鳴チェック
func _check_resonance(training_category: String) -> bool:
	# 補助ゲージが満タンなら100%共鳴
	if resonance_gauge >= 5:
		resonance_gauge = 0
		return true
	
	# チャクラ停滞時は共鳴なし
	if consecutive_category.get(training_category, 0) >= 3:
		return false
	
	# 条件1: 月のチャクラ気配カテゴリ = トレカテゴリ
	var condition1 = (chakra_flow_category == training_category)
	
	# 条件2: トレカテゴリ = 装備カテゴリ
	var condition2 = false
	for equip_category in current_equipment:
		if current_equipment[equip_category].related_training == training_category:
			condition2 = true
			break
	
	# 両方満たしていれば確率判定
	if condition1 and condition2:
		# 基本確率40%、熟度によって上昇
		var chance = 0.4
		for equip_category in current_equipment:
			var equipment = current_equipment[equip_category]
			if equipment.related_training == training_category:
				if equipment.familiarity_level >= 3:
					chance += 0.2
				elif equipment.familiarity_level >= 2:
					chance += 0.1
		
		return randf() <= chance
	
	return false

# ステータス成長計算
func _calculate_stat_gains(category: String, is_resonance: bool) -> Dictionary:
	var gains = {}
	
	# カテゴリごとの基本成長値設定
	match category:
		"speed", "速力":
			gains = {"speed": 6, "reaction": 2}
		"flexibility", "柔軟":
			gains = {"flexibility": 6, "balance": 2}
		"mental", "精神":
			gains = {"mental": 4, "focus": 3}
		"technique", "技術":
			gains = {"technique": 5, "adaptability": 1}
		"intellect", "展開":
			gains = {"intellect": 5, "judgment": 2}
		"stamina", "持久":
			gains = {"stamina": 6, "recovery": 2}
	
	# 調整係数計算
	var coefficient = _calculate_adjustment_coefficient(category)
	
	# ボーナス補正計算
	var bonus_modifier = 1.0
	
	# 共鳴ボーナス
	if is_resonance:
		bonus_modifier *= 1.5  # +50%
	
	# 装備ボーナス
	for equip_category in current_equipment:
		var equipment = current_equipment[equip_category]
		if equipment.related_training == category or _convert_category_ja_to_en(equipment.related_training) == category or _convert_category_en_to_ja(equipment.related_training) == category:
			bonus_modifier *= (1.0 + equipment.get_training_bonus(is_resonance))
		
		# 熟度ボーナス
		if equipment.familiarity_level >= 3:
			bonus_modifier *= 1.2  # +20%
		elif equipment.familiarity_level >= 2:
			bonus_modifier *= 1.1  # +10%
	
	# 最終成長量計算
	for stat in gains:
		gains[stat] = int(round(gains[stat] * coefficient * bonus_modifier))
		# 最低保証
		if gains[stat] < 1:
			gains[stat] = 1
	
	return gains

# 日本語カテゴリ名を英語に変換するヘルパー関数
func _convert_category_ja_to_en(ja_category: String) -> String:
	match ja_category:
		"速力": return "speed"
		"柔軟": return "flexibility"
		"精神": return "mental"
		"技術": return "technique"
		"展開": return "intellect"
		"持久": return "stamina"
		_: return ja_category  # 変換できない場合はそのまま返す
	
# 英語カテゴリ名を日本語に変換するヘルパー関数
func _convert_category_en_to_ja(en_category: String) -> String:
	match en_category:
		"speed": return "速力"
		"flexibility": return "柔軟"
		"mental": return "精神"
		"technique": return "技術"
		"intellect": return "展開"
		"stamina": return "持久"
		_: return en_category  # 変換できない場合はそのまま返す

# 調整係数計算
func _calculate_adjustment_coefficient(category: String) -> float:
	var coefficient = 1.0
	
	# 疲労による係数
	var fatigue = current_horse.fatigue
	if fatigue >= 80:
		coefficient *= 0.5
	elif fatigue >= 60:
		coefficient *= 0.8
	
	# チャクラ停滞による係数
	if consecutive_category.get(category, 0) >= 3:
		coefficient *= 0.8
	
	# ステータス上限による係数調整
	var main_stat = ""
	match category:
		"speed": main_stat = "speed"
		"flexibility": main_stat = "flexibility"
		"mental": main_stat = "mental"
		"technique": main_stat = "technique"
		"intellect": main_stat = "intellect"
		"stamina": main_stat = "stamina"
	
	# to_dictを使ってステータス値を取得
	if main_stat != "":
		var stats_dict = current_horse.to_dict()
		if stats_dict.has("current_stats"):
			var current_stats = stats_dict["current_stats"]
			var stat_value = current_stats.get(main_stat, 0)
			
			if stat_value > 120:
				coefficient *= 0.7
			elif stat_value > 100:
				coefficient *= 0.9
	
	return coefficient

# 熟度加算計算
func _calculate_familiarity_gains(training_category: String) -> Dictionary:
	var gains = {}
	
	for equip_category in current_equipment:
		var equipment = current_equipment[equip_category]
		
		# 一致カテゴリなら+10pt、非一致なら+2pt
		if equipment.related_training == training_category:
			gains[equip_category] = 10
		else:
			gains[equip_category] = 2
	
	return gains

# スキル進行更新
func _update_skill_progress(training_category: String, is_resonance: bool) -> Array:
	var results = []
	
	for skill in available_skills:
		# 既に開花済みのスキルはスキップ
		if skill.unlocked:
			continue
		
		# スキルの必要カテゴリが一致するか確認
		var category_match = false
		for req_category in skill.required_training:
			if req_category == training_category:
				category_match = true
				break
		
		if category_match:
			# 進行ポイント加算値計算
			var progress_points = 1
			
			# 共鳴ボーナス
			if is_resonance:
				progress_points += 1
			
			# 装備の熟度ボーナス
			for equip_category in current_equipment:
				var equipment = current_equipment[equip_category]
				if equipment.familiarity_level >= 2:
					progress_points += equipment.get_skill_support_bonus()
			
			# 進行追加
			var bloomed = skill.add_progress(progress_points)
			
			# 開花した場合、unlocked_skillsに追加
			if bloomed:
				unlocked_skills.append(skill)
			
			results.append({
				"skill": skill,
				"points_added": progress_points,
				"bloomed": bloomed
			})
	
	return results

# 連続トレーニング記録更新
func _update_consecutive_category(category: String) -> void:
	# まず他のカテゴリをリセット
	for other_category in consecutive_category.keys():
		if other_category != category:
			consecutive_category[other_category] = 0
	
	# 選択したカテゴリのカウント増加
	if not consecutive_category.has(category):
		consecutive_category[category] = 0
	
	consecutive_category[category] += 1
	
	# トレーニング記録を更新
	current_horse.record_training(category)

# 休養処理
func execute_rest() -> Dictionary:
	# 疲労回復
	var recovery = 50
	current_horse.reduce_fatigue(recovery)
	
	# 結果の組み立て
	var result = {
		"fatigue_recovery": recovery,
		"log_messages": ["休養で疲労が" + str(recovery) + "回復した"]
	}
	
	# 連続トレーニングカウントリセット
	consecutive_category.clear()
	
	return result

# レース処理
func execute_race() -> Dictionary:
	# 実際のレース計算はレース専用クラスを作るべきだが、ここでは簡易版
	var result = {
		"position": 0,
		"score": 0,
		"activated_skills": [],
		"logs": []
	}
	
	# レース結果を記録
	race_records.append(result)
	
	return result

# トレーニング状態オブジェクトを取得
func get_training_state() -> Node:
	return get_node("/root/TrainingState")

# レース結果を記録する関数
func record_race_result(result: Dictionary) -> void:
	# 既存のレコードがあれば上書き、なければ追加
	if race_records.size() > 0 and race_records.back().position == 0:
		race_records.pop_back()  # ダミーのレコードを削除
	
	# 有効なスキル情報を追加
	if not result.has("activated_skills"):
		result.activated_skills = []
	
	# ログ情報を追加
	if not result.has("logs"):
		result.logs = []
	
	# レース名を追加
	if not result.has("race_name"):
		var race_name = "チャクラカップ"
		if current_month < 12:
			race_name = "クラスレース"
		elif current_month >= 24:
			race_name = "チャクラG1"
		result.race_name = race_name
	
	# 月齢情報を追加
	result.month = current_month
	result.age = current_age
	
	# 記録を追加
	race_records.append(result)
	
	# 成長ボーナスを適用
	_apply_race_growth_bonus(result)

# レース後の成長ボーナスを適用
func _apply_race_growth_bonus(race_result: Dictionary) -> void:
	if not current_horse:
		return
	
	# 成績に応じたボーナス値（1-3着で大きなボーナス）
	var position_bonus = 0
	match race_result.position:
		1: position_bonus = 5  # 1着
		2: position_bonus = 3  # 2着
		3: position_bonus = 2  # 3着
		_: position_bonus = 1  # 4着以下
	
	# すべてのステータスに小さなボーナスを適用
	var stats_to_improve = ["speed", "stamina", "technique", "intellect"]
	
	# 現在のステータスを取得
	var stats_dict = current_horse.to_dict()
	if stats_dict.has("current_stats"):
		var current_stats = stats_dict["current_stats"]
		
		# 更新するステータス値を計算
		var updated_stats = current_stats.duplicate()
		for stat_name in stats_to_improve:
			var bonus = position_bonus
			if current_stats.has(stat_name):
				updated_stats[stat_name] = current_stats[stat_name] + bonus
		
		# 新しいステータスブロックを作成して馬に適用
		var new_stat_block_script = load("res://scripts/data/stat_block.gd")
		var new_stat_block = new_stat_block_script.new(updated_stats)
		current_horse.current_stats = new_stat_block
		
		print("DEBUG: レース後のボーナス適用: " + str(position_bonus) + "pt加算")
		print("DEBUG: 更新後のステータス: " + str(updated_stats))

# 利用可能なスキルを設定
func _setup_available_skills() -> void:
	available_skills.clear()
	unlocked_skills.clear()
	
	# 各装備の関連スキルを追加
	for equip_category in current_equipment:
		var equipment = current_equipment[equip_category]
		for skill_id in equipment.associated_skill_ids:
			# DataLoaderからスキルデータを取得
			var data_loader = DataLoaderScript.get_instance()
			var skill_data = data_loader.get_skill_data(skill_id)
			
			if skill_data:
				# Skillオブジェクトを作成（_load_from_dictで型変換も行われる）
				var skill_script = load("res://scripts/data/skill.gd")
				var skill = skill_script.new(skill_data)
				available_skills.append(skill)
			else:
				# データが見つからない場合の簡易作成（バックアップとして）
				var skill_script = load("res://scripts/data/skill.gd")
				var skill = skill_script.new()
				skill.id = skill_id
				skill.name = "仮スキル" + skill_id
				skill.description = "このスキルの説明文"
				
				# 型付き配列を正しく作成
				var training_categories = []
				training_categories.append(equipment.related_training)
				skill.required_training = training_categories
				
				available_skills.append(skill)

# 育成終了判定
func is_training_complete() -> bool:
	return current_month >= total_months

# 育成結果を計算
func calculate_training_result() -> Dictionary:
	print("DEBUG: 育成結果計算を実行")
	
	# 結果を保存する辞書
	var result = {
		"total_score": 0,
		"rank": "C",
		"stats_summary": current_horse.get_current_stats_dict() if current_horse else {},
		"unlocked_skills": unlocked_skills.size(),
		"race_results": race_records
	}
	
	# 評価項目別のスコア
	var stats_score = 0    # ステータス合計 (40%)
	var skills_score = 0   # スキル開花数 (30%)
	var race_score = 0     # レース成績 (20%)
	var balance_score = 0  # 育成バランス (10%)
	
	# 1. ステータス合計評価 (最大400点)
	if current_horse and current_horse.current_stats:
		var total_stats = current_horse.current_stats.get_main_stats_total()
		print("DEBUG: ステータス合計: " + str(total_stats))
		
		# 600点を満点とした場合の割合（最大400点）
		stats_score = int(min(total_stats / 600.0 * 400, 400))
	
	# 2. スキル開花数評価 (最大300点)
	if unlocked_skills:
		# 10個を満点とした場合の割合（最大300点）
		skills_score = int(min(unlocked_skills.size() / 10.0 * 300, 300))
	
	# 3. レース成績評価 (最大200点)
	if race_records:
		for race in race_records:
			if race.has("position"):
				match race.position:
					1: race_score += 60  # 1位
					2: race_score += 40  # 2位
					3: race_score += 30  # 3位
					4: race_score += 20  # 4位
					_: race_score += 10  # 5位以下
	
	# 4. 育成バランス評価 (最大100点)
	if current_horse and current_horse.training_count:
		var categories = ["速力", "柔軟", "精神", "技術", "展開", "持久"]
		var min_count = 999
		var max_count = 0
		var total_count = 0
		
		# 各カテゴリのトレーニング回数を確認
		for category in categories:
			var count = current_horse.training_count.get(category, 0)
			min_count = min(min_count, count)
			max_count = max(max_count, count)
			total_count += count
		
		print("DEBUG: トレーニングバランス - 最小:" + str(min_count) + " 最大:" + str(max_count) + " 合計:" + str(total_count))
		
		# バランス係数 = 最小回数 / 最大回数（0.0～1.0）
		# トレーニング回数が足りない場合は0に
		if max_count > 0 and total_count >= 10:
			var balance_factor = float(min_count) / float(max_count)
			balance_score = int(balance_factor * 100)
	
	# 合計スコア（最大1000点）
	result.total_score = stats_score + skills_score + race_score + balance_score
	
	# ランク判定
	if result.total_score >= 900:
		result.rank = "S"
	elif result.total_score >= 750:
		result.rank = "A"
	elif result.total_score >= 600:
		result.rank = "B"
	elif result.total_score >= 450:
		result.rank = "C"
	else:
		result.rank = "D"
	
	# デバッグログ
	print("DEBUG: 育成結果評価")
	print("  ステータス合計: " + str(stats_score) + "/400点")
	print("  スキル開花数: " + str(skills_score) + "/300点 (" + str(unlocked_skills.size()) + "個)")
	print("  レース成績: " + str(race_score) + "/200点")
	print("  育成バランス: " + str(balance_score) + "/100点")
	print("  総合スコア: " + str(result.total_score) + "/1000点")
	print("  評価ランク: " + result.rank)
	
	# 結果を保存（他の場所でも参照できるように）
	set_meta("training_result", result)
	
	return result

# セーブデータ作成
func create_save_data() -> Dictionary:
	var save_data = {
		"current_horse": current_horse.to_dict(),
		"current_month": current_month,
		"current_age": current_age,
		"equipments": {},
		"race_records": race_records,
		"unlocked_skills": []
	}
	
	# 装備データ保存
	for category in current_equipment:
		save_data.equipments[category] = current_equipment[category].to_dict()
	
	# スキルデータ保存
	for skill in unlocked_skills:
		save_data.unlocked_skills.append(skill.to_dict())
	
	return save_data

# セーブデータ読み込み
func load_save_data(save_data: Dictionary) -> void:
	# load_from_dictを呼び出して互換性を維持
	load_from_dict(save_data)

# セーブデータから読み込み
func load_from_dict(data: Dictionary) -> void:
	if data.has("current_month"):
		current_month = data.current_month
	
	if data.has("current_age"):
		current_age = data.current_age
	else:
		# 互換性のため年齢を推測（月から計算）
		current_age = 3 + int(current_month / 12)
	
	if data.has("chakra_flow_category"):
		chakra_flow_category = data.chakra_flow_category
	
	if data.has("resonance_gauge"):
		resonance_gauge = data.resonance_gauge
	
	if data.has("consecutive_category"):
		consecutive_category = data.consecutive_category
	
	# 馬データの読み込み
	if data.has("current_horse") and not data.current_horse.is_empty():
		var horse_script = load("res://scripts/data/horse.gd")
		current_horse = horse_script.new(data.current_horse)
	
	# 装備データの読み込み
	if data.has("equipments"):
		current_equipment.clear()
		var data_loader = DataLoaderScript.get_instance()
		
		for category in data.equipments:
			var equipment_data = data.equipments[category]
			var equipment_id = equipment_data.id if equipment_data is Dictionary and equipment_data.has("id") else equipment_data
			if data_loader and data_loader.has_equipment(equipment_id):
				current_equipment[category] = data_loader.get_equipment(equipment_id)
	
	# レース記録の読み込み
	if data.has("race_records"):
		race_records = data.race_records 

# 現在の疲労値を取得
func get_current_fatigue() -> int:
	if current_horse:
		return current_horse.fatigue
	return 0 

# セーブデータをJSONファイルに保存する
func save_game(save_slot: int = 1) -> bool:
	var save_data = create_save_data()
	var save_path = "user://save_slot_" + str(save_slot) + ".json"
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		print("セーブデータを保存しました: " + save_path)
		return true
	else:
		print("セーブデータの保存に失敗しました")
		return false

# セーブデータをJSONファイルから読み込む
func load_game(save_slot: int = 1) -> bool:
	var save_path = "user://save_slot_" + str(save_slot) + ".json"
	
	if not FileAccess.file_exists(save_path):
		print("セーブデータが見つかりません: " + save_path)
		return false
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if save_file:
		var json_string = save_file.get_as_text()
		var json_result = JSON.parse_string(json_string)
		
		if json_result:
			load_save_data(json_result)
			print("セーブデータを読み込みました: " + save_path)
			is_game_loaded = true  # ロード完了フラグを設定
			return true
		else:
			print("セーブデータの解析に失敗しました")
			return false
	else:
		print("セーブデータの読み込みに失敗しました")
		return false

# 利用可能なセーブスロットをチェックする
func get_available_save_slots(max_slots: int = 3) -> Array:
	var available_slots = []
	
	for slot in range(1, max_slots + 1):
		var save_path = "user://save_slot_" + str(slot) + ".json"
		
		if FileAccess.file_exists(save_path):
			var save_info = _get_save_slot_info(slot)
			available_slots.append(save_info)
		else:
			available_slots.append({
				"slot": slot,
				"exists": false,
				"info": "空のスロット"
			})
	
	return available_slots

# セーブスロットの情報を取得する
func _get_save_slot_info(slot: int) -> Dictionary:
	var save_path = "user://save_slot_" + str(slot) + ".json"
	var save_info = {
		"slot": slot,
		"exists": true,
		"info": "データなし"
	}
	
	if FileAccess.file_exists(save_path):
		var save_file = FileAccess.open(save_path, FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			var json_result = JSON.parse_string(json_string)
			
			if json_result:
				# セーブデータから主要な情報を抽出
				if json_result.has("current_horse") and json_result.current_horse.has("name"):
					save_info.horse_name = json_result.current_horse.name
				
				if json_result.has("current_month") and json_result.has("current_age"):
					save_info.progress = str(json_result.current_age) + "歳 " + str(int(json_result.current_month) % 12 + 1) + "月目"
				
				if save_info.has("horse_name") and save_info.has("progress"):
					save_info.info = save_info.horse_name + " (" + save_info.progress + ")"
				elif save_info.has("horse_name"):
					save_info.info = save_info.horse_name
	
	return save_info

# セーブデータを削除する
func delete_save(save_slot: int) -> bool:
	var save_path = "user://save_slot_" + str(save_slot) + ".json"
	
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		if dir:
			var err = dir.remove(save_path)
			if err == OK:
				print("セーブデータを削除しました: " + save_path)
				return true
			else:
				print("セーブデータの削除に失敗しました: エラーコード " + str(err))
				return false
		else:
			print("ディレクトリアクセスに失敗しました")
			return false
	else:
		print("削除するセーブデータが見つかりません: " + save_path)
		return false 
