function SetAppGraphicsPerformance
{
	Add-Type -AssemblyName System.Windows.Forms
	$OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
	$OpenFileDialog.Title = "Выберите желаемое приложение или игру"
	$OpenFileDialog.Filter = 'Исполняемые файлы (*.exe)|*.exe';
	$OpenFileDialog.InitialDirectory = "${env:SYSTEMDRIVE}"
	$OpenFileDialog.Multiselect = $false
	$Focus = New-Object -TypeName System.Windows.Forms.Form -Property @{TopMost = $true}
	$OpenFileDialog.ShowDialog($Focus)
	if ($OpenFileDialog.FileName)
	{
		$outputFile = Split-Path $OpenFileDialog.FileName -leaf
		if (-not (Test-Path -Path HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences))
		{
			New-Item -Path HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences -Force
		}
		if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile"))
		{
			New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile" -Force
		}
		if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile\PerfOptions"))
		{
			New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile\PerfOptions" -Force
		}
	New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences -Name $OpenFileDialog.FileName -PropertyType String -Value "GpuPreference=2;" -Force
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile" -Name UseLargePages -Value "1" -Force
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile\PerfOptions" -Name CpuPriorityClass -Value "3" -Force
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile\PerfOptions" -Name IoPriority -Value "3" -Force
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$outputFile\PerfOptions" -Name PagePriority -Value "5" -Force
	Write-Verbose -Message ("{0}" -f $OpenFileDialog.FileName) -Verbose
	}
}
SetAppGraphicsPerformance