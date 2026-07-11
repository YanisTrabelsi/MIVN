$ErrorActionPreference = "Stop"

$Repo   = "YanisTrabelsi/MIVN"
$Branch = "main"
$Target = Join-Path $env:LOCALAPPDATA "nvim"
$TmpDir = Join-Path $env:TEMP ("mivn_" + [System.Guid]::NewGuid().ToString())

New-Item -ItemType Directory -Path $TmpDir | Out-Null

try {
    $ArchivePath = Join-Path $TmpDir "mivn.zip"
    $ZipUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"

    Write-Host "==> Downloading MIVN ($Branch)..."
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ArchivePath

    Write-Host "==> Extracting..."
    Expand-Archive -Path $ArchivePath -DestinationPath $TmpDir -Force

    $ExtractedFolder = Join-Path $TmpDir "MIVN-$Branch"

    if (Test-Path $Target) {
        $Backup = "$Target.bak." + (Get-Date -Format "yyyyMMddHHmmss")
        Write-Host "==> Existing config found, backing it up to $Backup"
        Move-Item -Path $Target -Destination $Backup
    }

    New-Item -ItemType Directory -Path (Split-Path $Target -Parent) -Force | Out-Null
    Move-Item -Path $ExtractedFolder -Destination $Target

    Write-Host "==> MIVN installed to $Target"
    Write-Host "==> Launch 'nvim' to let lazy.nvim install the plugins."
}
finally {
    Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
