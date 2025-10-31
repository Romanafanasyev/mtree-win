# encoding: UTF-8
[CmdletBinding()]
param(
  [Alias('f')][switch]$Files,
  [Alias('h')][switch]$Help,
  [Parameter(Position=0)][string]$Path = '.'
)

try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $true } catch {}

# Box drawing via Unicode code points
$ELBOW = [char]0x2514   # └
$TEE   = [char]0x251C   # ├
$PIPE  = [char]0x2502   # │
$HLINE = [char]0x2500   # ─

# Reasonable defaults: caches/builds/config clutter
$Ignored = @(
  'node_modules', '.git', '.github', '.idea', '.vscode',
  '__pycache__', '.mypy_cache', '.pytest_cache', '.cache',
  '.venv', 'venv', 'env',
  'dist', 'build', 'out', 'coverage',
  '.next', '.nuxt', 'target', '.gradle'
)

function Show-Help {
@'
mtree - print directory tree (folders only by default)

Usage:
  mtree [-f] [PATH]

Options:
  -f, --files   include files
  -h, --help    show this help

Ignored by default: node_modules, .git, .github, .idea, .vscode,
__pycache__, .mypy_cache, .pytest_cache, .cache, .venv, venv, env,
dist, build, out, coverage, .next, .nuxt, target, .gradle
'@ | Write-Output
}


if ($Help) { Show-Help; exit 0 }

# Resolve and validate target
$Target = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
if (-not $Target) { Write-Error "Path not found: $Path"; exit 1 }
$Target = $Target.Path
if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
  Write-Error "Expected a directory: $Target"; exit 1
}

function Get-Entries {
  param([string]$Dir, [bool]$IncludeFiles)
  try {
    $items = Get-ChildItem -LiteralPath $Dir -Force -ErrorAction Stop
  } catch {
    Write-Warning "[mtree] Access denied: $Dir ($($_.Exception.Message))"
    return [PSCustomObject]@{ Dirs=@(); Files=@() }
  }
  $dirs  = $items | Where-Object { $_.PSIsContainer -and ($Ignored -notcontains $_.Name) } | Sort-Object Name
  $files = if ($IncludeFiles) { $items | Where-Object { -not $_.PSIsContainer } | Sort-Object Name } else { @() }
  [PSCustomObject]@{ Dirs=$dirs; Files=$files }
}

function Write-Tree {
  param([string]$Dir, [bool]$IncludeFiles, [string]$Prefix = '')

  $r = Get-Entries -Dir $Dir -IncludeFiles:$IncludeFiles
  $children = @()
  $children += $r.Dirs
  if ($IncludeFiles) { $children += $r.Files }

  for ($i = 0; $i -lt $children.Count; $i++) {
    $entry = $children[$i]
    $isLast = ($i -eq $children.Count - 1)

    if ($isLast) { $connector = "$ELBOW$HLINE$HLINE " } else { $connector = "$TEE$HLINE$HLINE " }
    Write-Output ($Prefix + $connector + $entry.Name)

    if ($entry.PSIsContainer) {
      # Avoid infinite loops on reparse points
      if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }

      if ($isLast) { $nextPrefix = $Prefix + '    ' } else { $nextPrefix = $Prefix + "$PIPE   " }
      Write-Tree -Dir $entry.FullName -IncludeFiles:$IncludeFiles -Prefix $nextPrefix
    }
  }
}

$rootLabel = Split-Path -Leaf -Path $Target
if ([string]::IsNullOrEmpty($rootLabel)) { $rootLabel = $Target }
Write-Output $rootLabel
Write-Tree -Dir $Target -IncludeFiles:$Files
