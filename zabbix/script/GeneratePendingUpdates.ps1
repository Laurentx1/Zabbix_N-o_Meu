# Conta atualizações pendentes e salva em um arquivo
$updateSession = New-Object -ComObject Microsoft.Update.Session
$searcher = $updateSession.CreateUpdateSearcher()
$updates = $searcher.Search("IsInstalled=0 and Type='Software'")
$count = $updates.Updates.Count
$count | Out-File -FilePath "C:\zabbix\PendingUpdates.txt" -Encoding ASCII