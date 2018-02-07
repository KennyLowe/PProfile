#PowerShell Profile
#Kenny Lowe 2017-2018
#Updated 21/01/2018


Import-Module Get-ChildItemColor
Import-Module Write-ASCII
Import-Module Oh-My-Posh

Set-Theme Agnoster

cd "Some folder"

$username = "email@address.com"
$pwdTxt = Get-Content ".\ExportedPassword.txt"
$SecurePwd = $pwdTxt | ConvertTo-SecureString
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePwd
$SubscriptionID = "your subscription"
$TranscriptDir = [string]"C:\Users\Username\Documents\WindowsPowerShell\Transcripts\"

$AzureLogin = Read-Host "Login to Azure? (Y/N)"
While("Y","N","Yes","No" -notcontains $AzureLogin)
{
    $AzureLogin = Read-Host "Login to Azure? (Y/N)"
}

If ($AzureLogin -eq "Y") 
{ 
	Import-Module AzureRM
	Login-AzureRMAccount -SubscriptionId $SubscriptionID -Credential $credObject 
	Get-AzureRmProviderFeature -FeatureName AllowArchive -ProviderNamespace  Microsoft.Storage
}

Import-Module PSReadLine

Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4000
# history substring search
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Tab completion
Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

If($Host.UI.RawUI.WindowTitle -like "*administrator*")
{
	Write-ASCII "Administrator" -Fore Green
}

function prompt {
    $origLastExitCode = $LastExitCode
    Write-VcsStatus

#    Write-Host "$env:USERNAME@" -NoNewline -ForegroundColor DarkYellow
#    Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
#    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }

#    Write-Host $curPath -NoNewline -ForegroundColor Yellow
    Write-Host " : " -NoNewline -ForegroundColor Blue
    Write-Host (Get-Date -Format G) -ForegroundColor Magenta
    $LastExitCode = $origLastExitCode
    Write-Host $curPath -NoNewline -ForegroundColor Yellow
    return " >"
}

Import-Module posh-git

$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = '] '


function Test-IsPS32 
{
    $psfilename = (Get-Process -id $pid).mainmodule.filename
    if ($psfilename -match "SysWoW64") { $True }
    else { $False }
}

function banner
{
	write-host ""
	write-host ""
	write-ascii "Custom commands..." -Fore "Green"
	write-host ""
	write-host " ------------------------------------------------------------" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Start-NewScope " -ForegroundColor "Yellow"
	write-host -nonewline " | " -Foregroundcolor "Magenta"
	write-host -nonewline "Restart PowerShell with new Scope       " -ForegroundColor "Yellow" 
	write-host " |" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " LL              " -ForegroundColor "Yellow" 
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Colourised LS       " -ForegroundColor "Yellow"
	write-host "                     |" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " LA " -ForegroundColor "Yellow"
	write-host -nonewline "             |" -ForegroundColor "Magenta"
	write-host -nonewline " As above with -Force appended            " -ForegroundColor Yellow
	write-host "|" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Get-DriveSpace  "-ForegroundColor "Yellow"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Gets drive space                         " -ForegroundColor "Yellow"
	write-host "|" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Grep            " -ForegroundColor "Yellow" 
	write-host -nonewline "|" -ForegroundColor "Magenta" 
	write-host -nonewline " Poor man's Grep, better dropping to Bash " -ForegroundColor "Yellow"
	write-host "|" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Fix-Linebreaks  " -ForegroundColor "Yellow"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Changes all linebreaks to \r\n  " -ForegroundColor "Yellow"
	write-host "         |" -ForegroundColor "Magenta"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " FOP             " -ForegroundColor "Yellow"
	write-host -nonewline "|" -ForegroundColor "Magenta"
	write-host -nonewline " Edit PowerShell Profile         " -ForegroundColor "Yellow"
	write-host "         |" -ForegroundColor "Magenta"
	write-host " ------------------------------------------------------------" -ForegroundColor "Magenta"
	write-host ""
}

banner

