    #$DefaultTranscriptFile = "$(Get-Location)\MBXScans\MBXScanTranscript$(Get-Date).txt"
    #Start-Transcript -Path $DefaultTranscriptFile
    Connect-ExchangeOnline
    $EmailPass = Read-Host "Enter LandryLabs.Bot password"
    $Mailbox = (get-mailbox | sort -property primarysmtpaddress).primarysmtpaddress
    $MailboxCount = $Mailbox.Count
    $i = 1;
    Write-Host "Total Mailboxes: $MailboxCount"
    $UnhealthyMBXArray90 = @();
    $HealthyMBXArray80 = @();
    $HealthyMBXArray70 = @();
    $HealthyMBXArray60 = @();
    $HealthyMBXArray50 = @();
    $HealthyMBXArray40 = @();
    $HealthyMBXArray30 = @();
    $HealthyMBXArray20 = @();
    $HealthyMBXArray10 = @();
    $HealthyMBXArray00 = @();
    $ForwardingAddressArray = @();
    $ForwardingSMTPAddressArray = @();
    foreach ($user in $Mailbox)
        {
            #Fetching mailbox used size and rebuilding the bytes value to be used in calculations#
            $MailboxUsedSize = (get-mailboxstatistics -Identity $user).totalitemsize.value;
            $NewUsedSize = "$MailboxUsedSize"
            $NewUsedSizeSplit = $NewUsedSize.Split(" "); #Splitting into an array to focus into the byte size easier.
            #$UsedSizeStageTwo = $NewUsedSizeSplit[0]
            $UsedSizeStageTwo = $NewUsedSizeSplit[2].Substring(1); #New string removing the '(' character.
            $UsedSizeStageTwoSplit = $UsedSizeStageTwo.Split(","); #Splitting using comma delimmiter to kill the commas.
            $MBUsedSizeFinal = $UsedSizeStageTwoSplit[0]+$UsedSizeStageTwoSplit[1]+$UsedSizeStageTwoSplit[2]+$UsedSizeStageTwoSplit[3]; #Re-joining the array into a string capable of calculations.
            #$MBUsedSizeFinal = $UsedSizeStageTwo;

            #Fetching mailbox total size and rebuilding the bytes value to be used in calculations#
            $MailboxTotalSize = (get-mailbox -Identity $user).ProhibitSendReceiveQuota;
            $NewTotalSize = "$MailboxTotalSize"
            $NewTotalSizeSplit = $NewTotalSize.Split(" "); #Splitting into an array to focus into the byte size easier.
            #$TotalSizeStageTwo = $NewTotalSizeSplit[0]
            $TotalSizeStageTwo = $NewTotalSizeSplit[2].Substring(1); #New string removing the '(' character.
            $TotalSizeStageTwoSplit = $TotalSizeStageTwo.Split(","); #Splitting using comma delimmiter to kill the commas.
            $MBTotalSizeFinal = $TotalSizeStageTwoSplit[0]+$TotalSizeStageTwoSplit[1]+$TotalSizeStageTwoSplit[2]+$TotalSizeStageTwoSplit[3]; #Re-joining the array into a string capable of calculations.
            #$MBTotalSizeFinal = $TotalSizeStageTwo

            #Fetching mailbox deleted size#
            $MailboxDeletedSize = (get-mailboxstatistics -Identity $user).totaldeleteditemsize.Value;

            #Information below used to send email alert#
            $PasswordEmail = ConvertTo-SecureString $EmailPass -AsPlainText -Force
            $From = "landrylabs.bot@sparkhound.com";
            $To = "daniel.landry@sparkhound.com";
            $Port = 587
            $Subject = "Exchange Monitoring Alert [Mailbox Is Over 90% Full]"
            $SMTPserver = "smtp.office365.com"
            $Cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $from, $PasswordEmail
            $Signature = "`n`nThank you,`nLandryLabs`nMonitoring Assistant."
            
            $AvailCapacity = $MBUsedSizeFinal/$MBTotalSizeFinal
            if ($MBUsedSizeFinal/$MBTotalSizeFinal -ge .90)
                {   
                    $UnhealthyMBXArray90 += "$user";
                    Write-Host "$i/$MailboxCount | $AvailCapacity | DANGER! User: $user";
                    $Subject = "Exchange Monitoring Alert [Mailbox Is Over 90% Full]"
                    $EmailBody = "===================`n"
                    $EmailBody = ($EmailBody +"$user `n"); 
                    $EmailBody = ($EmailBody +"Used: "+$MailboxUsedSize+"`n");
                    $EmailBody = ($EmailBody +"Deleted: "+$MailboxDeletedSize+"`n");
                    $EmailBody = ($EmailBody +"Total: "+$MailboxTotalSize+"`n");
                        if ((get-mailbox -Identity $user).ArchiveStatus -eq 'None') #'None' value mostly confirms that an archiving mailbox does't exist. Skips attempting to fetch that info if so.
                            {
                                $EmailBody = ($EmailBody +"Archive Mailbox not enabled.`n");
                            }
                        elseif ((get-mailbox -identity $user).ArchiveStatus -eq 'Active') #'Active' mostly confirms an archive mailbox exists and is active. Fetches archive mailbox info.
                            {
                                $EmailBody = ($EmailBody +"Archive: "+(get-mailbox -Identity $user).ArchiveStatus);
                                $EmailBody = ($EmailBody +"Archive Used: "+(get-mailboxstatistics $user -Archive).totalitemsize.Value);
                                $EmailBody = ($EmailBody +"Archive Deleted: "+(get-mailboxstatistics $user -Archive).totaldeleteditemsize.Value);
                            }
                    $EmailBody = ($EmailBody +"===================`n")
                    Send-MailMessage -from $From -To $To -Subject $Subject -Body "$EmailBody`n$signature" -SmtpServer $SMTPserver -Credential $Cred -Verbose -UseSsl -Port $Port
                }
            elseif ($AvailCapacity -lt .90 -and $AvailCapacity -ge .80)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray80 += "$user";
                }
            elseif ($AvailCapacity -lt .80 -and $AvailCapacity -ge .70)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray70 += "$user";
                }
            elseif ($AvailCapacity -lt .70 -and $AvailCapacity -ge .60)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray60 += "$user";
                }
            elseif ($AvailCapacity -lt .60 -and $AvailCapacity -ge .50)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray50 += "$user";
                }
            elseif ($AvailCapacity -lt .50 -and $AvailCapacity -ge .40)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray40 += "$user";
                }
            elseif ($AvailCapacity -lt .40 -and $AvailCapacity -ge .30)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray30 += "$user";
                }
            elseif ($AvailCapacity -lt .30 -and $AvailCapacity -ge .20)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray20 += "$user";
                }
            elseif ($AvailCapacity -lt .20 -and $AvailCapacity -ge .10)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray10 += "$user";
                }
            elseif ($AvailCapacity -lt .10 -and $AvailCapacity -ge .01)
                {
                    Write-Host "$i/$MailboxCount | $AvailCapacity | HEALTHY";
                    $HealthyMBXArray00 += "$user";
                }
        $ActiveForwarding = (Get-Mailbox -identity $user).ForwardingAddress
        $ActiveSMTPForwarding = (Get-Mailbox -identity $user).ForwardingSMTPAddress
        $MailboxUserType = (Get-Mailbox -identity $user).RecipientTypeDetails
        
        if ($ActiveForwarding -ne $Null)
            {
                switch ($MailboxUserType)
                    {
                        UserMailbox {$ForwardingAddressArray += "$user forwarding to $ActiveForwarding (User MBX)"}
                        SharedMailbox {$ForwardingAddressArray += "$user forwarding to $ActiveForwarding (Shared MBX)"}
                    }
            }
        if ($ActiveSMTPForwarding -ne $Null)
            {
                switch ($MailboxUserType)
                    {
                        UserMailbox {$ForwardingSMTPAddressArray += "$user forwarding to $ActiveSMTPForwarding (User MBX)"}
                        SharedMailbox {$ForwardingSMTPAddressArray += "$user forwarding to $ActiveSMTPForwarding (Shared MBX)"}
                    }
            }   
        $i++
        }
        #Stop-Transcript

        Write-Host "MBX's over 90% capacity: "
        $UnhealthyMBXArray90
        Write-Host "==============================`n"
        Write-Host "MBX's over 80% capacity: "
        $HealthyMBXArray80
        Write-Host "==============================`n"
        Write-Host "MBX's over 70% capacity: "
        $HealthyMBXArray70
        Write-Host "==============================`n"
        Write-Host "MBX's over 60% capacity: "
        $HealthyMBXArray60
        Write-Host "==============================`n"
        Write-Host "MBX's over 50% capacity: "
        $HealthyMBXArray50
        Write-Host "==============================`n"
        Write-Host "MBX's over 40% capacity: "
        $HealthyMBXArray40
        Write-Host "==============================`n"
        Write-Host "MBX's over 30% capacity: "
        $HealthyMBXArray30
        Write-Host "==============================`n"
        Write-Host "MBX's over 20% capacity: "
        $HealthyMBXArray20
        Write-Host "==============================`n"
        Write-Host "MBX's over 10% capacity: "
        $HealthyMBXArray10
        Write-Host "==============================`n"
        Write-Host "MBX's under 10% capacity: "
        $HealthyMBXArray00
        Write-Host "==============================`n"
        Write-Host "Active Forwarding:"
        $ForwardingAddressArray
        Write-Host "==============================`n"
        Write-Host "Active SMTP Forwarding:"
        $ForwardingSMTPAddressArray
        