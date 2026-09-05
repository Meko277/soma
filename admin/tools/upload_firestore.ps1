# Upload local asset JSON files to Firestore (REST API)
# Usage:
#   powershell -File upload_firestore.ps1 -Folder <dir> -Collection <name> -Lang <ar|en> -IdField <field> -LogFile <path>
param(
  [Parameter(Mandatory = $true)][string]$Folder,
  [Parameter(Mandatory = $true)][string]$Collection,
  [Parameter(Mandatory = $true)][string]$Lang,
  [Parameter(Mandatory = $true)][string]$IdField,
  [Parameter(Mandatory = $true)][string]$LogFile
)

$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$project = 'bible-62ac2'
$apiKey = 'AIzaSyBdRoE9E_Th7TDvReGyv9HqaczlU7wuLE0'
$base = "https://firestore.googleapis.com/v1/projects/$project/databases/(default)/documents"

# ---------------------------------------------------------------
# Fast JSON string escaper (only slow char-walk when needed)
# ---------------------------------------------------------------
$script:hasSpecial = [regex]'[\x00-\x1F"\\]'
$script:sbEscape = New-Object System.Text.StringBuilder

function Append-JsonString([string]$s, [System.Text.StringBuilder]$sb) {
  if (-not $script:hasSpecial.IsMatch($s)) {
    [void]$sb.Append($s)
    return
  }
  foreach ($ch in $s.ToCharArray()) {
    $code = [int]$ch
    if ($ch -eq '"') { [void]$sb.Append('\"') }
    elseif ($ch -eq '\') { [void]$sb.Append('\\') }
    elseif ($code -eq 8) { [void]$sb.Append('\b') }
    elseif ($code -eq 12) { [void]$sb.Append('\f') }
    elseif ($code -eq 10) { [void]$sb.Append('\n') }
    elseif ($code -eq 13) { [void]$sb.Append('\r') }
    elseif ($code -eq 9) { [void]$sb.Append('\t') }
    elseif ($code -lt 32) { [void]$sb.Append('\u{0:x4}' -f $code) }
    else { [void]$sb.Append($ch) }
  }
}

# ---------------------------------------------------------------
# Recursive writer: PS value -> Firestore Value JSON
# ---------------------------------------------------------------
function Write-FsValue($obj, [System.Text.StringBuilder]$sb) {
  if ($null -eq $obj) { [void]$sb.Append('{"nullValue":null}'); return }

  if ($obj -is [bool]) {
    if ($obj) { [void]$sb.Append('{"booleanValue":true}') }
    else { [void]$sb.Append('{"booleanValue":false}') }
    return
  }

  if ($obj -is [int32] -or $obj -is [int64] -or $obj -is [int16] -or $obj -is [byte]) {
    [void]$sb.Append('{"integerValue":"' + $obj.ToString([Globalization.CultureInfo]::InvariantCulture) + '"}')
    return
  }

  if ($obj -is [double] -or $obj -is [single] -or $obj -is [decimal]) {
    [void]$sb.Append('{"doubleValue":' + $obj.ToString([Globalization.CultureInfo]::InvariantCulture) + '}')
    return
  }

  if ($obj -is [string]) {
    [void]$sb.Append('{"stringValue":"')
    Append-JsonString $obj $sb
    [void]$sb.Append('"}')
    return
  }

  if ($obj -is [System.Collections.IDictionary]) {
    [void]$sb.Append('{"mapValue":{"fields":{')
    $first = $true
    foreach ($k in @($obj.Keys)) {
      if (-not $first) { [void]$sb.Append(',') }
      $first = $false
      [void]$sb.Append('"')
      Append-JsonString ([string]$k) $sb
      [void]$sb.Append('":')
      Write-FsValue $obj[$k] $sb
    }
    [void]$sb.Append('}}}')
    return
  }

  if ($obj -is [System.Management.Automation.PSCustomObject]) {
    [void]$sb.Append('{"mapValue":{"fields":{')
    $first = $true
    foreach ($p in @($obj.PSObject.Properties)) {
      if (-not $first) { [void]$sb.Append(',') }
      $first = $false
      [void]$sb.Append('"')
      Append-JsonString $p.Name $sb
      [void]$sb.Append('":')
      Write-FsValue $p.Value $sb
    }
    [void]$sb.Append('}}}')
    return
  }

  if ($obj -is [System.Collections.IEnumerable]) {
    [void]$sb.Append('{"arrayValue":{"values":[')
    $first = $true
    foreach ($item in @($obj)) {
      if (-not $first) { [void]$sb.Append(',') }
      $first = $false
      Write-FsValue $item $sb
    }
    [void]$sb.Append(']}}')
    return
  }

  # Fallback
  [void]$sb.Append('{"stringValue":"' + $obj.ToString() + '"}')
}
# ---------------------------------------------------------------
# MAIN: upload every *.json in $Folder
# ---------------------------------------------------------------

$doneIds = @{}
if (Test-Path $LogFile) {
  Get-Content $LogFile -Encoding UTF8 | ForEach-Object {
    if ($_ -like 'OK *') { $doneIds[$_.Substring(3).Trim()] = $true }
  }
}

$files = @(Get-ChildItem -LiteralPath $Folder -Filter *.json | Sort-Object Name)
Add-Content -LiteralPath $LogFile -Value ("START folder=$Folder collection=$Collection lang=$Lang files=" + $files.Count) -Encoding UTF8

$ok = 0; $skipped = 0

foreach ($file in $files) {
  try {
    if ($doneIds.ContainsKey($file.Name)) { $skipped++; continue }

    $raw = [IO.File]::ReadAllText($file.FullName, [Text.Encoding]::UTF8)
    $obj = $raw | ConvertFrom-Json

    $idFromField = $obj.PSObject.Properties[$IdField]
    $id = if ($idFromField -and $idFromField.Value) { [string]$idFromField.Value } else { $file.BaseName }
    $docId = "${id}_${Lang}"

    $obj | Add-Member -NotePropertyName 'lang' -NotePropertyValue $Lang -Force
    $obj | Add-Member -NotePropertyName 'updatedAt' -NotePropertyValue ([DateTime]::UtcNow.ToString('o')) -Force

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('{"fields":{')
    $firstDocField = $true
    foreach ($p in @($obj.PSObject.Properties)) {
      if (-not $firstDocField) { [void]$sb.Append(',') }
      $firstDocField = $false
      [void]$sb.Append('"')
      Append-JsonString $p.Name $sb
      [void]$sb.Append('":')
      Write-FsValue $p.Value $sb
    }
    [void]$sb.Append('}}')

    $bodyBytes = [Text.Encoding]::UTF8.GetBytes($sb.ToString())
    $url = "$base/$Collection/$([Uri]::EscapeDataString($docId))?key=$apiKey"

    $resp = Invoke-WebRequest -Uri $url -Method Patch `
      -ContentType 'application/json; charset=utf-8' -Body $bodyBytes `
      -UseBasicParsing -TimeoutSec 120

    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300) {
      $ok++
      Add-Content -LiteralPath $LogFile -Value ("OK " + $file.Name) -Encoding UTF8
    } else {
      Add-Content -LiteralPath $LogFile -Value ("FAIL " + $file.Name + " HTTP " + $resp.StatusCode) -Encoding UTF8
    }
  }
  catch {
    $msg = $_.Exception.Message
    $errBody = ''
    try {
      $rs = $_.Exception.Response.GetResponseStream()
      if ($rs) {
        $sr = New-Object IO.StreamReader($rs)
        $errBody = $sr.ReadToEnd()
        if ($errBody.Length -gt 500) { $errBody = $errBody.Substring(0, 500) }
        $errBody = $errBody -replace '\s+', ' '
      }
    } catch {}
    if ($msg.Length -gt 200) { $msg = $msg.Substring(0, 200) }
    Add-Content -LiteralPath $LogFile -Value ("FAIL " + $file.Name + " " + ($msg -replace "`r?`n", ' ')) -Encoding UTF8
  }
}

$fail = $files.Count - $ok - $skipped
Add-Content -LiteralPath $LogFile -Value ("DONE ok=$ok fail=$fail skipped=$skipped total=" + $files.Count) -Encoding UTF8
Write-Output ("FINISHED ok=$ok skipped=$skipped total=" + $files.Count)


