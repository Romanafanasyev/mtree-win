# mtree (Windows)

![Release](https://img.shields.io/github/v/release/Romanafanasyev/mtree-win?sort=semver) ![License](https://img.shields.io/github/license/Romanafanasyev/mtree-win) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)

Clean directory tree for Windows. Folders by default, common junk ignored. No dependencies. Works in PowerShell, cmd, and Git Bash.

## Install
PowerShell, user scope, one line:
```powershell
iwr -useb https://raw.githubusercontent.com/Romanafanasyev/mtree-win/main/install.ps1 | iex
```

## Quickstart
```bash
mtree            # tree of folders
mtree -f         # folders + files
mtree D:\work    # specific path
```

## Options
- -f, --files  include files
- -h, --help   show help
- Default ignore: node_modules, .git, .github, .idea, .vscode, __pycache__, .mypy_cache, .pytest_cache, .cache, .venv, venv, env, dist, build, out, coverage, .next, .nuxt, target, .gradle

## Why not built-in tree
- Cleaner defaults out of the box
- Readable output
- Cross-shell: PowerShell, cmd, Git Bash

## Requirements
- Windows 10 or later
- PowerShell 5.1 or PowerShell 7+

## Uninstall
```powershell
Remove-Item "$env:USERPROFILE\bin\mtree.ps1","$env:USERPROFILE\bin\mtree.cmd","$env:USERPROFILE\bin\mtree" -ErrorAction SilentlyContinue
```

## Versioning
- SemVer
- Output format and CLI flags stay stable within the same major version

## License
MIT. See LICENSE.
