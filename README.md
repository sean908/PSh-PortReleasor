# PortReleasor Usage Guide

## Description
PortReleasor is a PowerShell script that helps users find and terminate processes using specific ports on Windows systems. It supports substring matching, allowing users to kill processes using ports like 8080, 8081, 8089, etc., by simply entering "808".

## Features
- ✅ **Substring matching**: Enter "808" to match ports 8080, 8081, 8089, etc.
- ✅ **IPv6 support**: Handles both IPv4 (127.0.0.1:8080) and IPv6 ([::1]:8080) address formats
- ✅ **User-friendly interface**: Clean numbered list of processes to kill
- ✅ **Safety confirmation**: Requires explicit user approval before killing processes
- ✅ **Debug mode**: Use `-Debug` parameter for detailed troubleshooting output
- ✅ **Detailed feedback**: Shows success/failure status for each process
- ✅ **Summary reporting**: Final overview of operation results
- ✅ **Error handling**: Graceful handling of edge cases and permission issues

## Requirements
- Windows operating system
- PowerShell (included with Windows)
- Administrator privileges (recommended for killing processes)

## Usage

### Running the script:
```powershell
# Run the script (will prompt for port input)
.\PortReleasor.ps1

# Specify port directly as parameter
.\PortReleasor.ps1 -PortInput "808"

# Run with debug mode for detailed troubleshooting
.\PortReleasor.ps1 -PortInput "808" -Debug
```

### Step-by-step usage:
1. **Launch the script**: Double-click the script or run it from PowerShell
2. **Enter port number**: Input a port number or partial port (e.g., "808" for 8080, 8081, etc.)
3. **Review processes**: View the list of processes using the matching port(s)
4. **Confirm action**: Type 'Y' to confirm killing all processes or 'N' to cancel
5. **View results**: See which processes were successfully killed and any failures

## Examples

### Example 1: Kill all processes using port 3000
```powershell
.\PortReleasor.ps1
# Input: 3000
# Script will find and kill processes using port 3000
```

### Example 2: Kill all processes using ports starting with 808
```powershell
.\PortReleasor.ps1 -PortInput "808"
# Script will find processes using ports: 8080, 8081, 8082, etc.
```

## Safety Features
- **Confirmation required**: Script won't kill any processes without user confirmation
- **Detailed output**: Shows exactly which processes will be killed before proceeding
- **Error handling**: Won't crash on permission errors or missing processes
- **Clear feedback**: Success/failure status for each process operation

## Troubleshooting

### Permission Denied Errors
If you encounter permission errors, run PowerShell as Administrator:
```powershell
# Right-click PowerShell > Run as Administrator
cd "F:\C0de\SLabs\SWinScripts\portReleasor"
.\PortReleasor.ps1
```

### No Processes Found
- Ensure port is in use by a process
- Try a broader search term (e.g., "80" instead of "8080")
- Check if the application is still running
- Use debug mode to see netstat details: `.\PortReleasor.ps1 -PortInput "8080" -Debug`

### Debug Mode
Use the `-Debug` parameter for detailed troubleshooting:
```powershell
.\PortReleasor.ps1 -PortInput "808" -Debug
```
Debug mode shows:
- Raw netstat connections
- Connection parsing details
- Port extraction process
- Process lookup results
- Any failures in the parsing chain

### Error Messages
The script provides clear error messages for:
- Invalid port numbers (non-numeric input)
- Permission issues
- Network connection errors
- Process termination failures

## Technical Details
- Uses `netstat -ano` to find active TCP connections
- Handles both IPv4 (127.0.0.1:8080) and IPv6 ([::1]:8080) address formats
- Robust parsing with variable whitespace handling
- Parses output to identify process IDs (PIDs) and process names
- Uses `taskkill /PID <pid> /F` to force terminate processes
- Tracks and reports success/failure for each termination
