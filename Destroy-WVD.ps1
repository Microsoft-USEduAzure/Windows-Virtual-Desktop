Function Destroy-WVD {
    param( $TenantName )
    Write-Host "Begin deleting:"$TenantName
    # Pull tenant by name
    Get-RdsTenant -Name $TenantName | ForEach-Object {
        # Pull a list of  host pools for the tenant
        Get-RdsHostPool -TenantName $TenantName | ForEach-Object {
            $HostPoolName = $_.HostPoolName
            Write-Host "Begin deleting host pool:" $HostPoolName
            # Pull the list of app groups
            Get-RdsAppGroup -TenantName $TenantName -HostPoolName $HostPoolName | ForEach-Object {
                $AppGroupName = $_.AppGroupName
                Write-Host "Begin deleting app group:"$AppGroupName
                # Pull a list of published apps
                Get-RdsRemoteApp -TenantName $TenantName -HostPoolName $HostPoolName -AppGroupName $AppGroupName | ForEach-Object {
                    $App = $_.AppAlias
                    Write-Host "Begin deleting app:"$App
                    # Remove the published app
                    Remove-RdsRemoteApp -TenantName $TenantName -HostPoolName $HostPoolName -AppGroupName $AppGroupName -Name $App
                    Write-Host $App"deleted"
                }
                # Remove the app group
                Remove-RdsAppGroup -TenantName $TenantName -HostPoolName $HostPoolName -Name $AppGroupName
                Write-Host $AppGroupName"deleted"
            }
            
            # Pull a list of session hosts for the host pool 
            Get-RdsSessionHost -TenantName $TenantName -HostPoolName $HostPoolName | ForEach-Object {
                $SessionHostName = $_.SessionHostName
                Write-Host "Begin deleting session host:"$SessionHostName
                # Remove the session host
                Remove-RdsSessionHost -TenantName $TenantName -HostPoolName $HostPoolName -Name $SessionHostName
                Write-Host $SessionHostName"deleted"
            }
            # Remove the host pool
            Remove-RdsHostPool -TenantName $TenantName -Name $HostPoolName
            Write-Host $HostPoolName"deleted"
        }
        # Remove the tenent
        Remove-RdsTenant -Name $TenantName
        Write-Host $TenantName"deleted"
    }
}

#Destroy-WVD <YOUR_WVD_TENANT_NAME>