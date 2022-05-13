account_name="mydomain.local\admin"
account_password="MySecretPassword"
SERVER_AD01="myserverAD01"
nbServers=20

echo '$command_list = New-Object System.Collections.ArrayList' >> blockNewConnections.ps1
echo '$command_list.Add("Set-RDActiveManagementServer -ManagementServer server01.mydomain.local")' >> blockNewConnections.ps1
echo '$command_list.Add("Get-RDConnectionBrokerHighAvailability -ConnectionBroker server01.mydomain.local")' >> blockNewConnections.ps1
for i in $(seq 0 $[${nbServers}-1]); do
    echo "\$command_list.Add('Set-RDSessionHost -SessionHost remoteserver{i}.mydomain.local -NewConnectionAllowed No -ConnectionBroker server01.mydomain.local')" >> blockNewConnections.ps1
done
echo "\$securePassword = ConvertTo-SecureString '${account_password}' -AsPlainText -force" >> blockNewConnections.ps1
echo "\$credential = New-Object System.Management.Automation.PsCredential('${account_name}',\$securePassword)" >> blockNewConnections.ps1
echo 'Invoke-Command -Credential $credential -ComputerName . -ScriptBlock {param([array]$command_list) foreach ($element in $command_list) {Invoke-Expression $element} } -ArgumentList (,$command_list)' >> blockNewConnections.ps1
az vm run-command invoke --command-id RunPowerShellScript -g $RG -n "$SERVER_AD01" --scripts @blockNewConnections.ps1
