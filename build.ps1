# Build the report. Every generated file (aux, log, bbl, minted cache, PDF) goes to build/.
#
#   .\build.ps1          full build: pdflatex -> biber -> pdflatex x2  => build/main.pdf
#   .\build.ps1 quick    one pdflatex pass (text edits only, no new citations/references)
#   .\build.ps1 clean    delete build/
param([ValidateSet('full', 'quick', 'clean')] [string]$Mode = 'full')

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$Out = 'build'

if ($Mode -eq 'clean') {
    if (Test-Path $Out) { Remove-Item -Recurse -Force $Out }
    Write-Host "Removed $Out/"
    exit 0
}

# \include{section/...} writes build/section/*.aux, and pdflatex does not create folders.
New-Item -ItemType Directory -Force "$Out/section" | Out-Null
# minted v3 reads the output folder from this variable.
$env:TEXMF_OUTPUT_DIRECTORY = $Out

function Invoke-Step([string]$Exe, [string[]]$Arguments) {
    & $Exe @Arguments | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "$Exe failed (exit $LASTEXITCODE). First errors in $Out/main.log:" -ForegroundColor Red
        Select-String -Path "$Out/main.log" -Pattern '^!' -Context 0, 2 | Select-Object -First 5 | ForEach-Object { $_.ToString() }
        exit $LASTEXITCODE
    }
}

$Latex = @('-shell-escape', '-synctex=1', '-interaction=nonstopmode', '-file-line-error', "-output-directory=$Out", 'main.tex')

Invoke-Step 'pdflatex' $Latex
if ($Mode -eq 'full') {
    Invoke-Step 'biber' @("--input-directory=$Out", "--output-directory=$Out", 'main')
    Invoke-Step 'pdflatex' $Latex
    Invoke-Step 'pdflatex' $Latex
}
Write-Host "OK: $Out/main.pdf" -ForegroundColor Green
