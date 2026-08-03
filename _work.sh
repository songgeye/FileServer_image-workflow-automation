#!/bin/zsh

# ==========================================
# 設定エリア
# ==========================================
SERVER_ROOT="/Volumes/Job4D"
SERVER_DONE_DIR="${SERVER_ROOT}/--済--"
# ★ `*` という名前のフォルダを指す場合はそのまま指定（ダブルクォート内で安全に処理されます）
LOCAL_WORK_DIR="/Users/mac/Desktop/_登録作業用/*"
PS_APP_NAME="Adobe Photoshop 2025"
PS_ACTION_SET="画像登録_変換"
PS_ACTION_NAME="ExtendScript"

# 検索の深さ制限（必要に応じて調整）
SEARCH_MAX_DEPTH=5

# ==========================================
# 1. パラメータ＆接続チェック
# ==========================================

if [ -z "$1" ]; then
    echo "❌ エラー: フォルダ番号（検索ワード）を指定してください。"
    echo "使用例: work 252908"
    exit 1
fi

TARGET_KEYWORD="$1" 

if [ ! -d "$SERVER_ROOT" ]; then
    echo "❌ サーバーが見つかりません。マウント状態を確認してください。"
    exit 1
fi

# ==========================================
# 2. フォルダ検索（高速化対応）
# ==========================================

echo "🔍 サーバー内を検索中... ('$TARGET_KEYWORD')"

# --済-- や隠しディレクトリを除外して高速検索
FOUND_PATH=$(find "$SERVER_ROOT" -maxdepth "$SEARCH_MAX_DEPTH" \
    \( -name "--済--" -o -name ".*" \) -prune -o \
    -type d -name "*${TARGET_KEYWORD}*" -print 2>/dev/null | sort | tail -n 1)

if [ -z "$FOUND_PATH" ]; then
    echo "❌ フォルダが見つかりませんでした: $TARGET_KEYWORD"
    exit 1
fi

ORIGINAL_NAME=$(basename "$FOUND_PATH")
PARENT_PATH=$(dirname "$FOUND_PATH")
PARENT_NAME=$(basename "$PARENT_PATH")

echo "✅ 発見: $FOUND_PATH"

# ==========================================
# 3. 自動抽出（日付・依頼者名）
# ==========================================

TODAY=$(date +%y%m%d)

# ハイフン(-) または アンダーバー(_) の後ろを取得
if [[ "$PARENT_NAME" == *[-_]* ]]; then
    REQUESTER="${PARENT_NAME#*[-_]}"
else
    REQUESTER="$PARENT_NAME"
fi

# スペース除去（半角・全角）
REQUESTER=${REQUESTER// /}
REQUESTER=${REQUESTER// /}

# 新規フォルダ名
NEW_DIR_NAME="${TODAY}${REQUESTER}${ORIGINAL_NAME}"

# ★ `*` フォルダの中に作成するため、パス指定を文字列として正しく連結
LOCAL_TARGET_PATH="${LOCAL_WORK_DIR}/${NEW_DIR_NAME}"

echo "=========================================="
echo "📁 元フォルダ: $ORIGINAL_NAME"
echo "⬆️  親フォルダ: $PARENT_NAME"
echo "👤 抽出依頼者: $REQUESTER"
echo "🆕 作成名:     $NEW_DIR_NAME"
echo "=========================================="

# ==========================================
# 4. コピー & 移動
# ==========================================

# 受け皿となる `*` フォルダが存在するか確認・無ければ作成
if [ ! -d "$LOCAL_WORK_DIR" ]; then
    mkdir -p "$LOCAL_WORK_DIR"
fi

echo "📂 ローカルへコピー中..."
cp -R "$FOUND_PATH" "$LOCAL_TARGET_PATH"

if [ $? -ne 0 ]; then
    echo "❌ コピー失敗。終了します。"
    exit 1
fi

echo "🚚 サーバーフォルダを【--済--】へ移動中..."

# 移動先フォルダ作成チェック
if [ ! -d "$SERVER_DONE_DIR" ]; then
    mkdir -p "$SERVER_DONE_DIR"
fi

SERVER_DEST_PATH="${SERVER_DONE_DIR}/${NEW_DIR_NAME}"
if [ -d "$SERVER_DEST_PATH" ]; then
    SERVER_DEST_PATH="${SERVER_DEST_PATH}_dup"
fi

mv "$FOUND_PATH" "$SERVER_DEST_PATH"

if [ $? -ne 0 ]; then
    echo "❌ 移動に失敗しました。"
    exit 1
fi

echo "✨ 移動完了"
