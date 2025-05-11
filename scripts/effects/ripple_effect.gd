extends ColorRect

# シェーダーパラメータへの参照
var shader_material: ShaderMaterial
var animation_player: AnimationPlayer
var tween: Tween = null

# カテゴリーに応じた色の定義
const CATEGORY_COLORS = {
	"速力": Color(0.12, 0.56, 1.0, 1.0),  # 青
	"柔軟": Color(0.24, 0.7, 0.44, 1.0),  # 緑
	"精神": Color(0.58, 0.44, 0.86, 1.0),  # 紫
	"技術": Color(1.0, 0.55, 0.0, 1.0),   # 橙
	"展開": Color(0.44, 0.5, 0.56, 1.0),  # 灰青
	"持久": Color(0.8, 0.36, 0.36, 1.0)   # 赤
}

# 初期化
func _ready():
	# シェーダーマテリアルの設定
	shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://resources/shaders/ripple_effect.gdshader")
	material = shader_material
	
	# デフォルト設定
	size = Vector2(400, 400)  # サイズ設定
	color = Color(0, 0, 0, 0)  # 透明背景
	
	# AnimationPlayerの作成と設定
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	
	# フェードアウトアニメーションの作成
	_create_fade_animation()

# 波紋エフェクトの再生
func play_ripple(category: String = "", duration: float = 1.5):
	# カテゴリーに応じた色の設定
	var ripple_color = CATEGORY_COLORS.get(category, Color(0.5, 0.3, 0.9, 1.0))
	shader_material.set_shader_parameter("ripple_color", ripple_color)
	
	# アニメーション再生
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/ripple_strength", 0.5, 0.2)
	tween.tween_property(shader_material, "shader_parameter/max_radius", 0.9, duration)
	tween.parallel().tween_property(shader_material, "shader_parameter/ripple_strength", 0.0, duration)
	
	# 終了後に非表示にする
	tween.tween_callback(func(): 
		visible = false
		shader_material.set_shader_parameter("max_radius", 0.1)
	)
	
	# 表示と再生開始
	visible = true

# フェードアウトアニメーションの作成
func _create_fade_animation():
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":material:shader_parameter/ripple_strength")
	
	# キーフレーム設定
	animation.track_insert_key(track_index, 0.0, 0.5)  # 開始時の強度
	animation.track_insert_key(track_index, 1.0, 0.0)  # 終了時は0
	
	animation.length = 1.0  # アニメーション長さ
	animation.loop_mode = Animation.LOOP_NONE  # ループなし
	
	# AnimationPlayerに追加 (Godot 4.x用に修正)
	var library = AnimationLibrary.new()
	library.add_animation("fade_out", animation)
	animation_player.add_animation_library("default", library)

# 外部から呼び出せるメソッド（即時再生）
func show_ripple_effect(position: Vector2, category: String = "", duration: float = 1.5):
	# 位置設定
	var parent_rect_size = get_parent().size if get_parent() is Control else Vector2(1152, 648)
	
	# 中心位置の計算（UV座標系に変換、0-1の範囲）
	var uv_position = Vector2(
		position.x / parent_rect_size.x,
		position.y / parent_rect_size.y
	)
	
	shader_material.set_shader_parameter("center", uv_position)
	play_ripple(category, duration) 
