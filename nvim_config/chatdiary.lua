-- nvimの設定ファイル (例: chatdiary.lua)

-- オプション設定: 外部からのファイル変更検知を有効にする (これは維持)
vim.opt.autoread = true

-- =======================================================
-- カスタムコマンドの定義（全処理を統合）
-- =======================================================
vim.api.nvim_create_user_command('ChatDiarySend', function()
    -- 1. バッファの内容全体を取得
    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

    -- 2. スクリプトの実行（ロギングとクリップボードコピー）
    os.execute(string.format('echo %s | chat_manager_send.sh', vim.fn.shellescape(content)))

    -- 3. 入力バッファをクリアし、メッセージを表示
    vim.cmd('enew | setlocal buftype=nofile bufhidden=wipe')
    vim.cmd('echo "📝 ChatDiary: Logged and copied! Paste in browser (Ctrl+V)."')

    -- 4. ログバッファの更新
    -- :checktime で開かれているすべてのバッファの外部変更をチェックし、
    -- 'autoread' により自動でログファイルを更新させる
    vim.cmd('checktime')
    
end, { nargs = 0 })

-- 便利なキーマッピングの例 (例: <leader>gc で実行)
vim.keymap.set('n', '<leader>gc', ':ChatDiarySend<CR>', { desc = 'Send Chat and Log to ChatDiary' })

-- =======================================================
-- カスタムコマンドの定義（自動貼り付け機能を実装）
-- =======================================================
vim.api.nvim_create_user_command('ChatDiaryFormat', function()
    -- 1. 外部スクリプトを実行し、結果をLua変数に取り込む
    -- nvimの `system()` 関数は、標準出力の内容を文字列として返します。
    local formatted_code = vim.fn.system('format_response_code.sh')

    -- 2. エラーチェックとクリップボードへの格納
    if vim.v.shell_error ~= 0 then
        -- スクリプト実行でエラーが発生した場合（例: クリップボードツールが見つからないなど）
        vim.cmd('echohl ErrorMsg | echo "🚨 ChatDiaryFormat: Script execution failed (Check terminal output)." | echohl None')
        return
    end

    -- 3. 整形結果を現在のバッファのカーソル位置に挿入
    -- 整形結果をレジスタに設定し、`p` (貼り付け) コマンドで挿入します。

    -- レジスタ a に整形結果を設定 (最後に改行がある場合、文字単位の貼り付けになるように注意)
    vim.fn.setreg('a', formatted_code) 

    -- ノーマルモードで "ap（レジスタaの内容を貼り付け）"を実行
    vim.cmd('normal! "ap') 
    
    -- 4. メッセージ表示
    vim.cmd('echo "✅ Code formatted and pasted at cursor position."')

end, { nargs = 0 })

-- 便利なキーマッピングの例 (例: <leader>gf で実行)
vim.keymap.set('n', '<leader>gf', ':ChatDiaryFormat<CR>', { desc = 'Format Code and Paste' })


vim.api.nvim_create_user_command('ChatDiaryShiftPaste', function()
    -- 1. クリップボードの内容を取得
    local clipboard_content = vim.fn.system('pbpaste') -- macOSの例。xclipを使う場合は修正が必要。

    -- 2. Markdownヘッダーシフトスクリプトを実行し、結果を取得
    -- (Shift_markdown_headers.shがPATHに通っていることを前提とする)
    local shifted_content = vim.fn.system('echo ' .. vim.fn.shellescape(clipboard_content) .. ' | shift_markdown_headers.sh')

    -- 3. エラーチェック (省略)

    -- 4. 整形結果を現在のバッファのカーソル位置に挿入
    vim.fn.setreg('a', shifted_content) 
    vim.cmd('normal! "ap') 
    
    -- 5. メッセージ表示
    vim.cmd('echo "✅ Response headers shifted and pasted."')

end, { nargs = 0 })

-- 便利なキーマッピングの例 (例: <leader>gs で実行)
vim.keymap.set('n', '<leader>gs', ':ChatDiaryShiftPaste<CR>', { desc = 'Shift Markdown Headers and Paste' })
