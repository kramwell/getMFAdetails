#Written by KramWell.com - 14/JUL/2020
#Output MFA details of all users in Microsoft365 and their preferred multi-factor method

$LogTime = Get-Date -Format "MM-dd-yyyy_HH-mm-ss"
$CSVFile = "MFAdetails(" + $LogTime + ").csv"

Connect-MsolService

$vUser = Get-MsolUser -All -ErrorAction SilentlyContinue
If ($vUser) {

    $OutArray = @()

    Foreach ($EachUser in $vUser)
    {

	    $myobj = "" | Select UserPrincipalName, PhoneNumber, Email, OneWaySMS, PhoneAppOTP, PhoneAppNotification

	    $myobj.UserPrincipalName = $EachUser.UserPrincipalName
        $myobj.PhoneNumber = $EachUser.StrongAuthenticationUserDetails.PhoneNumber
        $myobj.Email = $EachUser.StrongAuthenticationUserDetails.Email
		
		#$myobj.FirstName.SubString(0,2) = $EachUser.FirstName
		
		# Write-host "Authentication Methods:"
		for ($i=0;$i -lt $EachUser.StrongAuthenticationMethods.Count;++$i){
			$methodType = $EachUser.StrongAuthenticationMethods[$i].MethodType

			if ($methodType -eq "OneWaySMS"){
				$myobj.OneWaySMS = $EachUser.StrongAuthenticationMethods[$i].IsDefault
			}elseif ($methodType -eq "PhoneAppOTP"){
				$myobj.PhoneAppOTP = $EachUser.StrongAuthenticationMethods[$i].IsDefault
			}elseif ($methodType -eq "PhoneAppNotification"){
				$myobj.PhoneAppNotification = $EachUser.StrongAuthenticationMethods[$i].IsDefault
			}

			# Write-host $EachUser.StrongAuthenticationMethods[$i].MethodType "(" $EachUser.StrongAuthenticationMethods[$i].IsDefault ")"
		}

	    # Add the object to the out-array
	    $OutArray += $myobj

	    # Wipe the object just to be sure
	    $myobj = $null

    }

}

$OutArray = $OutArray | Sort-Object -Property @{Expression = "UserPrincipalName"}

#$OutArray >>  $CSVFile

$OutArray | Export-Csv -Path .\$CSVFile -UseCulture -NoTypeInformation

$OutArray | FL

Write-Host File saved!