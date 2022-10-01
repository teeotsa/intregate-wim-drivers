Clear-Host

If (!(Test-Path "$env:TEMP\mount"))
{
    New-Item -Path "$env:TEMP\mount" -Force -ItemType Directory | Out-Null
    Write-Host "Mount folder created!" -ForegroundColor Green
}

$Wim = Get-ChildItem -Path "$PSScriptRoot\wim" -Include *.wim -Force -Recurse

If ($Wim.Count -lt 1) 
{
    Write-Host "No Windows Images were found...!" -ForegroundColor Red
    Return
}

$Drivers = Get-ChildItem -Path "$PSScriptRoot\drivers" -Force -Recurse

If ($Drivers.Count -lt 1) 
{
    Write-Host "No Drivers were found...!" -ForegroundColor Red
    Return
}

Foreach ($Item in $Wim)
{
    Write-Host "Found $($Item.Name)" -ForegroundColor Green

    Write-Host "Mounting..."

    Get-WindowsImage -ImagePath $Item.FullName | Foreach {
    
        Write-Host "Mounting Index > $($_.ImageIndex)" -ForegroundColor Cyan

        Mount-WindowsImage -ImagePath $Item.FullName -Path "$env:TEMP\mount" -Index $_.ImageIndex -LogLevel WarningsInfo -LogPath "$PSScriptRoot\mountlog.txt"

        Write-Host "Index > $($_.ImageIndex) is mounted!" -ForegroundColor Green

        Add-WindowsDriver -Path "$env:TEMP\mount" -Driver "$PSScriptRoot\drivers" -Recurse -ForceUnsigned -LogLevel WarningsInfo -LogPath "$PSScriptRoot\driverlog.txt"

        Write-Host "Dismounting Index > $($_.ImageIndex)" -ForegroundColor Yellow

        Dismount-WindowsImage -Path "$env:TEMP\mount" -Save -LogLevel WarningsInfo -LogPath "$PSScriptRoot\dismount_log.txt"

        Write-Host "Index > $($_.ImageIndex) is done!" -ForegroundColor Yellow

    }
}

Remove-Item -Path "$env:TEMP\mount" -Force -Recurse | Out-Null