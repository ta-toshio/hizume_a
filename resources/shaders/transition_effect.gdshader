shader_type canvas_item;

// トランジションパラメータ
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int transition_type : hint_range(0, 3) = 0; // 0=フェード, 1=サークル, 2=ワイプ, 3=ズーム
uniform vec4 transition_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float smoothness : hint_range(0.0, 1.0) = 0.1;

// フェード効果
float fade_effect(vec2 uv) {
    return progress;
}

// サークル効果
float circle_effect(vec2 uv) {
    float dist = distance(uv, vec2(0.5, 0.5));
    float circle_size = 0.5 * progress;
    return smoothstep(circle_size - smoothness, circle_size + smoothness, dist);
}

// ワイプ効果
float wipe_effect(vec2 uv) {
    return smoothstep(progress - smoothness, progress + smoothness, uv.x);
}

// ズーム効果
float zoom_effect(vec2 uv) {
    float dist = distance(uv, vec2(0.5, 0.5));
    return smoothstep(progress - smoothness, progress + smoothness, dist * 2.0);
}

// フラグメントシェーダー
void fragment() {
    // 元のテクスチャをサンプリング
    vec4 original = texture(TEXTURE, UV);
    
    // エフェクトタイプ別に透明度を計算
    float alpha = 0.0;
    if (transition_type == 0) {
        alpha = fade_effect(UV);
    } else if (transition_type == 1) {
        alpha = circle_effect(UV);
    } else if (transition_type == 2) {
        alpha = wipe_effect(UV);
    } else if (transition_type == 3) {
        alpha = zoom_effect(UV);
    }
    
    // 遷移色と元の色をブレンド
    vec4 transitioned = mix(original, transition_color, alpha);
    
    // 最終出力
    COLOR = transitioned;
} 