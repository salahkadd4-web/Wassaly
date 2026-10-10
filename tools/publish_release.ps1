<#
Publie une nouvelle version de Wassaly sur GitHub Releases (voir PUBLIER_UNE_VERSION.md).

Utilisation (depuis n'importe quel dossier) :
    .\tools\publish_release.ps1 -Version 1.1.0 -Notes "Ce qui change"

Ce que fait le script :
  1. augmente le numero de build dans pubspec.yaml (le chiffre apres le +)
  2. lance flutter analyze et flutter test (sauf -SkipTests)
  3. construit l'APK de release, signe avec android\key.properties
  4. le renomme wassaly.apk
  5. commit + push du pubspec, puis cree la release vX.Y.Z avec gh

Pre-requis : Flutter, Git, GitHub CLI (gh auth login deja fait), android\key.properties.
Le lien du QR ne change pas : .../releases/latest/download/wassaly.apk
#>
param(
    [Parameter(Mandatory = $true)][string]$Version,
    [string]$Notes = "Mise a jour de Wassaly",
    [string]$Repo = "salahkadd4-web/wassaly",
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

function Run([string]$cmd) {
    Write-Host ">> $cmd" -ForegroundColor Cyan
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) { throw "Echec : $cmd" }
}

if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    throw "Version invalide '$Version' (format attendu : 1.1.0)"
}
if (-not (Test-Path "android\key.properties")) {
    throw "android\key.properties introuvable : l'APK ne serait pas signe avec la bonne cle."
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) introuvable : https://cli.github.com/"
}

# 1. Nouvelle version dans pubspec.yaml
$pubspec = Get-Content pubspec.yaml -Raw
if ($pubspec -notmatch '(?m)^version:\s*\d+\.\d+\.\d+\+(\d+)\s*$') {
    throw "Ligne 'version:' introuvable dans pubspec.yaml"
}
$build = [int]$Matches[1] + 1
$pubspec = [regex]::Replace($pubspec, '(?m)^version:.*$', "version: $Version+$build")
Set-Content pubspec.yaml $pubspec -NoNewline
Write-Host "Version : $Version+$build" -ForegroundColor Green

# 2. Verifications
Run "flutter pub get"
Run "flutter analyze"
if (-not $SkipTests) { Run "flutter test" }

# 3-4. APK signe, renomme
Run "flutter build apk --release"
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "wassaly.apk" -Force

# 5. Git + release
Run "git add pubspec.yaml"
Run "git commit -m `"Version $Version`""
Run "git push"
Run "gh release create v$Version wassaly.apk --repo $Repo --title `"Wassaly $Version`" --notes `"$Notes`" --latest"

Write-Host ""
Write-Host "Release publiee : https://github.com/$Repo/releases/tag/v$Version" -ForegroundColor Green
Write-Host "Lien du QR      : https://github.com/$Repo/releases/latest/download/wassaly.apk"
Write-Host "Testez le lien, installez par-dessus l'ancienne version, puis prevenez les utilisateurs."
