extends Node

# テーマリソースを作成して保存するスクリプト
# このスクリプトは一度だけ実行することを想定しています

func _ready():
	print("デフォルトテーマを作成しています...")
	
	# 新しいテーマを作成
	var theme = Theme.new()
	
	# フォントサイズ階層を定義（役割ごとに統一したサイズ）
	var font_sizes = {
		"small": 24,       # 補足情報、ステータス値など
		"normal": 32,      # 通常テキスト、リスト項目など
		"medium": 40,      # サブタイトル、重要ボタンなど
		"large": 48,       # 画面タイトル、主要ヘッダーなど
		"extra_large": 64  # メインタイトルなど
	}
	
	# デフォルトフォントサイズを設定
	theme.set_default_font_size(font_sizes.normal)
	
	# 共通コントロールのフォントサイズを設定
	theme.set_font_size("font_size", "Label", font_sizes.normal)
	theme.set_font_size("font_size", "Button", font_sizes.normal)
	theme.set_font_size("font_size", "LineEdit", font_sizes.normal)
	theme.set_font_size("font_size", "OptionButton", font_sizes.normal)
	theme.set_font_size("font_size", "ItemList", font_sizes.normal)
	
	# 特別なフォントサイズを設定
	theme.set_font_size("font_size_small", "Label", font_sizes.small)
	theme.set_font_size("font_size_medium", "Label", font_sizes.medium)
	theme.set_font_size("font_size_large", "Label", font_sizes.large)
	theme.set_font_size("font_size_xl", "Label", font_sizes.extra_large)
	
	# ヘッダー用
	theme.set_font_size("title_font_size", "Label", font_sizes.large)
	theme.set_font_size("header_font_size", "Label", font_sizes.medium)
	
	# UI要素の統一サイズを設定
	theme.set_font_size("normal_font_size", "Button", font_sizes.normal)
	theme.set_font_size("large_font_size", "Button", font_sizes.medium)
	
	# ボタンの最小サイズを設定
	theme.set_constant("minimum_size", "Button", 60)
	
	# マージンなどの定数を調整してタッチ操作に適したサイズに
	theme.set_constant("margin_left", "MarginContainer", 40)
	theme.set_constant("margin_top", "MarginContainer", 40)
	theme.set_constant("margin_right", "MarginContainer", 40)
	theme.set_constant("margin_bottom", "MarginContainer", 40)
	
	# グリッドなどの間隔も広げる
	theme.set_constant("h_separation", "GridContainer", 20)
	theme.set_constant("v_separation", "GridContainer", 20)
	theme.set_constant("separation", "VBoxContainer", 20)
	theme.set_constant("separation", "HBoxContainer", 20)
	
	# テーマを保存
	var err = ResourceSaver.save(theme, "res://assets/themes/default_theme.tres")
	if err == OK:
		print("デフォルトテーマを保存しました: res://assets/themes/default_theme.tres")
	else:
		print("エラー: テーマの保存に失敗しました") 