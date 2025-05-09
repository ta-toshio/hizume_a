extends Control

# ボタン参照
@onready var start_button = $VBoxContainer/StartButton
@onready var skill_button = $VBoxContainer/SkillButton
@onready var records_button = $VBoxContainer/RecordsButton
@onready var exit_button = $VBoxContainer/ExitButton

func _ready():
	# ボタンシグナル接続
	start_button.pressed.connect(_on_start_button_pressed)
	skill_button.pressed.connect(_on_skill_button_pressed)
	records_button.pressed.connect(_on_records_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# 最初はデータが無いため、一部ボタンを無効化
	_update_button_states()

# ボタン状態の更新
func _update_button_states():
	# ここでは仮実装。後でデータの有無によって判定
	skill_button.disabled = true
	records_button.disabled = true

# 育成開始ボタン
func _on_start_button_pressed():
	print("育成開始ボタンが押されました")
	# 馬選択画面へ遷移
	get_tree().change_scene_to_file("res://scenes/screens/horse_select_screen.tscn")

# スキル図鑑ボタン
func _on_skill_button_pressed():
	print("スキル図鑑ボタンが押されました")
	# スキル図鑑画面へ遷移（未実装）
	# get_tree().change_scene_to_file("res://scenes/screens/skill_book_screen.tscn")

# 育成記録ボタン
func _on_records_button_pressed():
	print("育成記録ボタンが押されました")
	# 育成記録画面へ遷移（未実装）
	# get_tree().change_scene_to_file("res://scenes/screens/training_records_screen.tscn")

# 終了ボタン
func _on_exit_button_pressed():
	print("終了ボタンが押されました")
	get_tree().quit() 