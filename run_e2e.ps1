# Auto-detect active LAN IP using ops/find_active_ip.ps1
$IP = & "$PSScriptRoot\ops\find_active_ip.ps1" 2>$null

if (-not $IP) {
  # Fallback: direct DHCP detection
  $IP = (Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
      $_.IPAddress -notlike '127.*' -and 
      $_.IPAddress -notlike '169.*' -and
      $_.PrefixOrigin -eq 'Dhcp'
    } | Select-Object -First 1).IPAddress
}

if (-not $IP) {
  Write-Host "ERROR: Could not detect LAN IP. Connect to WiFi." -ForegroundColor Red
  exit 1
}

$DEVICE="1f3431ad"
$API="http://${IP}:8080"
$FILE="integration_test/full_e2e_test.dart"
$LOG="e2e_results.txt"

Write-Host "Detected LAN IP: $IP" -ForegroundColor Green
Write-Host "API URL: $API"

"Run started: $(Get-Date)" | Out-File $LOG
"API URL: $API" | Tee-Object -FilePath $LOG -Append

for ($i = 1; $i -le 11; $i++) {
    "=== SUITE $i ===" | Tee-Object -FilePath $LOG -Append
    flutter test $FILE `
        -d $DEVICE `
        --dart-define=API_BASE_URL=$API `
        --dart-define=E2E=true `
        --reporter expanded `
        --name "Suite $i" 2>&1 | Tee-Object -FilePath $LOG -Append
    "=== END SUITE $i ===" | Tee-Object -FilePath $LOG -Append
}

Write-Host "Done! Results in e2e_results.txt" -ForegroundColor Green