# **📝 ChatDiary: Neovimで完結するチャットログ管理ツール**

## **概要**

ChatDiaryは、Neovim (nvim) の専用バッファでチャットAIとの会話ログを作成・管理するためのユーティリティ群です。会話内容をシームレスにログファイルに記録し、AIの返答をログの構造を崩さずに貼り付けることができます。

このツールは、AIとの会話を構造化されたMarkdown形式で日々記録し、知識ベースを構築することを目指しています。

## **必要なツール**

このプロジェクトは、以下のツールに依存します。

1. **Neovim (v0.8.0以降)**  
2. **Bash** (シェルスクリプト実行環境)  
3. **クリップボードツール**: スクリプトがクリップボードの内容を読み込むために必要です。  
   * **macOS**: 標準の pbpaste / pbcopy を使用。  
   * **Linux (X11)**: xclip または xsel が必要です（推奨は xclip）。

## **導入手順**

### **1\. プロジェクトのクローンと配置**

リポジトリを任意の場所にクローンします。

git clone \[あなたのリポジトリURL\] \~/projects/ChatDiary  
cd \~/projects/ChatDiary

### **2\. PATHへの登録**

シェルスクリプトをどこからでも実行できるように、chat\_manager\_send.sh, format\_response\_code.sh, shift\_markdown\_headers.sh, chatdiary\_start.sh をPATHの通ったディレクトリ（例: \~/bin/）にシンボリックリンクとして登録します。

\# 例: \~/bin/ に登録する場合  
ln \-s \~/projects/ChatDiary/chat\_manager\_send.sh \~/bin/  
ln \-s \~/projects/ChatDiary/shift\_markdown\_headers.sh \~/bin/  
ln \-s \~/projects/ChatDiary/chatdiary\_start.sh \~/bin/  
\# format\_response\_code.sh は現在は shift\_markdown\_headers.sh で代用可能

### **3\. Neovim設定 (Lua) の組み込み**

init.lua や、適切な設定ファイルから chatdiary.lua を読み込みます。

\-- init.lua, after loading your plugin manager  
require('chatdiary')

## **📜 使い方**

### **起動**

以下のコマンドでログファイルと入力バッファが分割された状態でNeovimが起動します。

chatdiary\_start.sh

### **💡 主要コマンド**

| コマンド | キーマッピング (例) | 説明 |
| :---- | :---- | :---- |
| :ChatDiarySend | \<leader\>gc | 入力バッファの内容をログファイルに記録し、クリップボードにコピーします。その後、入力バッファをクリアし、ログパネルを :checktime で自動更新します。 |
| :ChatDiaryShiftPaste | \<leader\>gs | **AIの返答をログに貼り付けるための専用コマンド**です。システムクリップボードから内容を読み込み、**見出しレベルを2つシフト**して、現在のカーソル位置に直接貼り付けます。 |

### **ChatDiaryShiftPaste の重要性**

chat\_log.md の返答コンテナは \#\#\# 返答内容（Response） です。AIの返答に含まれる見出し（通常 \#\# や \#\#\#）をそのまま貼り付けると構造が崩れるため、このコマンドは全ての見出しを2段階シフト（例: \#\# → \#\#\#\#）することで、ログのMarkdown構造を保ちます。

## **🚧 今後の課題**

* **ログの自動整理:** ログファイル (chat\_log.md) に溜まったログブロックを、$HOME/Diary の日付ファイルに自動で追記し、処理済みのログを安全に削除する機能の実装。