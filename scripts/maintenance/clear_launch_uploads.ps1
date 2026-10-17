param([Parameter(Mandatory = $true)][string]$BackupDirectory)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Security
$root = (Resolve-Path '.').Path
$target = [IO.Path]::GetFullPath((Join-Path $root $BackupDirectory))
$allowed = [IO.Path]::GetFullPath((Join-Path $root 'supabase/.temp')) + [IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($allowed, [StringComparison]::OrdinalIgnoreCase)) {
  throw 'Backup path is outside the reviewed backup directory.'
}
$summary = Get-Content (Join-Path $target 'summary.json') -Raw | ConvertFrom-Json
$marker = Get-Content (Join-Path $target 'database_cleanup_verified.json') -Raw | ConvertFrom-Json
$linked = (Get-Content 'supabase/.temp/project-ref' -Raw).Trim()
if ($summary.project -ne 'aaxmohxwzmbjfgfkkejm' -or $linked -ne $summary.project -or
    $marker.admin_accounts -ne 3 -or $marker.non_admin_accounts -ne 0) {
  throw 'Database cleanup verification or project identity does not match.'
}
$bytes = [Security.Cryptography.ProtectedData]::Unprotect(
  [IO.File]::ReadAllBytes((Join-Path $target 'manifest.json.dpapi')), $null,
  [Security.Cryptography.DataProtectionScope]::CurrentUser)
$manifest = [Text.Encoding]::UTF8.GetString($bytes) | ConvertFrom-Json
foreach ($object in $manifest) {
  $backupFile = Join-Path $target $object.file
  $restored = [Security.Cryptography.ProtectedData]::Unprotect(
    [IO.File]::ReadAllBytes($backupFile), $null,
    [Security.Cryptography.DataProtectionScope]::CurrentUser)
  if ($restored.Length -ne $object.bytes) { throw 'An object backup is incomplete.' }
}
$cli = Join-Path $root 'node_modules/.bin/supabase.cmd'
$previousPreference = $ErrorActionPreference
try {
  $ErrorActionPreference = 'Continue'
  $raw = (& $cli projects api-keys --project-ref $linked --output json 2>$null | Out-String)
} finally { $ErrorActionPreference = $previousPreference }
$start = $raw.IndexOf('[')
if ($start -lt 0) { throw 'Storage credential response was invalid.' }
$keys = $raw.Substring($start) | ConvertFrom-Json
$serverKey = @($keys | Where-Object { $_.name -eq 'service_role' })[0].api_key
if (-not $serverKey) { throw 'Server storage credential is unavailable.' }
$headers = @{ apikey = $serverKey; Authorization = "Bearer $serverKey" }
$removed = 0
foreach ($group in ($manifest | Where-Object { -not $_.preserve } | Group-Object bucket)) {
  if ($group.Name -match 'admin') { throw 'Admin bucket was incorrectly included in removal targets.' }
  $body = @{ prefixes = @($group.Group | ForEach-Object name) } | ConvertTo-Json -Compress
  $uri = "https://$linked.supabase.co/storage/v1/object/$($group.Name)"
  try {
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ContentType 'application/json' -Body $body -TimeoutSec 60 | Out-Null
  } catch { throw 'Storage cleanup failed; the encrypted backup remains available.' }
  $removed += $group.Count
}
Write-Output "Requested deletion of $removed backed-up non-admin objects; admin objects preserved."
