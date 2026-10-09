#!/usr/bin/env sh
# Lightweight ping to ensure entrypoint script executes cleanly
/app/diagnostic.sh system >/dev/null 2>&1
exit $?