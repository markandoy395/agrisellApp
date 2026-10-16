param(
    [ValidateSet('appbundle', 'apk', 'size')]
    [string]$Artifact = 'appbundle',
    [string]$SymbolsDirectory = 'build/symbols'
)

$ErrorActionPreference = 'Stop'
$projectDirectory = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectDirectory
try {
    $buildArguments = @('build')
    if ($Artifact -eq 'size') {
        $buildArguments += @('apk', '--target-platform=android-arm64', '--analyze-size')
    } elseif ($Artifact -eq 'apk') {
        $buildArguments += @('apk', '--split-per-abi')
    } else {
        $buildArguments += 'appbundle'
    }
    $buildArguments += @('--release', '--tree-shake-icons')
    if ($Artifact -ne 'size') {
        $buildArguments += "--split-debug-info=$SymbolsDirectory"
    }
    & flutter @buildArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter release build failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}
