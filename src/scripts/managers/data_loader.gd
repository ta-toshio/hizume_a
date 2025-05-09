extends Node

# シングルトン設定
static var _instance = null
static func get_instance():
	return _instance

# データキャッシュ
var _horses_data: Dictionary = {}
var _equipment_data: Dictionary = {}
var _skills_data: Dictionary = {}

# 初期化
func _ready():
	_instance = self
	_load_all_data()

# 全データを読み込む
func _load_all_data() -> void:
	_load_horses_data()
	_load_equipment_data()
	_load_skills_data()

# 馬データを読み込む
func _load_horses_data() -> void:
	var json_data = _load_json_file("res://resources/data/horses.json")
	if json_data:
		for horse_data in json_data:
			if horse_data.has("id"):
				_horses_data[horse_data.id] = horse_data

# 装備データを読み込む
func _load_equipment_data() -> void:
	var json_data = _load_json_file("res://resources/data/equipment.json")
	if json_data:
		for equip_data in json_data:
			if equip_data.has("id"):
				_equipment_data[equip_data.id] = equip_data

# スキルデータを読み込む
func _load_skills_data() -> void:
	var json_data = _load_json_file("res://resources/data/skills.json")
	if json_data:
		for skill_data in json_data:
			if skill_data.has("id"):
				_skills_data[skill_data.id] = skill_data

# JSONファイルを読み込む
func _load_json_file(file_path: String) -> Array:
	if not FileAccess.file_exists(file_path):
		print("警告：ファイルが見つかりません: ", file_path)
		return []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		print("JSONの解析エラー: ", json.get_error_message(), " at line ", json.get_error_line())
		return []
	
	var data = json.get_data()
	if data is Array:
		return data
	
	return []

# 馬オブジェクトを取得
func get_horse(horse_id: String) -> Horse:
	if _horses_data.has(horse_id):
		return Horse.new(_horses_data[horse_id])
	
	# 存在しないIDの場合はダミーを返す
	print("警告：存在しない馬ID: ", horse_id)
	return Horse.new()

# 利用可能な全馬のIDを取得
func get_all_horse_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _horses_data.keys():
		ids.append(id)
	return ids

# 利用可能な全装備のIDを取得
func get_all_equipment_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _equipment_data.keys():
		ids.append(id)
	return ids

# 装備オブジェクトを取得
func get_equipment(equipment_id: String) -> Equipment:
	if _equipment_data.has(equipment_id):
		return Equipment.new(_equipment_data[equipment_id])
	
	# 存在しないIDの場合はダミーを返す
	print("警告：存在しない装備ID: ", equipment_id)
	return Equipment.new()

# カテゴリ別の装備IDリストを取得
func get_equipment_ids_by_category(category: String) -> Array[String]:
	var ids: Array[String] = []
	for id in _equipment_data.keys():
		if _equipment_data[id].category == category:
			ids.append(id)
	return ids

# スキルオブジェクトを取得
func get_skill(skill_id: String) -> Skill:
	if _skills_data.has(skill_id):
		return Skill.new(_skills_data[skill_id])
	
	# 存在しないIDの場合はダミーを返す
	print("警告：存在しないスキルID: ", skill_id)
	return Skill.new()

# 装備IDに関連付けられたスキルを取得
func get_skills_for_equipment(equipment_id: String) -> Array[Skill]:
	var skills: Array[Skill] = []
	
	if not _equipment_data.has(equipment_id):
		return skills
	
	var equipment_data = _equipment_data[equipment_id]
	if equipment_data.has("associated_skill_ids"):
		for skill_id in equipment_data.associated_skill_ids:
			if _skills_data.has(skill_id):
				skills.append(Skill.new(_skills_data[skill_id]))
	
	return skills

# ダミーデータを生成（正式なJSONが作成されるまでの仮実装）
func generate_dummy_data() -> void:
	print("ダミーデータを生成しています...")
	# 馬のダミーデータ
	var horse_data = {
		"id": "horse_001",
		"name": "疾風天陽",
		"description": "速さに優れた名馬",
		"base_stats": {
			"speed": 15,
			"stamina": 12,
			"technique": 10,
			"mental": 8,
			"flexibility": 11,
			"intellect": 9,
			"reaction": 7,
			"balance": 6,
			"focus": 5,
			"adaptability": 6,
			"judgment": 5,
			"recovery": 6
		},
		"growth_rates": {
			"speed": 1.2,
			"stamina": 1.0,
			"technique": 0.9,
			"mental": 0.8,
			"flexibility": 1.1,
			"intellect": 0.9
		},
		"aptitude": ["速力", "柔軟"]
	}
	_horses_data["horse_001"] = horse_data
	
	# 装備のダミーデータ
	_create_dummy_equipments()
	
	# スキルのダミーデータ
	_create_dummy_skills()
	
	print("ダミーデータの生成が完了しました")

