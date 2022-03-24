Param(
    [string] $OUdn="OU=contoso,DC=responsability,DC=local",
    [string] $threshold="-12",
    [string] $smtpserver="mail.contoso.local",
    [string] $mailsender="noreply@contoso.com",
    [string] $recipient="gregory.casanova@contoso.com"
)

$html_head = "<head><style type='text/css'>
table {font-family:verdana,arial,sans-serif;font-size:12px;color:#333333;border-width: 1px;border-color: #729ea5;border-collapse: collapse;}
th {font-family:verdana,arial,sans-serif;font-size:12px;background-color:#acc8cc;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;}
tr {font-family:verdana,arial,sans-serif;background-color:#d4e3e5;}
td {font-family:verdana,arial,sans-serif;font-size:12px;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;}
</style></head>"

$bodystart = "<body>Source : Automation Account <br> <table>
<tr><td><b>Account Name</b></td><td><b>Password Age (days)</b></td><td><b>DistinguishedName</b></td></tr>"


$bodymiddle =@()

$ADaccounts=Get-ADUser -filter 'Enabled -eq "True"' -SearchBase $OUdn -SearchScope Subtree -property "PwdLastSet" | where-object {([datetime]::FromFileTime($_.pwdLastSet)) -lt ((Get-Date).AddMonths($threshold))}

if ($ADaccounts) {
    foreach ($ADaccount in $ADaccounts) {

        $passwordage = ((get-date)-([datetime]::FromFileTime($ADaccount.pwdLastSet))).days
        $adaccountname = $ADaccount.name
        $adaccountdn = $ADaccount.distinguishedname

        $bodymiddle = $bodymiddle + "<tr><td>$adaccountname</td><td>$passwordage</td><td>$adaccountdn</td></tr>"
        
    }
    
    $bodyend = "</table></body>"
    $bodycompleted = $html_head + $bodystart + $bodymiddle + $bodyend
    
    Write-Output $bodycompleted

    Send-MailMessage -from $mailsender -to $recipient -Subject "Service accounts Password Age report" -Body $bodycompleted -BodyAsHtml -Priority High -SmtpServer $smtpserver

}