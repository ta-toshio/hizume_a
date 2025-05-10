class_name Horse
extends Resource

# 基本情報
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""

# ステータス関連
@export var base_stats = null
@export var current_stats = null
@export var growth_rates: Dictionary = {
	"speed": 1.0,
	"stamina": 1.0,
	"technique": 1.0,
	"mental": 1.0,
	"flexibility": 1.0,
	"intellect": 1.0
}

# 適性情報
@export var aptitude = []  # 得意カテゴリ（例：速力、柔軟）

# 育成関連情報
@export var fatigue: int = 0  # 疲労値（0-100）
@export var age_in_months: int = 36  # 月齢（初期値：3歳=36ヶ月）
@export var training_count: Dictionary = {}  # カテゴリごとのトレーニング回数

# 初期化
func _init(horse_data: Dictionary = {}):
	if horse_data.is_empty():
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		base_stats = stat_block_script.new()
		current_stats = stat_block_script.new()
	else:
		_load_from_dict(horse_data)

# 疲労を増加
func add_fatigue(amount: int) -> void:
	fatigue += amount
	fatigue = clamp(fatigue, 0, 100)

# 疲労を回復
func reduce_fatigue(amount: int) -> void:
	fatigue -= amount
	fatigue = clamp(fatigue, 0, 100)

# 月齢を進める
func advance_month() -> void:
	age_in_months += 1

# 現在の年齢を文字列で取得
func get_age_string() -> String:
	var years = age_in_months / 12
	var months = age_in_months % 12
	return str(years) + "歳" + str(months) + "月"

# トレーニング回数を記録
func record_training(category: String) -> void:
	if not training_count.has(category):
		training_count[category] = 0
	training_count[category] += 1

# 連続トレーニング回数を取得（チャクラ停滞判定用）
func get_consecutive_training_count(category: String) -> int:
	# ここでは単純な実装としているが、実際には連続回数の履歴管理が必要
	return training_count.get(category, 0)

# 辞書形式での保存・読み込み用
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"base_stats": base_stats.to_dict() if base_stats else {},
		"current_stats": current_stats.to_dict() if current_stats else {},
		"growth_rates": growth_rates,
		"aptitude": aptitude,
		"fatigue": fatigue,
		"age_in_months": age_in_months,
		"training_count": training_count
	}

# 辞書データから読み込み
func _load_from_dict(data: Dictionary) -> void:
	if data.has("id"):
		id = data.id
	if data.has("name"):
		name = data.name
	if data.has("description"):
		description = data.description
	
	# ステータス情報の読み込み
	var stat_block_script = load("res://scripts/data/stat_block.gd")
	if data.has("base_stats"):
		base_stats = stat_block_script.new(data.base_stats)
	else:
		base_stats = stat_block_script.new()
		
	if data.has("current_stats"):
		current_stats = stat_block_script.new(data.current_stats)
	else:
		current_stats = stat_block_script.new(base_stats.to_dict())
	
	if data.has("growth_rates"):
		growth_rates = data.growth_rates
	if data.has("aptitude"):
		# 配列を明示的に変換
		aptitude.clear()
		for item in data.aptitude:
			aptitude.append(str(item))
	if data.has("fatigue"):
		fatigue = data.fatigue
	if data.has("age_in_months"):
		age_in_months = data.age_in_months
	if data.has("training_count"):
		training_count = data.training_count 

# 現在のステータスを取得（安全なアクセス用）
func get_current_stats():
	if current_stats == null:
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		current_stats = stat_block_script.new()
	return current_stats

# 現在のステータスを辞書形式で取得（安全なアクセス用）
func get_current_stats_dict() -> Dictionary:
	if current_stats == null:
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		current_stats = stat_block_script.new()
	return current_stats.to_dict()

# 特定のステータス値を取得（安全なアクセス用）
func get_stat_value(stat_name: String) -> int:
	if current_stats == null:
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		current_stats = stat_block_script.new()
	return current_stats.get_stat(stat_name)

# 特定のステータス値を設定（安全なアクセス用）
func set_stat_value(stat_name: String, value: int) -> void:
	if current_stats == null:
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		current_stats = stat_block_script.new()
	
	# ステータスが存在するか確認し、存在する場合のみ値を設定
	if current_stats.has_property(stat_name):
		current_stats.set(stat_name, value)

# 特定のステータス値を増加（安全なアクセス用）
func increase_stat_value(stat_name: String, amount: int) -> void:
	if current_stats == null:
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		current_stats = stat_block_script.new()
	current_stats.increase_stat(stat_name, amount)

# 全ステータスの合計を計算して返す
func get_total_stats() -> int:
	if current_stats == null:
		var stat_block_script = load("res://scripts/data/stat_block.gd")
		current_stats = stat_block_script.new()
	return current_stats.get_total_stats() 
