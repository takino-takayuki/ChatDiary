#!/bin/bash

# --- 設定 ---
# ログファイルを保存するディレクトリ。必要に応じて変更してください。
CHAT_DIR="$HOME/ChatDiary"
# ログファイル名
CHAT_LOG_FILE="$CHAT_DIR/chat_log.md"
# 一時ファイル名 (プロセスIDとタイムスタンプでユニーク化)
TEMP_LOG_FILE="$CHAT_DIR/temp_log_$$_$(date +%s).md"
# --- 設定ここまで ---

# 1. ディレクトリが存在しない場合は作成
mkdir -p "$CHAT_DIR"

# 2. 標準入力（パイプ）からチャット文章を読み込む
# nvimから渡されるのは、エスケープされていない生のバッファ内容です。
CHAT_CONTENT=$(cat -)

# 内容が空の場合は終了
if [ -z "$CHAT_CONTENT" ]; then
    echo "Error: No content received. Exiting." >&2
    exit 1
fi

# 3. クリップボードへのコピー
# OSを判定し、適切なクリップボードコマンドを使用
CLIPBOARD_CMD=""

if command -v pbcopy &> /dev/null; then
    # macOS
    CLIPBOARD_CMD="pbcopy"
elif command -v xclip &> /dev/null; then
    # Linux (X11) - xclip がインストールされている場合
    # -selection clipboard でシステムクリップボードに格納
    CLIPBOARD_CMD="xclip -selection clipboard"
else
    # その他の環境（xclipやpbcopyがない場合）は警告
    echo "Warning: Clipboard tool (pbcopy/xclip) not found. Content was not copied." >&2
fi

if [ -n "$CLIPBOARD_CMD" ]; then
    # CHAT_CONTENTを変数としてパイプでコマンドに渡す
    echo "$CHAT_CONTENT" | $CLIPBOARD_CMD
fi

# 4. ログ用コンテンツの整形 (Markdown形式)
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')

# ヒアドキュメントで複数行のMarkdownブロックを構築
# CHAT_CONTENTはダブルクォーテーションで囲まれているため、複数行を保持します
LOG_BLOCK=$(cat <<EOF
## 💬 [$TIMESTAMP]
### 送信内容（User Prompt）
$CHAT_CONTENT


---
### 返答内容（Response）


---

EOF
)

# 5. ログファイルの先頭への追記（プリペンド）

# 5-1. 追記したい内容を一時ファイルに書き出す
echo "$LOG_BLOCK" > "$TEMP_LOG_FILE"

# 5-2. 既存のログファイルが存在する場合、その内容を一時ファイルの後ろに結合する
# これにより、TEMP_LOG_FILEが「新規内容 + 既存内容」の順になる
if [ -f "$CHAT_LOG_FILE" ]; then
    cat "$CHAT_LOG_FILE" >> "$TEMP_LOG_FILE"
fi

# 5-3. 一時ファイルの内容を正式なログファイルに上書き（移動）する
mv "$TEMP_LOG_FILE" "$CHAT_LOG_FILE"

# 6. 終了
# デバッグコード: 成功メッセージを標準出力に出力する (Neovimから確認可能)
# echo "Chat content successfully logged to $CHAT_LOG_FILE and copied to clipboard."
exit 0
