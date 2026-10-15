# Copy-Folders-With-Log.ps1
# Copies a selected folder to another drive and records the Robocopy output.
# This script does NOT calculate checksums, move files, or delete source files.

$ErrorActionPreference = 'Stop'

function Read-FolderPath {
    param([string]$Prompt)

    while ($true) {
        $enteredPath = Read-Host $Prompt
        if ([string]::IsNullOrWhiteSpace($enteredPath)) {
            Write-Host 'Please enter a folder path.' -ForegroundColor Yellow
            continue
        }

        $cleanPath = $enteredPath.Trim().Trim('"')
        if (Test-Path -LiteralPath $cleanPath -PathType Container) {
            try {
                return (Get-Item -LiteralPath $cleanPath -ErrorAction Stop).FullName.TrimEnd('\')
            }
            catch {
                Write-Host "Could not read that folder: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host 'That folder was not found. Check the path and try again.' -ForegroundColor Yellow
        }
    }
}

function Test-PathIsWithin {
    param(
        [string]$ChildPath,
        [string]$ParentPath
    )

    $child = [System.IO.Path]::GetFullPath($ChildPath).TrimEnd('\')
    $parent = [System.IO.Path]::GetFullPath($ParentPath).TrimEnd('\')

    if ($child.Equals($parent, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $parentWithSeparator = $parent + '\'
    return $child.StartsWith($parentWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)
}

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' Folder Copy with Transfer Log' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'This script copies a folder and records the results.'
Write-Host 'It does not move or delete the original files.'
Write-Host 'No checksum verification is performed.'
Write-Host ''

$SourcePath = Read-FolderPath 'Enter the FULL PATH of the folder you want to copy'
$DestinationParent = Read-FolderPath 'Enter the FULL PATH of the destination folder or drive'

$SourceFolderName = Split-Path -Path $SourcePath -Leaf
$TargetPath = Join-Path -Path $DestinationParent -ChildPath $SourceFolderName

# Prevent accidentally copying a folder into itself or one of its own subfolders.
if (Test-PathIsWithin -ChildPath $DestinationParent -ParentPath $SourcePath) {
    Write-Host ''
    Write-Host 'ERROR: The destination is inside the source folder.' -ForegroundColor Red
    Write-Host 'Choose a destination folder outside the source folder, then run the script again.' -ForegroundColor Yellow
    Read-Host 'Press Enter to close'
    exit 1
}

Write-Host ''
Write-Host "Source:      $SourcePath" -ForegroundColor Gray
Write-Host "Destination: $TargetPath" -ForegroundColor Gray
Write-Host ''

if (Test-Path -LiteralPath $TargetPath) {
    Write-Host 'The destination folder already exists.' -ForegroundColor Yellow
    Write-Host 'Robocopy may update matching files and add missing files. It will not delete destination files.' -ForegroundColor Yellow
    $confirmation = Read-Host 'Type YES to continue'
    if ($confirmation -cne 'YES') {
        Write-Host 'Copy cancelled. No files were copied.' -ForegroundColor Yellow
        Read-Host 'Press Enter to close'
        exit 0
    }
}
else {
    $confirmation = Read-Host 'Type YES to start the copy'
    if ($confirmation -cne 'YES') {
        Write-Host 'Copy cancelled. No files were copied.' -ForegroundColor Yellow
        Read-Host 'Press Enter to close'
        exit 0
    }
}

$DocumentationPath = Join-Path -Path $DestinationParent -ChildPath '_transfer_documentation'
$TimeStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$LogPath = Join-Path -Path $DocumentationPath -ChildPath "Robocopy_$($SourceFolderName)_$TimeStamp.log"
$SummaryPath = Join-Path -Path $DocumentationPath -ChildPath "Transfer_Summary_$($SourceFolderName)_$TimeStamp.txt"

try {
    New-Item -ItemType Directory -Path $DocumentationPath -Force | Out-Null

    $StartedAt = Get-Date
    Write-Host ''
    Write-Host 'Copy started. This window will show progress and the log will be saved to:' -ForegroundColor Cyan
    Write-Host $LogPath
    Write-Host ''

    # /E copies all subfolders, including empty ones.
    # /COPY:DAT preserves file data, attributes, and timestamps.
    # /DCOPY:DAT preserves directory data, attributes, and timestamps.
    # /R:2 /W:2 retries failed copies twice, waiting two seconds between attempts.
    # /XJ avoids following junction points.
    # /TEE shows output in this window and writes it to the log.
    # /LOG writes the Robocopy log to the specified file.
    & robocopy $SourcePath $TargetPath /E /COPY:DAT /DCOPY:DAT /R:2 /W:2 /XJ /TEE "/LOG:$LogPath"
    $RobocopyCode = $LASTEXITCODE

    $FinishedAt = Get-Date
    $Duration = $FinishedAt - $StartedAt

    if ($RobocopyCode -lt 8) {
        $Status = 'PASS - Robocopy completed without reporting a copy failure.'
        $StatusForScreen = 'COPY COMPLETED' 
        $StatusColor = 'Green'
    }
    else {
        $Status = "REVIEW NEEDED - Robocopy returned exit code $RobocopyCode, which indicates one or more copy errors. Review the Robocopy log."
        $StatusForScreen = 'REVIEW NEEDED'
        $StatusColor = 'Red'
    }

    $SummaryLines = @(
        'FOLDER COPY SUMMARY'
        '==================='
        "Status: $Status"
        "Source folder: $SourcePath"
        "Destination folder: $TargetPath"
        "Start time: $($StartedAt.ToString('yyyy-MM-dd HH:mm:ss'))"
        "Finish time: $($FinishedAt.ToString('yyyy-MM-dd HH:mm:ss'))"
        "Duration: $($Duration.ToString())"
        "Robocopy exit code: $RobocopyCode"
        "Robocopy log: $LogPath"
        ''
        'This script copies files only. It does not delete or move source files.'
        'No checksum verification was performed.'
        ''
        'Robocopy exit-code guidance: codes below 8 generally indicate no copy failure; codes 8 or higher indicate a failure. Review the log for details.'
    )
    $SummaryLines | Set-Content -LiteralPath $SummaryPath -Encoding UTF8

    Write-Host ''
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host $StatusForScreen -ForegroundColor $StatusColor
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host "Robocopy exit code: $RobocopyCode"
    Write-Host "Detailed log: $LogPath"
    Write-Host "Summary:      $SummaryPath"
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'If the copy started, review any Robocopy log that was created before the error.' -ForegroundColor Yellow
}

Write-Host ''
Read-Host 'Press Enter to close'
