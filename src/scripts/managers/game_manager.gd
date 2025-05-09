extends Node

# シングルトン設定
static var _instance = null
static func get_instance():
	return _instance

# ゲーム状態管理
var current_horse: Horse = null
var current_equipment: Dictionary = {}  # カテゴリごとの装備 {"rider": Equipment, "horse": Equipment, "manual": Equipment}
var available_skills: Array[Skill] = []
var unlocked_skills: Array[Skill] = []

# トレーニング状態
var current_month: int = 0  # 現在の育成ターン（0-32）
var total_months: int = 33  # 育成期間（3歳4月〜5歳12月 = 33ヶ月）
var chakra_flow_category: String = ""  # 当月のチャクラ気配カテゴリ
var resonance_gauge: int = 0  # 補助ゲージ（0-5）
var consecutive_category: Dictionary = {}  # 各カテゴリの連続選択回数

# レース結果記録
var race_records: Array[Dictionary] = []

# 初期化
func _ready():
	_instance = self
	
# 新しい育成サイクルを開始
func start_new_training(horse: Horse, equipments: Dictionary) -> void:
	current_horse = horse
	current_equipment = equipments
	current_month = 0
	
	# 初期スキル候補設定
	_setup_available_skills()
	
	# 最初の月のチャクラ気配を決定
	_determine_chakra_flow()
	
	# 連続カテゴリ選択回数初期化
	consecutive_category.clear()

# 月を進める
func advance_month() -> void:
	current_month += 1
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
	
	# 1. 疲労値加算
	var fatigue_increase = _get_fatigue_increase(training_category)
	current_horse.add_fatigue(fatigue_increase)
	result.log_messages.append("疲労が" + str(fatigue_increase) + "増加した")
	
	# 2. 成功判定
	var success_rate = _calculate_success_rate()
	result.success = randf() <= success_rate
	
	if not result.success:
		current_horse.add_fatigue(5)  # 失敗時は追加疲労
		result.log_messages.append("トレーニング失敗…型が乱れた…")
		return result
	
	# 3. 共鳴判定
	var resonance = _check_resonance(training_category)
	result.resonance = resonance
	
	if resonance:
		result.log_messages.append("チャクラが震えた…共鳴が発生！")
	
	# 4. ステータス成長計算
	var stats_gains = _calculate_stat_gains(training_category, resonance)
	result.stats_gains = stats_gains
	
	for stat_name in stats_gains:
		current_horse.current_stats.increase_stat(stat_name, stats_gains[stat_name])
		result.log_messages.append(stat_name + "が" + str(stats_gains[stat_name]) + "上昇した")
	
	# 5. 熟度加算
	var familiarity_gains = _calculate_familiarity_gains(training_category)
	result.familiarity_gains = familiarity_gains
	
	for equip_category in familiarity_gains:
		if current_equipment.has(equip_category):
			current_equipment[equip_category].add_familiarity(familiarity_gains[equip_category])
			result.log_messages.append(current_equipment[equip_category].name + "との調和が" + 
									  str(familiarity_gains[equip_category]) + "深まった")
	
	# 6. スキル進行更新
	var skill_progress = _update_skill_progress(training_category, resonance)
	result.skill_progress = skill_progress
	
	for skill_result in skill_progress:
		if skill_result.bloomed:
			result.log_messages.append("新たな技「" + skill_result.skill.name + "」が閃いた！")
		else:
			result.log_messages.append(skill_result.skill.name + "の習得が進んだ（あと" + 
									  str(skill_result.skill.progress_threshold - skill_result.skill.progress) + "）")
	
	# 7. 連続トレーニング記録更新
	_update_consecutive_training(training_category)
	
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
		"速力":
			gains = {"speed": 6, "reaction": 2}
		"柔軟":
			gains = {"flexibility": 6, "balance": 2}
		"精神":
			gains = {"mental": 4, "focus": 3}
		"技術":
			gains = {"technique": 5, "adaptability": 1}
		"展開":
			gains = {"intellect": 5, "judgment": 2}
		"持久":
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
		if equipment.related_training == category:
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
		"速力": main_stat = "speed"
		"柔軟": main_stat = "flexibility"
		"精神": main_stat = "mental"
		"技術": main_stat = "technique"
		"展開": main_stat = "intellect"
		"持久": main_stat = "stamina"
	
	if main_stat != "" and current_horse.current_stats.get(main_stat) > 120:
		coefficient *= 0.7
	elif main_stat != "" and current_horse.current_stats.get(main_stat) > 100:
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
func _update_consecutive_training(category: String) -> void:
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

# 利用可能なスキルを設定
func _setup_available_skills() -> void:
	available_skills.clear()
	unlocked_skills.clear()
	
	# 各装備の関連スキルを追加
	for equip_category in current_equipment:
		var equipment = current_equipment[equip_category]
		for skill_id in equipment.associated_skill_ids:
			# DataLoaderからスキルデータを取得
			var skill_data = DataLoader.get_instance().get_skill_data(skill_id)
			
			if skill_data:
				# Skillオブジェクトを作成（_load_from_dictで型変換も行われる）
				var skill = Skill.new(skill_data)
				available_skills.append(skill)
			else:
				# データが見つからない場合の簡易作成（バックアップとして）
				var skill = Skill.new()
				skill.id = skill_id
				skill.name = "仮スキル" + skill_id
				skill.description = "このスキルの説明文"
				
				# 型付き配列を正しく作成
				var training_categories: Array[String] = []
				training_categories.append(equipment.related_training)
				skill.required_training = training_categories
				
				available_skills.append(skill)

# 育成終了判定
func is_training_complete() -> bool:
	return current_month >= total_months

# 育成結果の評価を計算
func calculate_training_result() -> Dictionary:
	# 実際にはより複雑な計算を行う
	var result = {
		"total_score": 0,
		"rank": "C",
		"stats_summary": current_horse.current_stats.to_dict(),
		"unlocked_skills": unlocked_skills.size(),
		"race_results": race_records
	}
	
	# スコア計算
	result.total_score = current_horse.current_stats.get_total_stats() + unlocked_skills.size() * 10
	
	# ランク決定
	if result.total_score >= 1000:
		result.rank = "S"
	elif result.total_score >= 850:
		result.rank = "A"
	elif result.total_score >= 700:
		result.rank = "B"
	elif result.total_score >= 500:
		result.rank = "C"
	else:
		result.rank = "D"
	
	return result

# セーブデータ作成
func create_save_data() -> Dictionary:
	var save_data = {
		"current_horse": current_horse.to_dict(),
		"current_month": current_month,
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
	# 実装予定
	pass 
