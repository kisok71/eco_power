# Windows PowerShell - PC PowerSaver Pro Background Worker Engine
# UTF-8 Encoding

# Ensure single instance of background worker
$createdNew = $false
$mutex = New-Object System.Threading.Mutex($true, "PowerSaverPro_BackgroundWorkerMutex", [ref]$createdNew)
if (-not $createdNew) {
    exit
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Win32 API Definitions for Display, Idle Time
$Win32Code = @"
using System;
using System.Runtime.InteropServices;

public class Win32PowerBg {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    public const uint WM_SYSCOMMAND = 0x0112;
    public const int SC_MONITORPOWER = 0xF170;

    public static void TurnOffDisplay() {
        SendMessage((IntPtr)0xFFFF, WM_SYSCOMMAND, (IntPtr)SC_MONITORPOWER, (IntPtr)2);
    }
}
"@

Add-Type -TypeDefinition $Win32Code -ErrorAction SilentlyContinue

$ConfigFile = Join-Path $PSScriptRoot "settings.json"
if (-not $PSScriptRoot -or -not (Test-Path $PSScriptRoot)) {
    $ConfigFile = "c:\Users\jkiso\Documents\test\settings.json"
}

function Execute-PowerAction($actionIndex) {
    switch ($actionIndex) {
        0 { [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false) }
        1 { [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Hibernate, $false, $false) }
        2 { [Win32PowerBg]::TurnOffDisplay() }
        3 { Stop-Computer -Force }
        4 { Restart-Computer -Force }
    }
}

# Infinite Background Loop
while ($true) {
    Start-Sleep -Seconds 1
    if (Test-Path $ConfigFile) {
        try {
            $json = [System.IO.File]::ReadAllText($ConfigFile, [System.Text.Encoding]::UTF8)
            $cfg = $json | ConvertFrom-Json
            $now = Get-Date

            # Schedule 1 (점심시간) Check
            if ([bool]$cfg.Sched1_Enabled) {
                $targetH1 = [int]$cfg.Sched1_Hour
                $targetM1 = [int]$cfg.Sched1_Min
                if ($now.Hour -eq $targetH1 -and $now.Minute -eq $targetM1 -and $now.Second -eq 0) {
                    Execute-PowerAction ([int]$cfg.Sched1_Action)
                    Start-Sleep -Seconds 2
                }
            }

            # Schedule 2 (퇴근시간) Check
            if ([bool]$cfg.Sched2_Enabled) {
                $targetH2 = [int]$cfg.Sched2_Hour
                $targetM2 = [int]$cfg.Sched2_Min
                if ($now.Hour -eq $targetH2 -and $now.Minute -eq $targetM2 -and $now.Second -eq 0) {
                    Execute-PowerAction ([int]$cfg.Sched2_Action)
                    Start-Sleep -Seconds 2
                }
            }
        } catch {}
    }
}
