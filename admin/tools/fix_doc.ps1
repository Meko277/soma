$c = Get-Content -LiteralPath $PSScriptRoot\upload_firestore.ps1 -Raw

$old = @'
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('{"fields":')
    Write-FsValue $obj $sb
    [void]$sb.Append('}')
'@

$new = @'
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
'@

$old = $old -replace '`r?`n', "`r`n"

if (-not $c.Contains($old)) {
  # try LF version
  $oldLf = $old -replace "`r`n", "`n"
  if ($c.Contains($oldLf)) { $old = $oldLf; $new = $new -replace "`r`n", "`n" }
}

if ($c.Contains($old)) {
  $c = $c.Replace($old, $new)
  [IO.File]::WriteAllText("$PSScriptRoot\upload_firestore.ps1", $c, (New-Object Text.UTF8Encoding($false)))
  Write-Output 'FIXED'
} else {
  Write-Output 'NOT FOUND'
}