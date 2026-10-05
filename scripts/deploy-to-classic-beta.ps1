# Deploy ElvUI Forever into the live classic_beta AddOns folder.
# Source: this repo root (ElvUI, ElvUI_Libraries, ElvUI_Options)
# Target: D:\Battle.net\World of Warcraft\_classic_beta_\Interface\AddOns

$ErrorActionPreference = 'Stop'
$srcRoot = Split-Path $PSScriptRoot -Parent
$addonsDst = 'D:\Battle.net\World of Warcraft\_classic_beta_\Interface\AddOns'

if (-not (Test-Path -LiteralPath $addonsDst)) {
  throw "Forever AddOns folder missing: $addonsDst"
}

$names = @('ElvUI', 'ElvUI_Libraries', 'ElvUI_Options')
foreach ($name in $names) {
  $from = Join-Path $srcRoot $name
  $to = Join-Path $addonsDst $name
  if (-not (Test-Path -LiteralPath $from)) { throw "Missing source: $from" }
  if (Test-Path -LiteralPath $to) {
    Write-Host "Removing old $to"
    Remove-Item -LiteralPath $to -Recurse -Force
  }
  Write-Host "Copying $name -> $to"
  Copy-Item -LiteralPath $from -Destination $to -Recurse -Force
}

Write-Host 'Done. Restart WowB or /reload after enabling addons.'
