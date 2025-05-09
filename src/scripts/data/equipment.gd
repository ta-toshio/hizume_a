class_name Equipment
extends Resource

# 基本情報
@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var category: String = ""  # 'rider', 'horse', 'manual' のいずれか
@export var rarity: String = "SSR"  # 'SSR'固定（拡張性考慮）

# 効果関連
@export var effects: Array[Dictionary] = []
@export var related_training: String = ""  # 関連トレーニングカテゴリ（速力、精神など）
@export var associated_skill_ids: Array[String] = []  # このアイテムで開放されるスキルID

# 熟度関連
@export var familiarity: int = 0  # 現在の熟度ポイント（0-100）
@export var familiarity_level: int = 1  # 熟度レベル（1-4とMAX）

# 初期化
func _init(equipment_data: Dictionary = {}):
	if not equipment_data.is_empty():
		_load_from_dict(equipment_data)

# 熟度を加算
func add_familiarity(amount: int) -> void:
	familiarity += amount
	familiarity = clamp(familiarity, 0, 100)
	_update_familiarity_level()

# 熟度レベルを更新
func _update_familiarity_level() -> void:
	if familiarity < 20:
		familiarity_level = 1
	elif familiarity < 50:
		familiarity_level = 2
	elif familiarity < 80:
		familiarity_level = 3
	elif familiarity < 100:
		familiarity_level = 4
	else:
		familiarity_level = 5  # MAXレベル

# 熟度レベルをテキストで取得
func get_familiarity_level_text() -> String:
	if familiarity_level == 5:
		return "MAX"
	return "Lv." + str(familiarity_level)

# トレーニング効果ボーナスを計算
func get_training_bonus(is_resonance: bool = false) -> float:
	var bonus = 0.0
	for effect in effects:
		if effect.type == "trainingBoost":
			if effect.has("condition") and effect.condition == "resonance" and not is_resonance:
				continue
			bonus += effect.value / 100.0  # パーセント値を小数に変換
	return bonus

# スキルサポート効果を取得
func get_skill_support_bonus() -> int:
	for effect in effects:
		if effect.type == "skillSupport":
			if effect.has("condition") and effect.condition == "familiarity_lv2":
				if familiarity_level >= 2:
					return effect.value
			else:
				return effect.value
	return 0

# 辞書形式での保存・読み込み用
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"category": category,
		"rarity": rarity,
		"effects": effects,
		"related_training": related_training,
		"associated_skill_ids": associated_skill_ids,
		"familiarity": familiarity,
		"familiarity_level": familiarity_level
	}

# 辞書データから読み込み
func _load_from_dict(data: Dictionary) -> void:
	if data.has("id"):
		id = data.id
	if data.has("name"):
		name = data.name
	if data.has("description"):
		description = data.description
	if data.has("category"):
		category = data.category
	if data.has("rarity"):
		rarity = data.rarity
	if data.has("effects"):
		# 型変換：一般的なArrayからArray[Dictionary]への変換
		effects.clear()
		for effect in data.effects:
			if effect is Dictionary:
				effects.append(effect)
	if data.has("related_training"):
		related_training = data.related_training
	if data.has("associated_skill_ids"):
		# 型変換：一般的なArrayからArray[String]への変換
		associated_skill_ids.clear()
		for skill_id in data.associated_skill_ids:
			if skill_id is String:
				associated_skill_ids.append(skill_id)
	if data.has("familiarity"):
		familiarity = data.familiarity
		_update_familiarity_level()
	if data.has("familiarity_level"):
		familiarity_level = data.familiarity_level 
