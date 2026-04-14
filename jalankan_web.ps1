if (!(Test-Path "D:\Temp")) { New-Item -ItemType Directory -Force -Path "D:\Temp" | Out-Null }
$env:TMP = "D:\Temp"
$env:TEMP = "D:\Temp"
Write-Host "--------------------------------------------------------"
Write-Host "🚀 Menggunakan folder D:\Temp agar tidak error Drive C..."
Write-Host "--------------------------------------------------------"
flutter run -d chrome
