extends Node

# 育成状態管理
var current_training_options: Array[Dictionary] = []
var is_special_month: bool = false
var is_race_available: bool = false
var last_training_result: Dictionary = {}

# トレーニングカテゴリ一覧
const TRAINING_CATEGORIES = ["速力", "柔軟", "精神", "技術", "展開", "持久"]

# 強制レース月チェック用定数
const FORCED_RACE_MONTHS = [8, 20, 32]  # 3歳12月、4歳12月、5歳12月（0から始まるインデックスで8、20、32）

# 育成期間
const TRAINING_START_MONTH = 0  # 3歳4月
const TRAINING_END_MONTH = 33   # 5歳12月

# 初期化
func _init():
	pass

# トレーニング選択肢を生成
func generate_training_options() -> void:
	current_training_options.clear()
	
	for category in TRAINING_CATEGORIES:
		var training = _generate_training_for_category(category)
		current_training_options.append(training)

# カテゴリごとのトレーニング生成
func _generate_training_for_category(category: String) -> Dictionary:
	var training = {
		"id": "training_" + category + "_" + str(randi()),
		"name": _get_random_training_name(category),
		"category": category,
		"main_stat": _get_main_stat_for_category(category),
		"sub_stat": _get_sub_stat_for_category(category),
		"fatigue_increase": _get_fatigue_for_category(category),
		"description": "【" + category + "】系トレーニング"
	}
	
	return training

# カテゴリ別のメインステータス取得
func _get_main_stat_for_category(category: String) -> String:
	match category:
		"速力": return "speed"
		"柔軟": return "flexibility"
		"精神": return "mental"
		"技術": return "technique"
		"展開": return "intellect"
		"持久": return "stamina"
		_: return "speed"

# カテゴリ別のサブステータス取得
func _get_sub_stat_for_category(category: String) -> String:
	match category:
		"速力": return "reaction"
		"柔軟": return "balance"
		"精神": return "focus"
		"技術": return "adaptability"
		"展開": return "judgment"
		"持久": return "recovery"
		_: return "balance"

# カテゴリ別の疲労値取得
func _get_fatigue_for_category(category: String) -> int:
	match category:
		"速力", "持久": return 30
		"技術", "展開": return 25
		"柔軟": return 20
		"精神": return 10
		_: return 20

# ランダムなトレーニング名を生成
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

# 特別月間かどうかを判定
func check_special_month(month: int) -> bool:
	# 6ヶ月ごとに特別月間（例：3歳10月、4歳4月、4歳10月、5歳4月）
	var special_months = [6, 12, 18, 24]
	is_special_month = special_months.has(month)
	return is_special_month

# レース出走可能かどうかを判定
func check_race_availability(month: int) -> bool:
	# 12ターン目／24ターン目推奨（または自由に設定）
	is_race_available = (month >= 8)  # 最低でも8ヶ月目から出走可能に
	print("DEBUG: check_race_availability 呼び出し - 月: " + str(month) + " 判定結果: " + str(is_race_available))
	return is_race_available

# 強制レース月かどうかを判定
func is_forced_race_month(month: int) -> bool:
	print("DEBUG: 強制レース月チェック - 対象月: " + str(month))
	# 正しい強制レース月の判定（FORCED_RACE_MONTHS定数を使用）
	var result = FORCED_RACE_MONTHS.has(month)
	print("DEBUG: 強制レース月チェック結果: " + str(result) + " (月=" + str(month) + ", FORCED_RACE_MONTHS=" + str(FORCED_RACE_MONTHS) + ")")
	return result

# 最終月（育成完了月）かどうかを判定
func is_final_month(month: int) -> bool:
	# 33は存在しないので、32（5歳12月）が最終月
	return month >= 32

# 月齢から年齢と月を取得（"3歳4月"などの形式）
func get_age_month_string(month_index: int) -> String:
	# 3歳4月から始まるので、初期値は36ヶ月(3年)と4月
	var total_months = month_index + 40  # 36 + 4
	var years = total_months / 12
	var months = total_months % 12
	if months == 0:
		months = 12
		years -= 1
	
	return str(years) + "歳" + str(months) + "月"

# 育成進行状況の文字列表示（例：3歳4月 [1/33]）
func get_progress_display(month: int) -> String:
	var age_month = get_age_month_string(month)
	var progress = str(month + 1) + "/" + str(TRAINING_END_MONTH + 1)
	return age_month + " [" + progress + "]"

# 最後のトレーニング結果を設定
func set_last_training_result(result: Dictionary) -> void:
	last_training_result = result

# トレーニング結果のログメッセージを取得
func get_result_log_messages() -> Array[String]:
	if last_training_result.has("log_messages"):
		return last_training_result.log_messages
	return []

# 年と月から月インデックスを計算（デバッグ・検証用）
func calculate_month_index(age: int, month: int) -> int:
	# 3歳4月が基準（インデックス0）
	var base_age_in_months = 3 * 12 + 4 - 1  # 3歳4月（0から始まるインデックス）
	var target_age_in_months = age * 12 + month - 1  # 指定された年齢と月（0から始まるインデックス）
	
	return target_age_in_months - base_age_in_months

# 強制的にレース画面に遷移する必要があるかどうかを判定
func should_force_race_transition(month: int) -> bool:
	if is_forced_race_month(month):
		print("DEBUG: 強制レース月: " + get_age_month_string(month) + " (月インデックス: " + str(month) + ")")
		return true
	return false

# 指定カテゴリのトレーニングを取得
func get_training_by_category(category: String) -> Dictionary:
	for training in current_training_options:
		if training.category == category:
			return training
	
	# 見つからない場合は空の辞書を返す
	return {}

# 強制レース月のチェックと処理
func check_forced_race_transition(month: int) -> bool:
	# 3歳12月(月インデックス8)、4歳12月(月インデックス20)、5歳12月(月インデックス32)
	# これらの月は強制的にレースに遷移する
	return is_forced_race_month(month)

# 育成完了判定
func check_training_completion(month: int) -> bool:
	return is_final_month(month)

# 現在の月がトレーニング可能かどうかを判定
func can_train_in_current_month(month: int) -> bool:
	# 強制レース月（12月）はトレーニング不可
	# 月インデックス: 8=3歳12月, 20=4歳12月, 32=5歳12月
	if is_forced_race_month(month):
		print("DEBUG: トレーニング不可能な月です（レース専用月）: " + str(month))
		return false
	return true 