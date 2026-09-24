Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$output = Join-Path $root "lumen-ai-page-summarizer.zip"
$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("lumen-extension-" + [guid]::NewGuid().ToString("N"))

$files = @(
    "manifest.json",
    "background.js",
    "popup.html",
    "popup.css",
    "popup.js",
    "privacy.html"
)

$directories = @("icons")

try {
    New-Item -ItemType Directory -Path $staging -Force | Out-Null

    foreach ($file in $files) {
        $source = Join-Path $root $file
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Required file is missing: $file"
        }
        Copy-Item -LiteralPath $source -Destination (Join-Path $staging $file)
    }

    foreach ($directory in $directories) {
        $source = Join-Path $root $directory
        if (-not (Test-Path -LiteralPath $source -PathType Container)) {
            throw "Required directory is missing: $directory"
        }
        Copy-Item -LiteralPath $source -Destination (Join-Path $staging $directory) -Recurse
    }

    Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $output -Force

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($output)
    try {
        $forbiddenEntries = @(
            $archive.Entries | Where-Object {
                $_.FullName -match '(^|[\\/])(text|\.env(?:\..*)?|README\.md|STORE_LISTING\.md)$'
            }
        )
        if ($forbiddenEntries.Count -gt 0) {
            throw "A forbidden local or documentation file was included in the archive."
        }
    }
    finally {
        $archive.Dispose()
    }

    Write-Host "Created $output"
    Write-Host "Only runtime files were included; local secrets and documentation were excluded."
}
finally {
    if (Test-Path -LiteralPath $staging) {
        Remove-Item -LiteralPath $staging -Recurse -Force
    }
}
