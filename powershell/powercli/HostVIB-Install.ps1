<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Install VIB on an ESXi host
#>

# Define Variables
$Cluster = "Cluster"
$viburl = "https://global.download.synology.com/download/Tools/NFSVAAIPlugin/1.1-1004/VMware_ESXi/synonfs-vaai-plugin-1.1-1004.vib"
#$viburl = "/vmfs/volumes/NFS01/Patches/VIBs/6.5/synonfs-vaai-plugin-1.1-1004.vib"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential
$nosigcheck = $true
$maintenancemode = $false
$force = $false
$dryrun = $false

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

    Write-Host "`nPreparing $($_.Name) for esxcli" -F Yellow

    $esxcli = Get-EsxCli -VMHost $_ -V2

    # Install VIBs
    Write-Host "Installing VIB on $($_.Name)" -F Yellow

		# Create Installation Arguments
		$insParm = @{
			viburl = $viburl
			dryrun = $dryrun
			nosigcheck = $nosigcheck
			maintenancemode = $maintenancemode
			force = $force
		}

	$action = $esxcli.software.vib.install.Invoke($insParm)

	# Verify VIB installed successfully
	if ($action.Message -eq "Operation finished successfully."){Write-Host "Action Completed successfully on $($_.Name)" -F Green} else {Write-Host $action.Message -F Red}
}

# Disconnect from vCenter
Disconnect-VIServer -Server * -Force -Confirm:$false
