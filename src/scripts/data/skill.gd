class_name Skill
extends Resource

# 基本情報
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""

# スキル効果
@export var effect: Dictionary = {
	"timing": "",  # 'start', 'early', 'middle', 'final'
	"bonus_type": "",  # 'speed', 'stamina', 'control', 'score'
	"value": 0
}

# 発動条件
@export var condition: Dictionary = {
	"trigger": "always",  # 'always', 'when_losing', 'when_ahead', 'low_stamina'
	"position": "",  # 'top', 'mid', 'bottom'
	"section": ""  # 'early', 'middle', 'final'
}

# 分類・習得条件
@export var category_tags: Array[String] = []  # 速力系、精神系など
@export var required_training: Array[String] = []  # 開花に必要なカテゴリ
@export var progress_threshold: int = 5  # 開花に必要な進行ポイント

# 進行状況
@export var progress: int = 0  # 現在の進行ポイント
@export var unlocked: bool = false  # 開花済みか

# 初期化
func _init(skill_data: Dictionary = {}):
	if not skill_data.is_empty():
		_load_from_dict(skill_data)

# 進行ポイントを加算
func add_progress(amount: int) -> bool:
	if unlocked:
		return false
		
	progress += amount
	
	# 開花条件達成時
	if progress >= progress_threshold:
		unlocked = true
		return true  # 開花イベント発生を通知
	
	return false

# 進行度をパーセントで取得
func get_progress_percent() -> float:
	return float(progress) / float(progress_threshold) * 100.0

# スキル発動条件チェック
func check_activation_condition(race_state: Dictionary) -> bool:
	# レース状態に応じた発動条件チェック（簡易版）
	if condition.trigger == "always":
		return true
		
	if condition.section != "" and condition.section != race_state.current_section:
		return false
		
	if condition.trigger == "when_losing" and race_state.position < 3:  # 3位以下なら発動
		return true
		
	if condition.trigger == "when_ahead" and race_state.position <= 2:  # 2位以上なら発動
		return true
		
	if condition.trigger == "low_stamina" and race_state.stamina < 30:  # スタミナ低下時
		return true
		
	return false

# スキル効果を適用
func apply_effect(race_state: Dictionary) -> Dictionary:
	var result = race_state.duplicate()
	
	match effect.bonus_type:
		"speed":
			result.speed_bonus += effect.value
		"stamina":
			result.stamina_bonus += effect.value
		"control":
			result.control_bonus += effect.value
		"score":
			result.score_bonus += effect.value
	
	return result

# 辞書形式での保存・読み込み用
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"effect": effect,
		"condition": condition,
		"category_tags": category_tags,
		"required_training": required_training,
		"progress_threshold": progress_threshold,
		"progress": progress,
		"unlocked": unlocked
	}

# 辞書データから読み込み
func _load_from_dict(data: Dictionary) -> void:
	if data.has("id"):
		id = data.id
	if data.has("name"):
		name = data.name
	if data.has("description"):
		description = data.description
	if data.has("effect"):
		effect = data.effect
	if data.has("condition"):
		condition = data.condition
	if data.has("category_tags"):
		category_tags = data.category_tags
	if data.has("required_training"):
		required_training = data.required_training
	if data.has("progress_threshold"):
		progress_threshold = data.progress_threshold
	if data.has("progress"):
		progress = data.progress
	if data.has("unlocked"):
		unlocked = data.unlocked 