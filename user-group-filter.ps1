param([string]$domainName = 'tdbg-domain')
#filter based on the domain
#$users = Get-ADUser -Filter * -SearchBase 'DC=td-root-domain,DC=local' -Properties *
$users = Get-ADUser -Filter * -Properties *

$OFS = " "
[string]$domain_file_data = Get-Content ".\expected_groups\$domainName.txt"
[System.Collections.ArrayList]$expected_groups = $domain_file_data.Split(" ");
$display_result = New-Object System.Collections.ArrayList 
$export_data = @()

foreach($user in $users) {
    $present_groups = New-Object System.Collections.ArrayList
    $groups = $user.MemberOf
    
    foreach($group in $groups){
        [void]$present_groups.Add($group.Split(",")[0].Split("=")[1])
    }

    [System.Collections.ArrayList] $expected_groups_copy = @($expected_groups)
    [System.Collections.ArrayList] $present_groups_copy = @($present_groups)

    foreach($present_group in $present_groups){
        if($expected_groups.contains($present_group)){ 
            $present_groups_copy.Remove($present_group)
            $expected_groups_copy.Remove($present_group)
        }
    }

    $display_result += , [pscustomobject] @{User_Name=$user.Name; Not_Required_Groups=$present_groups_copy; Required_Groups=$expected_groups_copy}
    
    $OFS = "`r`n"
    $details = @{User_Name=$user.Name
     Not_Required_Groups= "$present_groups_copy" 
     Required_Groups="$expected_groups_copy" 
     }
    $OFS = " "
    $export_data += New-Object psobject -Property $details
}

#output data to screen
$display_result | ForEach {[PSCustomObject]$_} | Format-Table -AutoSize
$export_data | Export-Csv -Path  .\user-group-summary.csv -NoTypeInformation
