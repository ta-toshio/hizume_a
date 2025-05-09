class_name Horse
extends Resource

# 基本情報
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""

# ステータス関連
@export var base_stats: StatBlock
@export var current_stats: StatBlock
@export var growth_rates: Dictionary = {
	"speed": 1.0,
	"stamina": 1.0,
	"technique": 1.0,
	"mental": 1.0,
	"flexibility": 1.0,
	"intellect": 1.0
}

# 適性情報
@export var aptitude: Array[String] = []  # 得意カテゴリ（例：速力、柔軟）

# 育成関連情報
@export var fatigue: int = 0  # 疲労値（0-100）
@export var age_in_months: int = 36  # 月齢（初期値：3歳=36ヶ月）
@export var training_count: Dictionary = {}  # カテゴリごとのトレーニング回数

# 初期化
func _init(horse_data: Dictionary = {}):
	if horse_data.is_empty():
		base_stats = StatBlock.new()
		current_stats = StatBlock.new()
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
	if data.has("base_stats"):
		base_stats = StatBlock.new(data.base_stats)
	else:
		base_stats = StatBlock.new()
		
	if data.has("current_stats"):
		current_stats = StatBlock.new(data.current_stats)
	else:
		current_stats = StatBlock.new(base_stats.to_dict())
	
	if data.has("growth_rates"):
		growth_rates = data.growth_rates
	if data.has("aptitude"):
		aptitude = data.aptitude
	if data.has("fatigue"):
		fatigue = data.fatigue
	if data.has("age_in_months"):
		age_in_months = data.age_in_months
	if data.has("training_count"):
		training_count = data.training_count 