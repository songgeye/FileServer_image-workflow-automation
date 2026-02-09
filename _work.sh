#!/bin/zsh

# ==========================================
# 設定エリア
# ==========================================
SERVER_ROOT="/Volumes/Job4D"
SERVER_DONE_DIR="${SERVER_ROOT}/--済--"
LOCAL_WORK_DIR="/Users/mac/Desktop/_登録作業用/*"
PS_APP_NAME="Adobe Photoshop 2025"
PS_ACTION_SET="画像登録_変換"
PS_ACTION_NAME="ExtendScript"

# ==========================================
# 1. フォルダ検索
# ==========================================

if [ -z "$1" ]; then
    echo "❌ エラー: フォルダ番号（検索ワード）を指定してください。"
    echo "使用例: work 252908"
    exit 1
fi

TARGET_KEYWORD="$1" 

# サーバー接続確認
if [ ! -d "$SERVER_ROOT" ]; then
    echo "❌ サーバーが見つかりません。"
    exit 1
fi

echo "🔍 サーバー内を検索中... ('$TARGET_KEYWORD')"

# 全階層検索
FOUND_PATH=$(find "$SERVER_ROOT" -type d -name "*${TARGET_KEYWORD}*" | sort | tail -n 1)

if [ -z "$FOUND_PATH" ]; then
    echo "❌ フォルダが見つかりませんでした: $TARGET_KEYWORD"
    exit 1
fi

# 見つかったフォルダの名前
ORIGINAL_NAME=$(basename "$FOUND_PATH")

# 直上の親フォルダの名前を取得
PARENT_PATH=$(dirname "$FOUND_PATH")
PARENT_NAME=$(basename "$PARENT_PATH")

echo "✅ 発見: $FOUND_PATH"

# ==========================================
# 2. 自動抽出（日付・依頼者名）
# ==========================================

TODAY=$(date +%y%m%d)

# 依頼者名の抽出（親フォルダ名から）
if [[ "$PARENT_NAME" == *-* ]]; then
    REQUESTER="${PARENT_NAME#*-}"
else
    REQUESTER="$PARENT_NAME"
fi

# スペース削除
REQUESTER=${REQUESTER// /}
REQUESTER=${REQUESTER//　/}

# スペースなし・アンダーバーなし・ハイフンなしで連結
NEW_DIR_NAME="${TODAY}${REQUESTER}${ORIGINAL_NAME}"

LOCAL_TARGET_PATH="${LOCAL_WORK_DIR}/${NEW_DIR_NAME}"

echo "=========================================="
echo "📁 元フォルダ: $ORIGINAL_NAME"
echo "⬆️  親フォルダ: $PARENT_NAME"
echo "👤 抽出依頼者: $REQUESTER"
echo "🆕 作成名:     $NEW_DIR_NAME"
echo "=========================================="

# ==========================================
# 3. コピー & 移動 (リネーム移動)
# ==========================================

if [ -z "$1" ]; then
    echo "❌ エラー: フォルダ番号（検索ワード）を指定してください。"
    echo "使用例: work 252908"
    exit 1
fi

TARGET_KEYWORD="$1" 

if [ ! -d "$SERVER_ROOT" ]; then
    echo "❌ サーバーが見つかりません。"
    exit 1
fi

echo "🔍 サーバー内を検索中... ('$TARGET_KEYWORD')"

FOUND_PATH=$(find "$SERVER_ROOT" -type d -name "*${TARGET_KEYWORD}*" | sort | tail -n 1)

if [ -z "$FOUND_PATH" ]; then
    echo "❌ フォルダが見つかりませんでした: $TARGET_KEYWORD"
    exit 1
fi

ORIGINAL_NAME=$(basename "$FOUND_PATH")
PARENT_PATH=$(dirname "$FOUND_PATH")
PARENT_NAME=$(basename "$PARENT_PATH")

echo "✅ 発見: $FOUND_PATH"

# ==========================================
# 2. 自動抽出（日付・依頼者名）
# ==========================================

TODAY=$(date +%y%m%d)

# ★修正箇所: ハイフン(-) または アンダーバー(_) のどちらかがあれば、その後ろを取得
if [[ "$PARENT_NAME" == *[-_]* ]]; then
    # 「最初の区切り文字」より右側を抽出
    # 例: ma_松ヶ野 -> 松ヶ野
    # 例: 0204-松ヶ野 -> 松ヶ野
    REQUESTER="${PARENT_NAME#*[-_]}"
else
    # どちらもない場合は親フォルダ名をそのまま使う
    REQUESTER="$PARENT_NAME"
fi

# スペース削除
REQUESTER=${REQUESTER// /}
REQUESTER=${REQUESTER//　/}

# 連結
NEW_DIR_NAME="${TODAY}${REQUESTER}${ORIGINAL_NAME}"
LOCAL_TARGET_PATH="${LOCAL_WORK_DIR}/${NEW_DIR_NAME}"

echo "=========================================="
echo "📁 元フォルダ: $ORIGINAL_NAME"
echo "⬆️  親フォルダ: $PARENT_NAME"
echo "👤 抽出依頼者: $REQUESTER"
echo "🆕 作成名:     $NEW_DIR_NAME"
echo "=========================================="

# ==========================================
# 3. コピー & 移動
# ==========================================

echo "📂 ローカルへコピー中..."
cp -R "$FOUND_PATH" "$LOCAL_TARGET_PATH"

if [ $? -ne 0 ]; then
    echo "❌ コピー失敗。終了します。"
    exit 1
fi

echo "🚚 サーバーフォルダを【--済--】へ移動中..."

SERVER_DEST_PATH="${SERVER_DONE_DIR}/${NEW_DIR_NAME}"
if [ -d "$SERVER_DEST_PATH" ]; then
    SERVER_DEST_PATH="${SERVER_DEST_PATH}_dup"
fi

mv "$FOUND_PATH" "$SERVER_DEST_PATH"

if [ $? -ne 0 ]; then
    echo "❌ 移動に失敗しました。"
    exit 1
fi

echo "   → 移動完了"

# ==========================================
# 4. 不可視ファイル削除 (Photoshopエラー対策)
# ==========================================
# cho "🧹 不可視ファイル（._）をクリーニング中..."
# Photoshopが処理するローカルフォルダを掃除
# dot_clean -m "$LOCAL_TARGET_PATH"
