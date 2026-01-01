#!/usr/bin/env bash
name=$(whoami)
while true; do
	prefix_state=$(tmux display-message -p "#{client_prefix}")

	if [ "$prefix_state" = "1" ]; then
		echo "{\"text\": \"$name\", \"class\": \"active\"}"
	else
		echo "{\"text\": \"$name\", \"class\": \"inactive\"}"
	fi

	sleep 0.025
done