function Start-NewScope 
{
cls
banner
 if ($Prompt -ne $null)
 { if ($Prompt -is [ScriptBlock])
 {
 $null = New-Item function:Prompt -Value $Prompt -force
 }else
 { function Prompt {$Prompt}
 }
 }
}
sal New-Scope Start-NewScope

function Test-DNSFlush
{
Param(
 [Parameter(Mandatory=$True)]
   [string]$url
)

Echo " ** Ctrl-C to Quit **"
$i=1
Do 
{
    ipconfig /flushdns
    Start-Sleep 10
    ping $url
}
While ($i=1)
}

function Fix-Linebreaks
{
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
    [string]$file
)

$OldFile = "$file"
$Path = Split-Path -Path $file
$Newfile = $Path + "\temp.txt"
Get-Content $OldFile | Set-Content -Path $NewFile
del $OldFile
move $NewFile $OldFile
Echo "   ** Completed **"
}

function Get-Time { return $(get-date | foreach { $_.ToLongTimeString() } ) }


write-ascii "Transcript logging..." -Fore Green
write-host ""
$Transcript = Start-Transcript -OutputDirectory $TranscriptDir
write-host $Transcript -ForegroundColor "Green"
write-host ""

Function funcOpenPowerShellProfile
{
    Notepad $PROFILE
}

Set-Alias fop funcOpenPowerShellProfile

Set-Alias ls Get-ChildItemColor -option AllScope
Set-Alias l Get-ChildItemColorFormatWide -option AllScope
Set-Alias dir Get-ChildItemColor -option AllScope
Set-Alias jit Invoke-Jit

function get-drivespace {
  param( [parameter(mandatory=$true)]$Computer)
  if ($computer -like "*.com") {$cred = get-credential; $qry = Get-WmiObject Win32_LogicalDisk -filter drivetype=3 -comp $computer -credential $cred }
  else { $qry = Get-WmiObject Win32_LogicalDisk -filter drivetype=3 -comp $computer }  
  $qry | select `
    @{n="drive"; e={$_.deviceID}}, `
    @{n="GB Free"; e={"{0:N2}" -f ($_.freespace / 1gb)}}, `
    @{n="TotalGB"; e={"{0:N0}" -f ($_.size / 1gb)}}, `
    @{n="FreePct"; e={"{0:P0}" -f ($_.FreeSpace / $_.size)}}, `
    @{n="name"; e={$_.volumeName}} |
  format-table -autosize
} #close drivespace

function Search-TextFile {
  param( 
    [parameter(mandatory=$true)]$File,
    [parameter(mandatory=$true)]$SearchText
  ) #close param
  if ( !(test-path $File) ) {"File not found:" + $File; break}
  $fullPath = resolve-path $file | select -expand path
  $lines = [system.io.file]::ReadLines($fullPath)
  foreach ($line in $lines) { if ($line -match $SearchText) {$line} }
} #end function Search-TextFile

Set-Alias grep Search-TextFile

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function U
{
    param
    (
        [int] $Code
    )
 
    if ((0 -le $Code) -and ($Code -le 0xFFFF))
    {
        return [char] $Code
    }
 
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF))
    {
        return [char]::ConvertFromUtf32($Code)
    }
 
    throw "Invalid character code $Code"
}

function invoke-jit
{
Import-Module Azure-Security-Center

# My RG

$resourceGroup = Read-Host "Resource Group?"

# VM that will be started after updating the NSG

$VMName = Read-Host "VM Name?"

# Get my Public IP

$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip

# Hours for access

[int]$hours = 3


# Get Sub Info and select Subscription

$SubscriptionName = Read-Host "Subscription Name?"

Select-AzureRmSubscription -SubscriptionName $SubscriptionName



# Request Access to the VM for current IP Address for RDP for 2 hours

Invoke-ASCJITAccess -ResourceGroupName $resourceGroup -VM $VMName -Port 3389 -Hours $hours -AddressPrefix $ip 

}

Set-Theme Agnoster
Import-Module PoShFuck
