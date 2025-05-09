class_name StatBlock
extends Resource

# 主要ステータス（6種）
@export var speed: int = 10        # 速力
@export var stamina: int = 10      # 持久力
@export var technique: int = 10    # 技術
@export var mental: int = 10       # 精神
@export var flexibility: int = 10  # 柔軟性
@export var intellect: int = 10    # 展開力（読み）

# 補助ステータス（6種）
@export var reaction: int = 5      # 反応速度
@export var balance: int = 5       # バランス
@export var focus: int = 5         # 集中力
@export var adaptability: int = 5  # 対応力
@export var judgment: int = 5      # 判断力
@export var recovery: int = 5      # 回復力

# 初期化関数
func _init(init_stats: Dictionary = {}):
	if not init_stats.is_empty():
		for stat_name in init_stats:
			if self.get(stat_name) != null:
				self.set(stat_name, init_stats[stat_name])

# 値をコピーする関数
func copy_from(other_stats: StatBlock) -> void:
	speed = other_stats.speed
	stamina = other_stats.stamina
	technique = other_stats.technique
	mental = other_stats.mental
	flexibility = other_stats.flexibility
	intellect = other_stats.intellect
	
	reaction = other_stats.reaction
	balance = other_stats.balance
	focus = other_stats.focus
	adaptability = other_stats.adaptability
	judgment = other_stats.judgment
	recovery = other_stats.recovery

# 主要ステータスの合計を取得
func get_main_stats_total() -> int:
	return speed + stamina + technique + mental + flexibility + intellect

# 全ステータスの合計を取得
func get_total_stats() -> int:
	return get_main_stats_total() + reaction + balance + focus + adaptability + judgment + recovery

# ステータスを配列形式で取得（UI表示用など）
func get_main_stats_array() -> Array:
	return [
		{"name": "速力", "value": speed},
		{"name": "持久力", "value": stamina},
		{"name": "技術", "value": technique},
		{"name": "精神", "value": mental},
		{"name": "柔軟性", "value": flexibility},
		{"name": "展開力", "value": intellect}
	]

# 補助ステータスを配列形式で取得
func get_secondary_stats_array() -> Array:
	return [
		{"name": "反応速度", "value": reaction},
		{"name": "バランス", "value": balance},
		{"name": "集中力", "value": focus},
		{"name": "対応力", "value": adaptability},
		{"name": "判断力", "value": judgment},
		{"name": "回復力", "value": recovery}
	]

# ステータスを増加させる
func increase_stat(stat_name: String, amount: int) -> void:
	if self.get(stat_name) != null:
		self.set(stat_name, self.get(stat_name) + amount)

# ステータス情報を辞書形式で取得
func to_dict() -> Dictionary:
	return {
		"speed": speed,
		"stamina": stamina,
		"technique": technique,
		"mental": mental,
		"flexibility": flexibility,
		"intellect": intellect,
		"reaction": reaction,
		"balance": balance,
		"focus": focus,
		"adaptability": adaptability,
		"judgment": judgment,
		"recovery": recovery
	} 