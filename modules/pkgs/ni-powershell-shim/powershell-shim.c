/* Minimal powershell.exe stand-in for the Native Access installer under wine.
 *
 * Wine ships a powershell.exe that is a pure stub: it prints a FIXME and
 * returns 0 for every invocation. The NI installer probes with three commands
 * and only ever reads the exit code:
 *
 *   1. if (Get-Command Get-CimInstance) { exit 0 } else { exit 1 }
 *   2. if ((Get-ExecutionPolicy -Scope Process) -eq "Restricted") { exit 1 }
 *                                                           else { exit 0 }
 *   3. if ((Get-CimInstance Win32_Process | ? { $_.Path.StartsWith(
 *          "C:\Program Files\Native Instruments\Native Access") }).Count -gt 0)
 *      { exit 0 } else { exit 1 }
 *
 * Because the stub always returns 0, probe 3 reads as "Native Access is
 * already running", so the installer aborts and rolls back. This shim returns
 * 1 for the Win32_Process probe (nothing running) and 0 otherwise, which is
 * what a real Windows box with no NA running would report.
 */
#include <windows.h>
#include <string.h>

int main(void)
{
    const char *cmd = GetCommandLineA();
    if (cmd && strstr(cmd, "Win32_Process"))
        return 1;   /* no Native Access process is running */
    return 0;       /* CimInstance available; execution policy not Restricted */
}
