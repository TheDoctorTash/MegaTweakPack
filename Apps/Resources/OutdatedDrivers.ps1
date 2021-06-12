$Hashtable = @{
	Name = 'OriginalFileName'
	Expression = {$_.OriginalFileName | Split-Path -Leaf}
}
$AllDrivers = Get-WindowsDriver –Online -All | Where-Object -FilterScript {$_.Driver -like 'oem*inf'} | Select-Object $Hashtable, Driver, ClassDescription, ProviderName, Date, Version
Write-Host "Все установленные сторонние драйверы:" -ForegroundColor Yellow
$AllDrivers | Sort-Object ClassDescription | Format-Table
$DriverGroups = $AllDrivers | Group-Object OriginalFileName | Where-Object -FilterScript {$_.Count -gt 1}
Write-Host "Дубликаты драйверов:" -ForegroundColor Yellow
$DriverGroups | ForEach-Object {$_.Group | Sort-Object Date -Descending | Select-Object -Skip 1} | Format-Table
$DriversToRemove = $DriverGroups | ForEach-Object {$_.Group | Sort-Object Date -Descending | Select-Object -Skip 1}
Write-Host "Драйверы для удаления:" -ForegroundColor Yellow
$DriversToRemove | Sort-Object ClassDescription | Format-Table
Foreach ($item in $DriversToRemove)
{
	$Name = $($item.Driver).Trim()
	& pnputil.exe /delete-driver "$Name" /force
}