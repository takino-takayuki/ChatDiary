#!/bin/bash

# --- 1. クリップボードからの読み込み設定 ---

# OSを判定し、適切なクリップボード読み込みコマンドを設定
PASTE_CMD=""

if command -v pbpaste &> /dev/null; then
    # macOS
    PASTE_CMD="pbpaste"
elif command -v xclip &> /dev/null; then
    # Linux (X11) - xclip がインストールされている場合
    # -o (out) でクリップボードの内容を出力
    PASTE_CMD="xclip -selection clipboard -o"
else
    # ツールが見つからない場合は、エラーメッセージを出力して終了
    echo "Error: Clipboard tool (pbpaste/xclip) not found. Cannot read content." >&2
    exit 1
fi

# 2. クリップボードからコード本文を取得
# ツールが設定されていれば、そのコマンドでクリップボードの内容を取得
CODE_BODY=$($PASTE_CMD)

# 内容が空の場合は終了
if [ -z "$CODE_BODY" ]; then
    exit 0
fi

# --- 3. Markdown整形処理 ---

# コードブロック全体を構築 (トリプルバッククォートと言語名なしのコードを結合)
# ヒアドキュメント内のトリプルバッククォートは、そのままの文字として出力されます。
OUTPUT_BLOCK=$(cat <<EOF
\`\`\`
${CODE_BODY}
\`\`\`
EOF
)

# 4. sedを使って、構築したブロックの全ての行の先頭に2スペースを挿入して出力
echo "$OUTPUT_BLOCK" | sed 's/^/  /'
