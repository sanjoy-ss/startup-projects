#!/usr/bin/env bash
# Run interactively as the unprivileged Linux account that will own the cron job.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$(uname -s)" != Linux ]; then
  echo 'This installer targets your Linux server.' >&2
  exit 1
fi
command -v crontab >/dev/null || { echo 'Install and enable the cron service first.' >&2; exit 1; }
python3 -c 'import sys; assert sys.version_info >= (3, 10), "Python 3.10+ is required"'
if [ ! -x .venv/bin/python ]; then
  python3 -m venv .venv
fi
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python deploy/configure_env.py
.venv/bin/python main.py check-config
# Create/validate the Atlas collections and indexes before enabling the scheduler.
.venv/bin/python main.py init-db
.venv/bin/python deploy/install_cron.py --install
echo 'Setup complete. Import your approved sources with: .venv/bin/python main.py import-sources sources.json'
