#!/bin/bash
# Prevent editing on main branch
# [ "$(git branch --show-current 2>/dev/null)" != "main" ] || {
# 	echo '{"block": true, "message": "Cannot edit files on main branch. Create a feature branch first."}' >&2
# 	exit 2
# }
