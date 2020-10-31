<#
.SYNOPSIS
  Clear and collect event logs for analysis.
.DESCRIPTION
  This script provides two functionalities, Clear-EventLogs will clear all of the embedded event logs providers and Collect-EventLogs will collect them to a network drive specified within the script.
.EXAMPLE
  Collect-EventLogs "testanalysis"

  This will collect and upload specified event logs to a network share.
#>

$EventLogs = "System","Security","Windows PowerShell","Microsoft-Windows-Sysmon/Operational"
$FileShare = "\\10.100.0.1\share"
$DriveLetter = "U"

Function Clear-EventLogs {
  foreach ($EventLog in $EventLogs) {
    Write-Host $EventLog
    wevtutil cl $EventLog
  }
}

Function Collect-EventLogs($CollectionStamp) {
  $sysname=$env:COMPUTERNAME
  $net=new-object -ComObject WScript.Network
  $path=$DriveLetter+":\"
  New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $FileShare -Persist
  foreach ($EventLog in $EventLogs) {
    $evtxpath=$path + $EventLog + "_" + $sysname + "_" + $CollectionStamp + ".evt"
    Write-Host "Collecting "$EventLog " to " $evtxpath
    wevtutil epl $EventLog $evtxpath
  }

  Get-PSDrive $DriveLetter | Remove-PSDrive
}
