---
title: "スキル図鑑／育成記録UI仕様書"
free: false
---

## 📚 スキル図鑑／育成記録UI仕様書

---

### ✅ 1. スキル図鑑 UI

#### 概要

育成中および過去に獲得・開花したスキルを一覧表示し、効果や習得条件を振り返ることができる辞典的UI。

#### 表示構成

| エリア      | 内容                            |
| -------- | ----------------------------- |
| 左側カテゴリ一覧 | タグ（速力系／精神系など）で分類されたフィルター表示    |
| 中央スキル一覧  | アイコン＋スキル名＋ランク（ノーマル／レア／奥義）＋獲得数 |
| 右側詳細表示欄  | 選択中スキルの効果／発動条件／開花条件／獲得装備などを表示 |

#### アイコン状態

| 状態     | 表示            |
| ------ | ------------- |
| 未開花    | グレーアイコン＋ロック表示 |
| 一度開花済み | カラー表示＋チェックマーク |
| 複数回開花  | 数値バッジ表示（例：×3） |

#### 補助要素

* ソート切替（名前順／タグ別／獲得回数）
* フィルター（未獲得のみ表示／奥義のみ表示など）

---

### ✅ 2. 育成記録 UI

#### 概要

周回終了時に育てた馬・成長したステ・開花スキルなどの育成結果を記録・閲覧できる画面。

#### 表示構成

| エリア     | 内容                            |
| ------- | ----------------------------- |
| 左側履歴一覧  | 育成周回ごとの履歴（馬名／評価／レース結果）をリストで表示 |
| 右側詳細パネル | 以下をタブ形式で表示：                   |

* ステータス成長グラフ（12種の推移）
* 開花スキル一覧（発動区間／発動ログ付き）
* トレーニング履歴（カテゴリ使用回数／熟度推移）
* 使用装備と熟度最終値

#### 評価ランク表示

* S／A／B／Cランク（スコアに応じて）
* ゴールド・シルバーなどの演出枠で区別

#### 操作補助

* お気に入り育成記録にスター付与
* 育成メモ（50字程度の自由記述）機能

---

この仕様により、プレイヤーが自らの育成体験を“成果”として記録・振り返ることで、次の周回へのモチベーションやスキル収集欲求を継続的に刺激できるUI体験が提供されます。