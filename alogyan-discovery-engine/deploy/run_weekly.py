#!/usr/bin/env python3
"""POSIX host-local cron lock, usable on macOS and Linux without a flock binary."""
import fcntl
import logging
from logging.handlers import RotatingFileHandler
import os
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))


def run():
    os.chdir(ROOT)
    os.umask(0o077)
    logs = ROOT / 'logs'
    logs.mkdir(exist_ok=True)
    logger = logging.getLogger('discovery.cron')
    logger.setLevel(logging.INFO)
    handler = RotatingFileHandler(logs / 'weekly.log', maxBytes=2_000_000, backupCount=5)
    handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s %(message)s'))
    logger.addHandler(handler)
    with (ROOT / '.weekly.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            logger.info('Skipped overlapping run')
            return 0
        from main import main
        sys.argv = [str(ROOT / 'main.py'), 'weekly']
        logger.info('Starting discovery batch')
        try:
            import contextlib
            import io
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                result = main()
            if output.getvalue().strip():
                logger.info('Batch result: %s', output.getvalue().strip())
        except Exception as exc:
            logger.error('Batch failed: %s', type(exc).__name__)
            return 1
        logger.info('Batch finished with exit code %s', result)
        return result


if __name__ == '__main__':
    raise SystemExit(run())
