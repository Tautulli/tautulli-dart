#!/usr/bin/env python3
"""Extract and diff Tautulli's API command surface at a release tag.

    python3 tool/api_surface.py v2.18.1              # list commands (one per line)
    python3 tool/api_surface.py v2.17.2 v2.18.1      # diff two tags
    python3 tool/api_surface.py v2.18.1 --map        # command -> handler function

Commands come from two places: the @addtoapi decorator in plexpy/webserve.py and
the public methods of the API2 class in plexpy/api2.py.

Read the handler through --map, never by grepping `def <command>`. 18 of the 123
commands at v2.18.1 are registered under a name that differs from their function,
and for `get_stream_data` and `pms_image_proxy` an unrelated function with the
bare command name also exists — grepping finds the wrong one silently.

Validated at v2.18.1: output is byte-identical to the command list a live server
returns, both in test/fixtures/api/docs.json and in the "Possible commands are:"
message of test/fixtures/errors/unknown_command.json (123 each).
"""

import ast
import sys
import urllib.error
import urllib.request

RAW = "https://raw.githubusercontent.com/Tautulli/Tautulli/{}/plexpy/{}"


def _fetch(tag, name):
    try:
        with urllib.request.urlopen(RAW.format(tag, name), timeout=60) as response:
            return response.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as error:
        # A bare "2.19.0" 404s just like a moved file would; say which it is.
        sys.exit(f"{tag}/plexpy/{name}: HTTP {error.code} — tags are vX.Y.Z, with the leading v")


def surface(tag):
    """Return {command_name: handler_function_name} for a tag."""
    commands = {}

    for node in ast.walk(ast.parse(_fetch(tag, "webserve.py"))):
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue
        for decorator in node.decorator_list:
            # Bare @addtoapi: the command is the function name.
            if isinstance(decorator, ast.Name) and decorator.id == "addtoapi":
                commands[node.name] = node.name
            # @addtoapi("a", "b"): each argument is an alias for this function.
            elif (
                isinstance(decorator, ast.Call)
                and getattr(decorator.func, "id", "") == "addtoapi"
            ):
                aliases = [
                    a.value for a in decorator.args if isinstance(a, ast.Constant)
                ]
                for alias in aliases or [node.name]:
                    commands[alias] = node.name

    for node in ast.walk(ast.parse(_fetch(tag, "api2.py"))):
        if isinstance(node, ast.ClassDef) and node.name == "API2":
            for member in node.body:
                if isinstance(member, ast.FunctionDef) and not member.name.startswith(
                    "_"
                ):
                    commands[member.name] = "API2." + member.name

    return commands


def main(argv):
    if not argv:
        sys.exit(__doc__)

    old = surface(argv[0])

    if len(argv) > 1 and argv[1] == "--map":
        for command in sorted(old):
            handler = old[command]
            # API2 methods are always named for their command; only a webserve
            # handler can carry a name that differs from the registered command.
            aliased = handler != command and not handler.startswith("API2.")
            print(f"{command} -> {handler}{'  <-- alias' if aliased else ''}")
    elif len(argv) > 1:
        new = surface(argv[1])
        for command in sorted(set(new) - set(old)):
            print(f"ADDED    {command}")
        for command in sorted(set(old) - set(new)):
            print(f"REMOVED  {command}")
        print(f"# {argv[0]}: {len(old)} -> {argv[1]}: {len(new)}", file=sys.stderr)
        return
    else:
        for command in sorted(old):
            print(command)

    print(f"# {len(old)} commands at {argv[0]}", file=sys.stderr)


if __name__ == "__main__":
    main(sys.argv[1:])
