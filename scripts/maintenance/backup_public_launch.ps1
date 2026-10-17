param([Parameter(Mandatory = $true)][string]$BackupDirectory)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Security
$projectRef = 'aaxmohxwzmbjfgfkkejm'
$root = (Resolve-Path '.').Path
$target = [IO.Path]::GetFullPath((Join-Path $root $BackupDirectory))
$allowed = [IO.Path]::GetFullPath((Join-Path $root 'supabase/.temp')) + [IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($allowed, [StringComparison]::OrdinalIgnoreCase)) {
  throw 'Backup directory must be inside the ignored supabase/.temp directory.'
}
New-Item -ItemType Directory -Path $target -ErrorAction Stop | Out-Null
$cli = Join-Path $root 'node_modules/.bin/supabase.cmd'
function Read-CliJson([string[]]$Arguments) {
  $previousPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    $raw = (& $cli @Arguments 2>$null | Out-String)
  } finally { $ErrorActionPreference = $previousPreference }
  $start = $raw.IndexOf('{')
  $arrayStart = $raw.IndexOf('[')
  if ($arrayStart -ge 0 -and ($start -lt 0 -or $arrayStart -lt $start)) { $start = $arrayStart }
  if ($start -lt 0) { throw 'CLI did not return JSON; no data was changed.' }
  return $raw.Substring($start) | ConvertFrom-Json
}
function Protect-Backup([string]$Name, [byte[]]$Bytes) {
  $protected = [Security.Cryptography.ProtectedData]::Protect(
    $Bytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
  $path = Join-Path $target $Name
  [IO.File]::WriteAllBytes($path, $protected)
  $restored = [Security.Cryptography.ProtectedData]::Unprotect(
    [IO.File]::ReadAllBytes($path), $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
  $sha = [Security.Cryptography.SHA256]::Create()
  try {
    if ([Convert]::ToBase64String($sha.ComputeHash($Bytes)) -ne
        [Convert]::ToBase64String($sha.ComputeHash($restored))) { throw 'Backup verification failed.' }
  } finally { $sha.Dispose() }
}
$linked = (Get-Content 'supabase/.temp/project-ref' -Raw).Trim()
if ($linked -ne $projectRef) { throw 'Linked project differs from the reviewed target.' }
$response = Read-CliJson -Arguments @('db','query','--linked','--file','supabase/.temp/public-launch-backup.sql','--output','json')
$data = $response.rows[0].backup
if (-not $data -or -not $data.'public.admins') { throw 'Backup is missing administrator records.' }
$adminUserIds = @($data.'public.admins' | ForEach-Object { [string]$_.user_id })
$adminEmails = @($data.'public.users' | Where-Object { [string]$_.user_id -in $adminUserIds } |
  ForEach-Object { ([string]$_.email).Trim().ToLowerInvariant() })
$adminAuth = @($data.'auth.users' | Where-Object { ([string]$_.email).Trim().ToLowerInvariant() -in $adminEmails })
if ($adminAuth.Count -ne $adminUserIds.Count) { throw 'Administrator authentication mapping is inconsistent.' }
$adminAuthIds = @($adminAuth | ForEach-Object { [string]$_.id })
Protect-Backup 'database.json.dpapi' ([Text.Encoding]::UTF8.GetBytes(($data | ConvertTo-Json -Depth 100 -Compress)))
$keys = Read-CliJson -Arguments @('projects','api-keys','--project-ref',$projectRef,'--output','json')
$serverKey = @($keys | Where-Object { $_.name -eq 'service_role' })[0].api_key
if (-not $serverKey) { throw 'A server storage credential is unavailable; backup stopped.' }
$headers = @{ apikey = $serverKey; Authorization = "Bearer $serverKey" }
$objects = @($data.'storage.objects')
$manifest = @()
foreach ($object in $objects) {
  $bucket = [string]$object.bucket_id
  $name = [string]$object.name
  $parts = $name.Split('/')
  $preserve = $bucket -match 'admin' -or $parts[0] -in $adminAuthIds -or
    $parts[0] -in $adminUserIds -or [string]$object.owner -in $adminAuthIds
  $encoded = ($parts | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/'
  $uri = "https://$projectRef.supabase.co/storage/v1/object/authenticated/$bucket/$encoded"
  try { $download = Invoke-WebRequest -Uri $uri -Headers $headers -UseBasicParsing -TimeoutSec 60 }
  catch { throw 'An uploaded object could not be backed up; cleanup has not started.' }
  $memory = New-Object IO.MemoryStream
  if ($download.RawContentStream.CanSeek) { $download.RawContentStream.Position = 0 }
  $download.RawContentStream.CopyTo($memory)
  $bytes = $memory.ToArray()
  $memory.Dispose()
  if ($object.metadata.size -and $bytes.Length -ne [long]$object.metadata.size) {
    throw 'Uploaded object backup length differs from storage metadata.'
  }
  $file = "object-$($object.id).dpapi"
  Protect-Backup $file $bytes
  $manifest += @{ bucket = $bucket; name = $name; file = $file; preserve = $preserve; bytes = $bytes.Length }
}
Protect-Backup 'manifest.json.dpapi' ([Text.Encoding]::UTF8.GetBytes(($manifest | ConvertTo-Json -Depth 10 -Compress)))
$summary = @{
  project = $projectRef; created_at = [DateTime]::UtcNow.ToString('o')
  admin_accounts = $adminAuth.Count; non_admin_accounts = @($data.'auth.users' | Where-Object { $_.id -notin $adminAuthIds }).Count
  objects = $manifest.Count; preserved_objects = @($manifest | Where-Object preserve).Count
  database_tables = @($data.PSObject.Properties).Count; encryption = 'Windows DPAPI CurrentUser'
}
$summary | ConvertTo-Json | Set-Content (Join-Path $target 'summary.json') -Encoding UTF8
$summary | ConvertTo-Json -Compress
