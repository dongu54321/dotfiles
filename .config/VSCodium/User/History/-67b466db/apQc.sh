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


# view key: CTRL+a ?
    # Ctrl+A D — Detach from the current session.
    # Ctrl+A % — Split the window into two panes horizontally.
    # Ctrl+A " — Split the window into two panes vertically.
    # Ctrl+A Arrow Key (Left, Right, Up, Down) — Move between panes.
    # Ctrl+A X — Close pane.
    # Ctrl+A C — Create a new window.
    # Ctrl+A N or P — Move to the next or previous window.
    # Ctrl+A 0 (1,2...) — Move to a specific window by number.
    # Ctrl+A : — Enter the command line to type commands. Tab completion is available.
    # Ctrl+A ? — View all keybindings. Press Q to exit.
    # Ctrl+A W — Open a panel to navigate across windows in multiple sessions.










