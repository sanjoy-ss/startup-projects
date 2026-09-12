"""Alogyan Discovery Engine CLI. Run: uv run main.py <command>"""
import argparse
import asyncio
import json
import logging
import certifi
from motor.motor_asyncio import AsyncIOMotorClient
from discovery.config import Settings
from discovery.indexes import ensure_indexes_async
from discovery.storage.repository import AsyncRepository
from discovery.fetcher.router import SourceRouter
from discovery.pipeline import (
    run_generate_queries_stage,
    run_crawl_frontier_stage,
    run_parse_snapshots_stage,
    run_resolve_and_score_stage,
    run_full_pipeline_async
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Alogyan Discovery Engine CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("init-db", help="Initialize MongoDB collections, validators, and indexes")
    subparsers.add_parser("check-config", help="Validate environment settings and API keys")

    gen_p = subparsers.add_parser("generate-queries", help="Generate search and maps queries into URL frontier")
    gen_p.add_argument("--city", default="Agartala")
    gen_p.add_argument("--state", default="Tripura")

    crawl_p = subparsers.add_parser("crawl-frontier", help="Crawl queued frontier URLs with Source Router")
    crawl_p.add_argument("--batch", type=int, default=50)

    parse_p = subparsers.add_parser("parse-snapshots", help="Parse raw HTML snapshots (deterministic + LLM)")
    parse_p.add_argument("--batch", type=int, default=50)

    score_p = subparsers.add_parser("resolve-and-score", help="Resolve deduplication and compute lead scores")
    score_p.add_argument("--batch", type=int, default=50)

    all_p = subparsers.add_parser("run-all", help="Run the full end-to-end automated discovery loop")
    all_p.add_argument("--batch", type=int, default=100)
    all_p.add_argument("--city", default="Agartala")
    all_p.add_argument("--state", default="Tripura")

    return parser


async def run_async_cli(args, settings: Settings):
    uri = settings.mongodb_uri.get_secret_value()
    client = AsyncIOMotorClient(
        uri,
        tlsCAFile=certifi.where(),
        serverSelectionTimeoutMS=10000
    )
    db = client[settings.mongodb_database]
    repo = AsyncRepository(db)
    router = SourceRouter(user_agent=settings.user_agent, crawl_delay=settings.crawl_delay)

    try:
        if args.command == "init-db":
            await ensure_indexes_async(db)
            print(json.dumps({"database": settings.mongodb_database, "status": "initialized", "indexes": "ensured"}))

        elif args.command == "generate-queries":
            res = await run_generate_queries_stage(repo, city=args.city, state=args.state)
            print(json.dumps(res, indent=2))

        elif args.command == "crawl-frontier":
            res = await run_crawl_frontier_stage(repo, router, batch_limit=args.batch)
            print(json.dumps(res, indent=2))

        elif args.command == "parse-snapshots":
            llm_key = settings.embedding_key.get_secret_value() if hasattr(settings, 'embedding_key') else ""
            res = await run_parse_snapshots_stage(repo, batch_limit=args.batch, llm_key=llm_key)
            print(json.dumps(res, indent=2))

        elif args.command == "resolve-and-score":
            res = await run_resolve_and_score_stage(repo, batch_limit=args.batch)
            print(json.dumps(res, indent=2))

        elif args.command == "run-all":
            llm_key = settings.embedding_key.get_secret_value() if hasattr(settings, 'embedding_key') else ""
            res = await run_full_pipeline_async(
                repo, router, batch_limit=args.batch, llm_key=llm_key, city=args.city, state=args.state
            )
            print(json.dumps(res, indent=2))

    finally:
        client.close()


def main():
    parser = build_parser()
    args = parser.parse_args()

    settings = Settings()
    if args.command == "check-config":
        print(json.dumps({"configuration": "valid", "database": settings.mongodb_database}))
        return 0

    asyncio.run(run_async_cli(args, settings))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
