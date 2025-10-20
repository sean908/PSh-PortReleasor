# PortReleasor.ps1
# A script to help users kill processes using specific ports
# Supports substring matching for port numbers

param(
    [string]$PortInput = "",
    [switch]$Debug
)

# Function to display colored output
function Write-Colored {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# Function to get user input
function Get-PortInput {
    if ([string]::IsNullOrWhiteSpace($PortInput)) {
        $PortInput = Read-Host "Enter port number or partial port (e.g., 808, 3000)"
    }

    # Validate input is numeric
    if (-not ($PortInput -match '^\d+$')) {
        Write-Colored "Error: Please enter a valid numeric port number." "Red"
        exit 1
    }

    return $PortInput
}

# Function to find processes using the specified port
function Find-ProcessesByPort {
    param([string]$PortSearch)

    Write-Colored "Searching for processes using ports containing '$PortSearch'..." "Yellow"

    try {
        # Get all TCP connections
        $connections = netstat -ano | Where-Object { $_ -match "TCP" }

        if ($Debug) {
            Write-Colored "`n=== DEBUG: Raw netstat TCP connections ===" "Magenta"
            $connections | ForEach-Object { Write-Colored $_ "Gray" }
            Write-Colored "=== END DEBUG ===`n" "Magenta"
        }

        $processes = @()

        foreach ($connection in $connections) {
            if ($Debug) {
                Write-Colored "DEBUG: Processing connection: $connection" "Cyan"
            }

            # Parse netstat output: Proto Local Address Foreign Address State PID
            # Use split parsing for better reliability with variable whitespace
            $trimmed = $connection.Trim()
            $parts = $trimmed -split '\s+', 6
            if ($parts.Count -ge 5) {
                $protocol = $parts[0]
                $localAddress = $parts[1]
                $foreignAddress = $parts[2]
                $state = $parts[3]
                $processId = $parts[-1]  # Get the last element

                if ($Debug) {
                    Write-Colored "DEBUG: Regex match successful. LocalAddress: $localAddress, PID: $processId" "Green"
                }

                # Extract port number - handle both IPv4 (127.0.0.1:8080) and IPv6 ([::1]:8080)
                if ($localAddress -match ":(\d+)$") {
                    $port = $matches[1]
                    if ($Debug) {
                        Write-Colored "DEBUG: Extracted port: $port, comparing against search: $PortSearch" "Green"
                    }

                    if ($port -match $PortSearch) {
                        if ($Debug) {
                            Write-Colored "DEBUG: Port match found! Looking up process info..." "Yellow"
                        }

                        try {
                            $processInfo = Get-Process -Id $processId -ErrorAction SilentlyContinue
                            if ($processInfo) {
                                $processes += [PSCustomObject]@{
                                    PID = $processId
                                    ProcessName = $processInfo.ProcessName
                                    Port = $port
                                    LocalAddress = $localAddress
                                }

                                if ($Debug) {
                                    Write-Colored "DEBUG: Added process: $($processInfo.ProcessName) (PID: $processId) on port $port" "Yellow"
                                }
                            }
                        } catch {
                            # Process might have ended, skip it
                            if ($Debug) {
                                Write-Colored "DEBUG: Process lookup failed for PID: $processId" "Red"
                            }
                        }
                    }
                }
            } else {
                if ($Debug) {
                    Write-Colored "DEBUG: Regex failed to match connection: $connection" "Red"
                }
            }
        }

        return $processes | Sort-Object Port
    } catch {
        Write-Colored "Error finding processes: $_" "Red"
        exit 1
    }
}

# Function to display found processes
function Display-Processes {
    param([array]$Processes)

    if ($Processes.Count -eq 0) {
        Write-Colored "No processes found using the specified port(s)." "Green"
        return $false
    }

    Write-Colored "`nFound $($Processes.Count) process(es):" "Cyan"
    Write-Colored "----------------------------------------" "Gray"

    for ($i = 0; $i -lt $Processes.Count; $i++) {
        $process = $Processes[$i]
        Write-Colored "$($i + 1). PID: $($process.PID) | Process: $($process.ProcessName) | Port: $($process.Port)" "White"
    }

    return $true
}

# Function to get user confirmation
function Get-Confirmation {
    param([array]$Processes)

    $response = Read-Host "`nFound $($Processes.Count) process(es). Do you want to kill all of them? (Y/N)"
    return ($response -match '^[Yy]$')
}

# Function to kill processes
function Kill-Processes {
    param([array]$Processes)

    $successCount = 0
    $failedCount = 0

    Write-Colored "`nKilling processes..." "Yellow"
    Write-Colored "----------------------------------------" "Gray"

    foreach ($process in $Processes) {
        try {
            $result = taskkill /PID $process.PID /F /T
            if ($LASTEXITCODE -eq 0) {
                Write-Colored "✓ Successfully killed PID $($process.PID) ($($process.ProcessName))" "Green"
                $successCount++
            } else {
                Write-Colored "✗ Failed to kill PID $($process.PID) ($($process.ProcessName))" "Red"
                $failedCount++
            }
        } catch {
            Write-Colored "✗ Error killing PID $($process.PID): $_" "Red"
            $failedCount++
        }
    }

    return @{
        Success = $successCount
        Failed = $failedCount
    }
}

# Function to display summary
function Show-Summary {
    param([hashtable]$Results, [array]$Processes)

    Write-Colored "`n" "White"
    Write-Colored "========================================" "Cyan"
    Write-Colored "           PORT RELEASE SUMMARY" "Cyan"
    Write-Colored "========================================" "Cyan"
    Write-Colored "Total processes targeted: $($Processes.Count)" "White"
    Write-Colored "Successfully killed: $($Results.Success)" "Green"
    Write-Colored "Failed to kill: $($Results.Failed)" "Red"

    if ($Results.Success -gt 0) {
        Write-Colored "✓ Port released successfully!" "Green"
    } else {
        Write-Colored "✗ No ports were released." "Yellow"
    }
}

# Main execution
try {
    Write-Colored "========================================" "Cyan"
    Write-Colored "          PORT RELEASOR" "Cyan"
    Write-Colored "========================================" "Cyan"

    # Get port input
    $portSearch = Get-PortInput

    # Find processes
    $processes = Find-ProcessesByPort $portSearch

    # Display processes and get confirmation
    if (Display-Processes $processes) {
        if (Get-Confirmation $processes) {
            # Kill processes
            $results = Kill-Processes $processes

            # Show summary
            Show-Summary $results $processes
        } else {
            Write-Colored "Operation cancelled by user." "Yellow"
        }
    }
} catch {
    Write-Colored "An unexpected error occurred: $_" "Red"
    exit 1
}

Write-Colored "`nScript completed." "White"