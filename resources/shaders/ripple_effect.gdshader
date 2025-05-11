shader_type canvas_item;

// 波紋の設定用パラメータ
uniform vec4 ripple_color : source_color = vec4(0.5, 0.3, 0.9, 1.0); // 紫色（既定値）
uniform float ripple_width : hint_range(0.0, 1.0) = 0.1; // 波紋の幅
uniform float ripple_speed : hint_range(0.1, 5.0) = 1.0; // 波紋の広がる速度
uniform float ripple_strength : hint_range(0.0, 1.0) = 0.5; // 波紋の強さ
uniform vec2 center = vec2(0.5, 0.5); // 波紋の中心（UV座標系、デフォルトは中央）
uniform float max_radius : hint_range(0.0, 2.0) = 0.9; // 波紋の最大半径
uniform float fade_edge : hint_range(0.0, 0.5) = 0.1; // 端のフェード量

// フラグメントシェーダー
void fragment() {
    // UV座標から中心までの距離を計算
    float dist = distance(UV, center);
    
    // 時間とともに広がる波紋の半径（0.0～max_radius）
    float current_radius = mod(TIME * ripple_speed, max_radius);
    
    // 波紋のマスク計算（幅ripple_widthの同心円）
    float ring_mask = 1.0 - smoothstep(current_radius - ripple_width, current_radius, dist);
    ring_mask *= smoothstep(current_radius - ripple_width * 2.0, current_radius - ripple_width, dist);
    
    // 外側へのフェードアウト
    float edge_fade = 1.0 - smoothstep(max_radius - fade_edge, max_radius, dist);
    
    // 最終的な波紋の強度
    float final_strength = ring_mask * ripple_strength * edge_fade;
    
    // 元のテクスチャとブレンド
    vec4 original = texture(TEXTURE, UV);
    vec4 ripple = ripple_color;
    ripple.a *= final_strength;
    
    // 加算合成
    COLOR = original + ripple;
} 