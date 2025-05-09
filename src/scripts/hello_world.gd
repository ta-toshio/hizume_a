extends Control

func _ready():
	# 画面にHello Worldを表示するラベルを作成
	var label = Label.new()
	label.text = "Hello World!"
	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.anchor_right = 0.5
	label.anchor_bottom = 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# フォントサイズを大きくする
	var font = label.get_theme_font("font")
	label.add_theme_font_size_override("font_size", 48)
	
	# ラベルを中央に配置
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	# シーンにラベルを追加
	add_child(label)
	
	print("Hello World! スクリプトが実行されました。") 