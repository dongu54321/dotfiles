#!/bin/bash
sudo apt install tmux -y
### tmux 3 panel alias
echo "alias tmuxx='tmux new-session \; split-window -h \; split-window -v \; attach'" >> ~/.bash_aliases

mkdir -p ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "
setw -g mouse on
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @yank_selection_mouse 'clipboard'
run '~/.tmux/plugins/tpm/tpm'
" >> ~/.tmux.conf


# view key: CTRL+b ?
# Ctrl+b D — Detach from the current session.
# Ctrl+b % — Split the window into two panes horizontally.
# Ctrl+b " — Split the window into two panes vertically.
# Ctrl+b Arrow Key (Left, Right, Up, Down) — Move between panes.
# Ctrl+b X — Close pane.
# Ctrl+b C — Create a new window.
# Ctrl+b N or P — Move to the next or previous window.
# Ctrl+b 0 (1,2...) — Move to a specific window by number.
# Ctrl+b : — Enter the command line to type commands. Tab completion is available.
# Ctrl+b ? — View all keybindings. Press Q to exit.
# Ctrl+b W — Open a panel to navigate across windows in multiple sessions.