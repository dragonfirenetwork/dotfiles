#!/bin/bash

# Check if tmux server is running and dev session exists
if tmux list-sessions 2>/dev/null | grep -q "^dev:"; then
    # If dev session exists, attach to it
    tmux attach-session -t dev
else
    # If no dev session exists, create it using the config file and attach
    tmux new-session -d -s dev
    tmux source-file ~/.config/tmux/dev.conf
    tmux attach-session -t dev
fi
