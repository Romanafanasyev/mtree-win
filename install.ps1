# Installs mtree to %USERPROFILE%\bin and ensures PATH. Works in PowerShell 5.1+.
$ErrorActionPreference = 'Stop'
$bin = Join-Path $env:USERPROFILE 'bin'
New-Item -ItemType Directory -Force -Path $bin | Out-Null

$base = 'https://raw.githubusercontent.com/Romanafanasyev/mtree-win/main'
Invoke-WebRequest -UseBasicParsing -Uri "$base/mtree.ps1"                  -OutFile "$bin\mtree.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "$base/wrappers/mtree.cmd"         -OutFile "$bin\mtree.cmd"
Invoke-WebRequest -UseBasicParsing -Uri "$base/wrappers/mtree"             -OutFile "$bin\mtree"

# Making bash-wrapper executable
try { & bash -lc "chmod +x /c/Users/$env:USERNAME/bin/mtree" } catch {}

# Add %USERPROFILE%\bin to PATH (user scope)
$u = [Environment]::GetEnvironmentVariable('Path','User')
if (-not $u.Split(';') -contains $bin) {
  [Environment]::SetEnvironmentVariable('Path', ($u.TrimEnd(';') + ';' + $bin), 'User')
  Write-Output "PATH updated. Restart terminal."
}

Write-Output "mtree installed. Try: mtree -h"
