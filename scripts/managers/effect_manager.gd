extends Node

# シングルトン設定
static var _instance = null
static func get_instance():
	return _instance

# エフェクトのプリロード
var ripple_effect_scene = preload("res://scenes/effects/ripple_effect.tscn")
var screen_transition_scene = preload("res://scenes/effects/screen_transition.tscn")

# エフェクトコンテナ参照
var effect_container: Control = null

# サウンド効果
const SOUND_EFFECTS = {
	"共鳴": "res://assets/sounds/resonance.ogg",
	"開花": "res://assets/sounds/skill_bloom.ogg",
	"スキル発動": "res://assets/sounds/skill_activate.ogg",
	"決定": "res://assets/sounds/select.ogg",
	"成長": "res://assets/sounds/growth.ogg"
}

# 初期化
func _init():
	_instance = self

# 画面が読み込まれたときにコンテナを設定
func setup_effect_container(container: Control):
	effect_container = container

# 波紋エフェクトの表示
func show_ripple(position: Vector2, category: String = "", duration: float = 1.5):
	if effect_container == null:
		printerr("エフェクトコンテナが設定されていません")
		return
		
	# 既存のエフェクトを検索
	var existing_effect = _find_existing_effect("RippleEffect")
	var ripple_effect
	
	if existing_effect:
		ripple_effect = existing_effect
	else:
		# 新しくインスタンス化
		ripple_effect = ripple_effect_scene.instantiate()
		effect_container.add_child(ripple_effect)
	
	# エフェクト再生
	ripple_effect.show_ripple_effect(position, category, duration)
	
	# 共鳴音を再生（音声ファイルがある場合）
	play_sound("共鳴")

# チャクラ共鳴エフェクト
func show_resonance_effect(position: Vector2, category: String):
	show_ripple(position, category, 2.0)
	
	# ログメッセージ表示（将来的な実装）
	# show_message("チャクラが震えた...", Color(0.58, 0.44, 0.86))

# スキル開花エフェクト
func show_skill_bloom_effect(position: Vector2, skill_name: String, category: String):
	show_ripple(position, category, 2.5)
	
	# ポップアップメッセージ表示
	show_skill_name_popup(skill_name, position, category)
	
	# 開花音を再生
	play_sound("開花")

# スキル名ポップアップ表示
func show_skill_name_popup(skill_name: String, position: Vector2, category: String = ""):
	if effect_container == null:
		return
		
	# ポップアップラベル作成
	var popup_label = Label.new()
	effect_container.add_child(popup_label)
	
	# スタイル設定
	popup_label.text = skill_name + " 開花！"
	popup_label.add_theme_font_size_override("font_size", 32)
	
	# カテゴリーに応じた色設定
	var color_map = {
		"速力": Color(0.12, 0.56, 1.0),
		"柔軟": Color(0.24, 0.7, 0.44),
		"精神": Color(0.58, 0.44, 0.86),
		"技術": Color(1.0, 0.55, 0.0),
		"展開": Color(0.44, 0.5, 0.56),
		"持久": Color(0.8, 0.36, 0.36)
	}
	var text_color = color_map.get(category, Color(0.9, 0.9, 0.9))
	popup_label.add_theme_color_override("font_color", text_color)
	
	# 初期位置設定
	popup_label.position = position - Vector2(popup_label.size.x / 2, 50)
	
	# アニメーション作成
	var tween = create_tween()
	tween.tween_property(popup_label, "position:y", popup_label.position.y - 70, 1.0)
	tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(popup_label.queue_free)

# ステータス変化エフェクト
func show_stat_change(node: Control, value: int, is_positive: bool = true):
	if node == null:
		return
		
	# 変化量表示ラベル
	var change_label = Label.new()
	node.add_child(change_label)
	
	# テキストとスタイル設定
	var prefix = "+" if is_positive else ""
	change_label.text = prefix + str(value)
	change_label.add_theme_font_size_override("font_size", 16)
	
	# 色設定
	var color = Color(0.2, 0.8, 0.2) if is_positive else Color(0.8, 0.2, 0.2)
	change_label.add_theme_color_override("font_color", color)
	
	# 位置設定（親ノードの右上）
	change_label.position = Vector2(node.size.x + 5, 0)
	
	# アニメーション
	var tween = create_tween()
	tween.tween_property(change_label, "position:y", change_label.position.y - 20, 0.7)
	tween.parallel().tween_property(change_label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(change_label.queue_free)
	
	# 値変化時の音を再生
	play_sound("成長")

# 効果音再生
func play_sound(sound_key: String):
	# 音声ファイルがまだ実装されていない場合は、ログだけ出す
	if not SOUND_EFFECTS.has(sound_key) or not FileAccess.file_exists(SOUND_EFFECTS[sound_key]):
		print("効果音再生（仮）: " + sound_key)
		return
		
	# TODO: 効果音実装後に有効化
	# var audio_player = AudioStreamPlayer.new()
	# add_child(audio_player)
	# var stream = load(SOUND_EFFECTS[sound_key])
	# audio_player.stream = stream
	# audio_player.play()
	# await audio_player.finished
	# audio_player.queue_free()

# 既存のエフェクトを検索
func _find_existing_effect(effect_name: String):
	if effect_container == null:
		return null
		
	for child in effect_container.get_children():
		if child.name.begins_with(effect_name):
			return child
	
	return null

# 画面遷移エフェクト表示
func transition_to_scene(target_scene: String, transition_type: int = 0, duration: float = 0.7) -> void:
	print("DEBUG: 画面遷移開始: " + target_scene)
	
	if effect_container == null:
		print("ERROR: エフェクトコンテナが設定されていません。直接遷移します。")
		get_tree().change_scene_to_file(target_scene)
		return
	
	# トランジションエフェクトのインスタンス化
	var transition_effect = screen_transition_scene.instantiate()
	effect_container.add_child(transition_effect)
	
	# シェーダーマテリアルの取得
	var shader_material = transition_effect.material as ShaderMaterial
	
	# 初期設定
	shader_material.set_shader_parameter("progress", 0.0)
	shader_material.set_shader_parameter("transition_type", transition_type)
	
	# トランジションタイプに応じた色設定
	var color = Color(0, 0, 0, 1)  # デフォルトは黒
	
	match transition_type:
		0:  # フェード
			color = Color(0, 0, 0, 1)
		1:  # サークル
			color = Color(0, 0.1, 0.3, 1)
		2:  # ワイプ
			color = Color(0.1, 0, 0.2, 1)
		3:  # ズーム
			color = Color(0.2, 0.2, 0.2, 1)
	
	shader_material.set_shader_parameter("transition_color", color)
	
	# フェードインアニメーション
	var tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/progress", 1.0, duration)
	
	# アニメーション完了時の処理
	await tween.finished
	
	# シーン遷移
	get_tree().change_scene_to_file(target_scene)
	
	# 新しいシーンがロードされた後、トランジションエフェクトも破棄
	# 新しいシーンでは別のエフェクトコンテナが設定されるため 