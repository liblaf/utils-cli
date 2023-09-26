import json
import subprocess
from collections.abc import Iterable, Sequence
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path
from subprocess import CompletedProcess
from typing import Annotated

import typer


def repo_list() -> Iterable[str]:
    process: CompletedProcess = subprocess.run(
        args=[
            "gh",
            "repo",
            "list",
            "--json=nameWithOwner",
            "--limit=1000",
            "--no-archived",
            "--source",
        ],
        capture_output=True,
        check=True,
    )
    return map(lambda repo: repo["nameWithOwner"], json.loads(process.stdout))


def clone(repo: str, prefix: Path) -> None:
    if (prefix / repo / ".git").is_dir():
        return
    subprocess.run(
        args=[
            "gh",
            "repo",
            "clone",
            repo,
            prefix / repo,
            "--",
            "--recurse-submodules",
            "--remote-submodules",
        ]
    )


def main(
    *,
    prefix: Annotated[
        Path,
        typer.Option(
            "-p",
            "--prefix",
            exists=False,
            file_okay=False,
            dir_okay=True,
            writable=True,
            readable=False,
        ),
    ] = Path.home()
    / "github"
) -> None:
    with ProcessPoolExecutor() as executor:
        repos: Sequence[str] = list(repo_list())
        list(executor.map(clone, repos, [prefix] * len(repos)))
