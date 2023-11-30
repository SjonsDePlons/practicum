@echo off
echo check if the next results contain:
echo "AlwaysInstallElevated with vale 0x1.
echo If so MSI files will always be ran as admin.

echo Checking HKLM:
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
echo Checking HKCU:
reg query HKCU\Software\Policies\Microsoft\Windows\Installer