# Neovim Daily Cheat Sheet

## Git Diff Shortcuts (delta)
- `gd` -> opens `git diff` in a terminal buffer (uses your git pager, `delta`).
- `gdm` -> opens `git diff <base>...HEAD` where base is first found of:
  - `main`
  - `master`
  - `origin/main`
  - `origin/master`

## Window Jumping (Arrows + j/k)
- Arrow keys switch windows in normal/insert/terminal modes:
  - `<Left>` -> left window
  - `<Down>` -> lower window
  - `<Up>` -> upper window
  - `<Right>` -> right window
- `Ctrl-w h/j/k/l` also switches windows (left/down/up/right).
- `Ctrl-w j` and `Ctrl-w k` are the `j/k` way to move down/up windows.
- In terminal mode, arrows auto-exit terminal insert and jump windows.

## File Tree + Editor Flow
- `<leader>e` toggles Neo-tree.
- In Neo-tree, use `j/k` to move up/down the file list.
- Use `<Right>` to jump from tree to editor window.

## Search
- `<leader>ff` -> find files.
- `ss` -> literal live grep in current working directory.

## Terminal
- `tt` -> toggle floating terminal.
- `<Esc>` in terminal -> leave terminal insert mode.

## Leader Keys
- Leader: `<Space>`
- Local leader: `,`

## Daily Dev Reminder
- Shell aliases (like `gst`) live in bash/zsh, not Neovim keymaps.
- Neovim keymaps must call plugin commands or terminal commands directly.

