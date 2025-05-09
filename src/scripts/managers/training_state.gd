extends Node

# 育成状態管理
var current_training_options: Array[Dictionary] = []
var is_special_month: bool = false
var is_race_available: bool = false
var last_training_result: Dictionary = {}

# トレーニングカテゴリ一覧
const TRAINING_CATEGORIES = ["速力", "柔軟", "精神", "技術", "展開", "持久"]

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
	return is_race_available

# 最後のトレーニング結果を設定
func set_last_training_result(result: Dictionary) -> void:
	last_training_result = result

# トレーニング結果のログメッセージを取得
func get_result_log_messages() -> Array[String]:
	if last_training_result.has("log_messages"):
		return last_training_result.log_messages
	return []

# 指定カテゴリのトレーニングを取得
func get_training_by_category(category: String) -> Dictionary:
	for training in current_training_options:
		if training.category == category:
			return training
	
	# 見つからない場合は空の辞書を返す
	return {} 