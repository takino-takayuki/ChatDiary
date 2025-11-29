#!/bin/bash

# 標準入力からMarkdownコンテンツを読み込む
MARKDOWN_CONTENT=$(cat -)

# 内容が空の場合は終了
if [ -z "$MARKDOWN_CONTENT" ]; then
    exit 0
fi

# 1. sedを使って、行頭が「#」で始まる行に対して、行頭に「##」を追加する。
# H3 コンテナ（###）の下に H4 が来るようにするため、2つシフトします。
# sed -E '/^#/s/^/##/' の解説:
# - /^#/ : 行頭が # で始まる行のみを対象とする。
# - s/^/##/ : その行の行頭（^）を ## に置換（追記）する。
SHIFTED_CONTENT=$(echo "$MARKDOWN_CONTENT" | sed -E '/^#/s/^/##/')

# 2. 結果を標準出力に出力する
echo "$SHIFTED_CONTENT"
