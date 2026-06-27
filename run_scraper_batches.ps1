# run_scraper_batches.ps1
# This script automatically opens new PowerShell windows and runs the scraper
# for each city, in batches, so you don't have to copy-paste manually.

# ---- EDIT THIS LIST: remaining cities you still need ----
$cities = @(
    @{ Name = "Louisville KY";        File = "leads_louisville.csv" },
    @{ Name = "Baltimore MD";         File = "leads_baltimore.csv" },
    @{ Name = "Milwaukee WI";         File = "leads_milwaukee.csv" },
    @{ Name = "Albuquerque NM";       File = "leads_albuquerque.csv" },
    @{ Name = "Tucson AZ";            File = "leads_tucson.csv" },
    @{ Name = "Fresno CA";            File = "leads_fresno.csv" },
    @{ Name = "Sacramento CA";        File = "leads_sacramento.csv" },
    @{ Name = "Mesa AZ";              File = "leads_mesa.csv" },
    @{ Name = "Atlanta GA";           File = "leads_atlanta.csv" },
    @{ Name = "Kansas City MO";       File = "leads_kansascity.csv" },
    @{ Name = "Colorado Springs CO";  File = "leads_coloradosprings.csv" },
    @{ Name = "Omaha NE";             File = "leads_omaha.csv" },
    @{ Name = "Raleigh NC";           File = "leads_raleigh.csv" },
    @{ Name = "Miami FL";             File = "leads_miami.csv" },
    @{ Name = "Long Beach CA";        File = "leads_longbeach.csv" },
    @{ Name = "Virginia Beach VA";    File = "leads_virginiabeach.csv" },
    @{ Name = "Oakland CA";           File = "leads_oakland.csv" },
    @{ Name = "Minneapolis MN";       File = "leads_minneapolis.csv" },
    @{ Name = "Tulsa OK";             File = "leads_tulsa.csv" },
    @{ Name = "Tampa FL";             File = "leads_tampa.csv" },
    @{ Name = "Arlington TX";         File = "leads_arlington.csv" },
    @{ Name = "New Orleans LA";       File = "leads_neworleans.csv" },
    @{ Name = "Wichita KS";           File = "leads_wichita.csv" },
    @{ Name = "Cleveland OH";         File = "leads_cleveland.csv" }
)

# ---- SETTINGS ----
$batchSize = 5          # how many terminals to open AT THE SAME TIME (keep 3-5, don't go higher)
$projectFolder = "C:\Users\abdul\Documents\github\Google-Maps-Scrapper"   # <-- change if your path is different
$waitBetweenBatchesSeconds = 30   # extra pause after a batch finishes, before starting next batch

# ---- SCRIPT LOGIC (no need to edit below this line) ----
$total = $cities.Count
$batchCount = [Math]::Ceiling($total / $batchSize)

# Folder to hold temporary per-city launcher scripts (avoids quoting issues)
$tempFolder = Join-Path $projectFolder "_temp_launchers"
if (-not (Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

Write-Host "Total cities to scrape: $total"
Write-Host "Running in $batchCount batches of $batchSize parallel terminals each."
Write-Host ""

for ($b = 0; $b -lt $batchCount; $b++) {

    $startIdx = $b * $batchSize
    $endIdx = [Math]::Min($startIdx + $batchSize - 1, $total - 1)

    Write-Host "=== Starting batch $($b+1) of $batchCount (cities $($startIdx+1) to $($endIdx+1)) ==="

    $processList = @()

    for ($i = $startIdx; $i -le $endIdx; $i++) {
        $city = $cities[$i].Name
        $file = $cities[$i].File

        # Write a small standalone .ps1 launcher file for THIS city only.
        # This avoids all nested-quote escaping problems.
        $launcherPath = Join-Path $tempFolder "launch_$i.ps1"

        $launcherContent = @"
Set-Location -Path '$projectFolder'
python main.py -s 'HVAC contractor $city' -o '$file'
"@

        Set-Content -Path $launcherPath -Value $launcherContent -Encoding UTF8

        Write-Host "  Opening terminal for: $city -> $file"

        # Launch a new PowerShell window that just runs that one launcher file
        $proc = Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$launcherPath`"" -PassThru
        $processList += $proc

        Start-Sleep -Seconds 3   # small stagger so all terminals don't hit Google in the exact same millisecond
    }

    Write-Host "  Waiting for batch $($b+1) terminals to finish..."

    # Wait until all processes in this batch have closed
    foreach ($proc in $processList) {
        $proc.WaitForExit()
    }

    Write-Host "  Batch $($b+1) complete."

    if ($b -lt $batchCount - 1) {
        Write-Host "  Pausing $waitBetweenBatchesSeconds seconds before next batch..."
        Start-Sleep -Seconds $waitBetweenBatchesSeconds
    }

    Write-Host ""
}

Write-Host "ALL BATCHES COMPLETE. Check your folder for all leads_*.csv files."# updated
