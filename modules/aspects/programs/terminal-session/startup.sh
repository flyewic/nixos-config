#!/usr/bin/env bash
handoff="$HOME/.cache/ghostty-herdr-handoff"
rm -f "$handoff"
zellij attach --create main
if [ -e "$handoff" ]; then
    rm -f "$handoff"
    exec herdr
fi