# ダミー装備データ生成
func _create_dummy_equipments() -> void:
	# 騎手装備
	var rider_equipment = {
		"id": "eq_rider_001",
		"name": "静心の装束",
		"description": "精神を安定させる騎手装束",
		"category": "rider",
		"rarity": "SSR",
		"effects": [
			{ "type": "trainingBoost", "value": 15 },
			{ "type": "skillSupport", "value": 1, "condition": "familiarity_lv2" }
		],
		"related_training": "精神",
		"associated_skill_ids": ["skill_001", "skill_002"]
	}
	_equipment_data["eq_rider_001"] = rider_equipment
	
	# 馬装備
	var horse_equipment = {
		"id": "eq_horse_001",
		"name": "無音蹄",
		"description": "足音を消し、静かに疾走する",
		"category": "horse",
		"rarity": "SSR",
		"effects": [
			{ "type": "trainingBoost", "value": 10 },
			{ "type": "eventBuff", "value": 20, "condition": "resonance" }
		],
		"related_training": "速力",
		"associated_skill_ids": ["skill_003"]
	}
	_equipment_data["eq_horse_001"] = horse_equipment
	
	# 導法書装備
	var manual_equipment = {
		"id": "eq_manual_001",
		"name": "柔走体捌の書",
		"description": "柔軟性を高める秘伝書",
		"category": "manual",
		"rarity": "SSR",
		"effects": [
			{ "type": "skillSupport", "value": 2 },
			{ "type": "trainingBoost", "value": 5 }
		],
		"related_training": "柔軟",
		"associated_skill_ids": ["skill_004"]
	}
	_equipment_data["eq_manual_001"] = manual_equipment

# ダミースキルデータ生成
func _create_dummy_skills() -> void:
	# スキル1
	var skill1 = {
		"id": "skill_001",
		"name": "静心制圧",
		"description": "中盤、精神が安定して展開を読む力が強まる",
		"effect": {
			"timing": "middle",
			"bonus_type": "control",
			"value": 10
		},
		"condition": {
			"trigger": "always",
			"section": "middle"
		},
		"category_tags": ["精神系", "展開系"],
		"required_training": ["精神", "展開"],
		"progress_threshold": 5
	}
	_skills_data["skill_001"] = skill1
	
	# スキル2
	var skill2 = {
		"id": "skill_002",
		"name": "心身統合",
		"description": "終盤で集中を保ちつつスタミナ消費を抑える",
		"effect": {
			"timing": "final",
			"bonus_type": "stamina",
			"value": 12
		},
		"condition": {
			"trigger": "low_stamina",
			"section": "final"
		},
		"category_tags": ["精神系", "持久系"],
		"required_training": ["精神", "持久"],
		"progress_threshold": 5
	}
	_skills_data["skill_002"] = skill2
	
	# スキル3
	var skill3 = {
		"id": "skill_003",
		"name": "無音疾風",
		"description": "終盤、静かに加速し順位を上げやすくなる",
		"effect": {
			"timing": "final",
			"bonus_type": "speed",
			"value": 15
		},
		"condition": {
			"trigger": "when_losing",
			"position": "mid",
			"section": "final"
		},
		"category_tags": ["速力系"],
		"required_training": ["速力", "技術"],
		"progress_threshold": 5
	}
	_skills_data["skill_003"] = skill3
	
	# スキル4
	var skill4 = {
		"id": "skill_004",
		"name": "柔式転身",
		"description": "スタート時、柔軟な動きで有利な位置を取る",
		"effect": {
			"timing": "start",
			"bonus_type": "control",
			"value": 8
		},
		"condition": {
			"trigger": "always",
			"section": "early"
		},
		"category_tags": ["柔軟系"],
		"required_training": ["柔軟", "精神"],
		"progress_threshold": 5
	}
	_skills_data["skill_004"] = skill4

# JSONファイルを保存する
func save_dummy_data_to_files() -> void:
	print("JSONファイルにダミーデータを保存しています...")
	_ensure_directory_exists("res://resources/data")
	
	_save_json_file("res://resources/data/horses.json", _horses_data.values())
	_save_json_file("res://resources/data/equipment.json", _equipment_data.values())
	_save_json_file("res://resources/data/skills.json", _skills_data.values())
	
	print("JSONファイルの保存が完了しました")

# ディレクトリが存在することを確認し、なければ作成
func _ensure_directory_exists(dir_path: String) -> void:
	var dir = DirAccess.open("res://")
	
	if not dir.dir_exists(dir_path):
		print("ディレクトリを作成します: ", dir_path)
		dir.make_dir_recursive(dir_path)

# JSONファイルを保存
func _save_json_file(file_path: String, data: Array) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(data, "  ")
		file.store_string(json_text)
		file.close()
		print("ファイル保存: ", file_path)
	else:
		print("エラー: ファイルを保存できませんでした: ", file_path)

# 指定されたIDのスキルデータを取得
func get_skill_data(skill_id: String) -> Dictionary:
	if _skills_data.has(skill_id):
		return _skills_data[skill_id]
	else:
		print("警告: スキルデータが見つかりません: ", skill_id)
		return {}

# データファイルの存在確認
func _check_data_files_exist() -> bool:
	var file_access = FileAccess.open("res://resources/data/horses.json", FileAccess.READ)
	var horses_exist = file_access != null
	if file_access:
		file_access.close()
		
	file_access = FileAccess.open("res://resources/data/equipment.json", FileAccess.READ)
	var equipment_exist = file_access != null
	if file_access:
		file_access.close()
		
	file_access = FileAccess.open("res://resources/data/skills.json", FileAccess.READ)
	var skills_exist = file_access != null
	if file_access:
		file_access.close()
	
	return horses_exist && equipment_exist && skills_exist 