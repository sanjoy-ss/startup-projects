#!/usr/bin/env python3
"""Preview, install, or remove only the managed Alogyan cron entry."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import shlex
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
START = '# BEGIN ALOGYAN DISCOVERY'
END = '# END ALOGYAN DISCOVERY'


def schedule() -> str:
    # IST never changes. Validate both seasons so a DST host cannot drift silently.
    offsets = set()
    year = datetime.now().year
    for y in (year, year + 1):
        for month in range(1, 13):
            timestamp = datetime(y, month, 15, tzinfo=timezone.utc).timestamp()
            offsets.add(time.localtime(timestamp).tm_gmtoff)
    if offsets == {19800}:
        return '0 1 * * 2,6'
    if offsets == {0}:
        return '30 19 * * 1,5'  # Monday/Friday UTC = Tuesday/Saturday 01:00 IST.
    raise ValueError('Cron host must use Asia/Kolkata or UTC; configure the server timezone first')


def replace_block(existing: str, replacement: str = '') -> str:
    lines = existing.splitlines(keepends=True)
    output = []
    inside = False
    seen = False
    for line in lines:
        if line.rstrip('\r\n') == START:
            if inside or seen:
                raise ValueError('Malformed or duplicate managed cron block')
            inside = seen = True
        elif line.rstrip('\r\n') == END:
            if not inside:
                raise ValueError('Malformed managed cron block')
            inside = False
        elif not inside:
            output.append(line)
    if inside:
        raise ValueError('Unclosed managed cron block')
    text = ''.join(output)
    if replacement:
        text += ('' if not text or text.endswith('\n') else '\n') + replacement + '\n'
    return text


def block(root: Path, expression: str) -> str:
    if any(char in str(root) for char in ('%', '\n', '\r')):
        raise ValueError('Checkout path contains unsupported crontab characters')
    python = shlex.quote(str(root / '.venv/bin/python'))
    wrapper = shlex.quote(str(root / 'deploy/run_weekly.py'))
    return f'{START}\n# Tuesday and Saturday 01:00 Asia/Kolkata\n{expression} {python} {wrapper}\n{END}'


def read_crontab() -> str:
    result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
    if result.returncode == 0:
        return result.stdout
    if result.returncode == 1 and 'no crontab for' in result.stderr.lower():
        return ''
    raise RuntimeError('Cannot read crontab; existing entries have not been changed')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--install', action='store_true')
    mode.add_argument('--remove', action='store_true')
    args = parser.parse_args()
    new_block = '' if args.remove else block(ROOT, schedule())
    if not args.install and not args.remove:
        print(new_block)
        return 0
    if args.install:
        from discovery.config import Settings
        Settings(_env_file=ROOT / '.env')  # Reject incomplete config before changing cron.
        if not (ROOT / '.venv/bin/python').is_file():
            raise ValueError('Create the project Python environment first')
    old = read_crontab()
    if args.install and any(line.lstrip().startswith(('CRON_TZ=', 'CRON_TZ =')) for line in old.splitlines()):
        raise ValueError('Existing CRON_TZ override requires a manual timezone review')
    new = replace_block(old, new_block)
    if old == new:
        print('Cron is already up to date.')
        return 0
    # Preserve a private, uniquely named recovery copy before modifying OS configuration.
    import os
    import tempfile
    backups = ROOT / 'deploy/backups'
    backups.mkdir(exist_ok=True)
    descriptor, filename = tempfile.mkstemp(prefix='crontab-', suffix='.txt', dir=backups)
    with os.fdopen(descriptor, 'w') as backup:
        backup.write(old)
    subprocess.run(['crontab', '-'], input=new, text=True, check=True)
    if read_crontab() != new:
        raise RuntimeError('Cron verification failed; recovery copy retained')
    print('Managed cron entry removed.' if args.remove else 'Discovery scheduled: Tuesday/Saturday 01:00 IST.')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'Cron setup failed ({type(exc).__name__}): check configuration and cron access.', file=sys.stderr)
        raise SystemExit(1)
