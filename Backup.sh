#!/usr/bin/env bash
set -euo pipefail
TS="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE="/tmp/gitea-backup-${TS}.tar.gz"
tar -czf ${ARCHIVE} -C /home/ubuntu/data .
echo "Created backup archive: ${ARCHIVE}"
