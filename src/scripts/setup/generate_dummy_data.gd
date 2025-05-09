extends Node

func _ready():
	print("ダミーデータ生成を開始します...")
	
	# リソースフォルダを確認
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("resources"):
		dir.make_dir("resources")
	
	if not dir.dir_exists("resources/data"):
		dir.make_dir("resources/data")
	
	# DataLoaderへの参照を取得
	var data_loader = get_node("/root/DataLoader")
	if data_loader:
		# ダミーデータを生成
		data_loader.generate_dummy_data()
		data_loader.save_dummy_data_to_files()
		
		print("ダミーデータの生成が完了しました！")
	else:
		print("エラー: DataLoaderノードが見つかりません。")
	
	# 少し待ってからアプリケーションを終了
	await get_tree().create_timer(2.0).timeout
	get_tree().quit() 