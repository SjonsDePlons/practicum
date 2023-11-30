$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services"

# Specify the identities to filter
$identitiesToDisplay = @("Everyone", $env:USERNAME, "NT AUTHORITY\INTERACTIVE", "BUILTIN\Administrators")

try {
    # Get the registry key
    $servicesKey = Get-Item -LiteralPath $registryPath

    # Loop over subkeys (service names) in the Services key
    foreach ($serviceKey in $servicesKey.GetSubKeyNames()) {
        $serviceKeyPath = Join-Path -Path $registryPath -ChildPath $serviceKey

        try {
            # Get the ACL for the service key
            $acl = (Get-Item -LiteralPath $serviceKeyPath).GetAccessControl()

            # Check if the service key has the specified permissions for the selected identities
            $hasDesiredPermissions = $acl.GetAccessRules($true, $true, [System.Security.Principal.NTAccount]) | 
                Where-Object {
                    $identitiesToDisplay -contains $_.IdentityReference.Value -and
                    ($_.RegistryRights -band [System.Security.AccessControl.RegistryRights]::FullControl -or
                     $_.RegistryRights -band [System.Security.AccessControl.RegistryRights]::SetValue)
                }

            # Initialize a variable to store service information
            $serviceInfo = ""

            # Display information only if the service key meets the criteria
            if ($hasDesiredPermissions.Count -gt 0) {
                $serviceInfo += "Service Name: $serviceKey`r`n"

                # Display permissions for the service key with FullControl or SetValue
                foreach ($accessRule in $hasDesiredPermissions) {
                    $serviceInfo += "  Identity: $($accessRule.IdentityReference.Value)`r`n"
                    
                    # Convert registry rights to a human-readable format
                    $rights = [System.Security.AccessControl.RegistryRights]$accessRule.RegistryRights

                    # Check if $rights contain ONLY "ReadKey"
                    if (-not ($rights -eq [System.Security.AccessControl.RegistryRights]::ReadKey)) {
                        $serviceInfo += "  Rights: $rights`r`n"
                        $serviceInfo += "---`r`n"
                    }
                }

                $serviceInfo += "----------------------`r`n"

                # Print service information for the current service
                Write-Host $serviceInfo
            }
        } catch {
            Write-Host "Error accessing service key: $serviceKeyPath. $_"
        }
    }
} catch {
    Write-Host "Error accessing registry key: $registryPath. $_"
}