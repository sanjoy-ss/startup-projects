from main import build_parser

def test_cli_parser_has_all_required_subcommands():
    parser = build_parser()
    # Find the SubParsersAction
    subparsers_action = None
    for action in parser._actions:
        if action.dest == "command":
            subparsers_action = action
            break
    assert subparsers_action is not None
    commands = subparsers_action.choices.keys()
    
    assert "init-db" in commands
    assert "generate-queries" in commands
    assert "crawl-frontier" in commands
    assert "parse-snapshots" in commands
    assert "resolve-and-score" in commands
    assert "run-all" in commands
