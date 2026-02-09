# FileServer_image-workflow-automation
社内サーバーからの画像フォルダ検索、リネーム、アーカイブ移動、Photoshopによる画像処理、およびWeb登録画面の立ち上げを一括で自動化するツールセットです。

## 🚀 機能 (Features)

このツールは、以下の定型業務をコマンド一発で実行します：

1.  **検索 & 取得**: ファイルサーバー（`/Volumes/Job4D`）内の膨大なフォルダから、指定した番号やキーワードでフォルダを検索。
2.  **スマートリネーム**: 親フォルダ名から依頼者名を自動抽出し、「`YYMMDD` + `依頼者名` + `元フォルダ名`」の形式にリネーム。
3.  **アーカイブ移動**: サーバー上の元フォルダを「`--済--`」フォルダへ移動（重複時は自動でサフィックス付与）。
4.  **クリーンアップ**: Mac特有の隠しファイル（`._*`）を自動除去し、Photoshopの「不特定のオブジェクト」エラーを回避。
5.  **画像処理**: Photoshopを起動し、リサイズ・CMYK変換・保存処理を実行（ExtendScript連携）。
6.  **登録準備**: Google Chromeで画像登録システムとMALL管理画面を自動で開く。

## 📦 動作環境 (Requirements)

* **OS**: macOS (zsh)
* **Application**: Adobe Photoshop 2025, Google Chrome
* **Network**: ファイルサーバー (`/Volumes/Job4D`) がマウントされていること

## 🛠 インストール & セットアップ

### 1. スクリプトの配置
リポジトリ内の `_work.sh` を任意の場所に配置します（例: `~/Downloads/_work.sh`）。

### 2. 実行権限の付与
ターミナルで以下のコマンドを実行し、スクリプトに実行権限を与えます。

```bash
chmod +x ~/Downloads/_work.sh
```

### 3. Photoshopスクリプトの準備
同梱の `ExtendScript.jsx` をPhotoshopのアクションとして登録します。

* **アクションセット名**: `画像登録_変換`
* **アクション名**: `ExtendScript`

※ `_work.sh` 内の設定と一致させる必要があります。

### 4. エイリアスの設定（推奨）
どこからでも `work` コマンドで呼び出せるように、`.zshrc` にエイリアスを追加します。

```bash
echo "alias work='/Users/mac/Downloads/_work.sh'" >> ~/.zshrc
source ~/.zshrc
```

## 💻 使い方 (Usage)

ターミナルで `work` コマンドの後に、処理したいフォルダ番号（またはキーワード）を入力するだけです。

```bash
work 252908
```

実行すると、検索〜画像処理〜ブラウザ起動まで全自動で進行します。

## ⚙️ 設定 (Configuration)

`_work.sh` ファイル冒頭の変数を環境に合わせて変更してください。

| 変数名 | 説明 | デフォルト値 |
| :--- | :--- | :--- |
| `SERVER_ROOT` | 検索対象のサーバーパス | `/Volumes/Job4D` |
| `LOCAL_WORK_DIR` | 作業用ローカルフォルダ | `~/Desktop/_登録作業用` |
| `PS_APP_NAME` | Photoshopのアプリ名 | `Adobe Photoshop 2025` |
| `PS_ACTION_SET` | アクションセット名 | `画像登録_変換` |

## 💡 便利なコマンド (Tips)

作業の最後に、ダウンロードしたCSVを確認する際によく使うコマンドです。
**Downloadsフォルダにある「一番新しいCSVファイル」を即座に開きます。**

```bash
ls -t ~/Downloads/*.csv | head -n 1 | xargs open
```

### コマンド解説

* `ls -t ~/Downloads/*.csv`: ダウンロードフォルダ内のCSVファイルを**更新日時が新しい順**に並べ替えてリストアップ。
* `head -n 1`: リストの一番上（つまり**最新の1つ**）だけを取り出す。
* `xargs open`: 取り出したファイル名を `open` コマンドに渡し、関連付けられたアプリ（Excel等）で開く。

## ⚠️ トラブルシューティング

* **Photoshopで「ファイルを開く」ダイアログが出る**
    * Photoshop側のスクリプト（JSX）に `app.open()` や `Folder.selectDialog()` が含まれていないか確認してください。シェルスクリプト連携時は `app.activeDocument` を対象にする必要があります。
* **サーバーが見つからない**
    * Finderでサーバーがマウントされているか確認してください。
