#PowerShell Profile
#Kenny Lowe 2017-2018
#Updated 18/01/2018

Import-Module Write-ASCII

#Username for Azure Login
$username = "email@address.com"
#Store Password encrypted in a file somewhere
$pwdTxt = Get-Content ".\ExportedPassword.txt"
$SecurePwd = $pwdTxt | ConvertTo-SecureString
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePwd
#Sub you want to login to
$SubscriptionID = your-subscription-id

$AzureLogin = Read-Host "Login to Azure? (Y/N)"
while("Y","N","Yes","No" -notcontains $AzureLogin)
{
    $AzureLogin = Read-Host "Login to Azure? (Y/N)"
}

If ($AzureLogin -eq "Y") 
{ 
	Import-Module AzureRM
	Login-AzureRMAccount -SubscriptionId $SubscriptionID -Credential $credObject 
	Get-AzureRmProviderFeature -FeatureName AllowArchive -ProviderNamespace  Microsoft.Storage
}

If($Host.UI.RawUI.WindowTitle -like "*administrator*")
{
	Write-ASCII "Administrator" -Fore Green
}

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

Import-Module posh-git

function global:prompt {
#  $realLASTEXITCODE = $LASTEXITCODE

#  Write-Host($pwd.ProviderPath) -nonewline

#  Write-VcsStatus

#  $global:LASTEXITCODE = $realLASTEXITCODE
# return "> "
}

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


#
# useful aggregate
#
function count
{
    BEGIN { $x = 0 }
    PROCESS { $x += 1 }
    END { $x }
}

function product
{
    BEGIN { $x = 1 }
    PROCESS { $x *= $_ }
    END { $x }
}

function sum
{
    BEGIN { $x = 0 }
    PROCESS { $x += $_ }
    END { $x }
}

function average
{
    BEGIN { $max = 0; $curr = 0 }
    PROCESS { $max += $_; $curr += 1 }
    END { $max / $curr }
}

function Get-Time { return $(get-date | foreach { $_.ToLongTimeString() } ) }

function prompt
{
#add global variable if it doesn't already exist

if (-Not $global:LastCheck) 
{
	$global:LastCheck = Get-Date
    	$global:cdrive = Get-CimInstance -query "Select Freespace,Size from win32_logicaldisk where deviceid='c:'"

}



#only refresh disk information once every 15 minutes
$min = (New-TimeSpan $Global:lastCheck).TotalMinutes

if ($min -ge 15) 
{

    $global:cdrive = Get-CimInstance -query "Select Freespace,Size from win32_logicaldisk where deviceid='c:'"
    $global:LastCheck = Get-Date
}

$diskinfo = "{0:N2}" -f (($global:cdrive.freespace/1gb)/($global:cdrive.size/1gb)*100)

#only the get the CIM properties we need to cut down on processing time
$cpu = (Get-CimInstance -ClassName win32_processor -property loadpercentage).loadpercentage

#get the number of running processes
$pcount = (Get-Process).Count
$os = Get-CimInstance -class Win32_OperatingSystem -Property LastBootUpTime,TotalVisibleMemorySize,FreePhysicalMemory

#calculate the percentage of free physical memory
$freeMem = $os.freephysicalmemory/1mb

#get uptime
$time = $os.LastBootUpTime
[TimeSpan]$uptime = New-TimeSpan $time $(get-date)

#construct an uptime string e.g. 13d 15h 18m 38s
$up = "$($uptime.days)d $($uptime.hours)h $($uptime.minutes)m $($uptime.seconds)s"

#this is the text to appear in the status box
$text="CPU:{0}% FreeMem:{6:n2}GB Procs:{1} Free C:{2}% {3}{4} {5}"  -f $cpu.ToString().padleft(2,"0"),$pcount,$diskinfo,([char]0x25b2),$up,(Get-Date -format G),$FreeMem

#display prompt data in color based on the amount of free memory
$pctFreeMem = $os.FreePhysicalMemory/$os.TotalVisibleMemorySize

if ($pctFreeMem -ge .50) {
    $color = "green"
}

elseif ($pctFreeMem -ge .20) {
    $color = "yellow"
}

else {
    $color = "red"
}

#write the status box with an appropriate outline color
Write-Host $([char]0x250c) -NoNewline -ForegroundColor $color
Write-Host $(([char]0x2500).ToString()*$text.length ) -ForegroundColor $color -NoNewline
Write-Host $([char]0x2510) -ForegroundColor $color
Write-Host $([char]0x2502) -ForegroundColor $color -NoNewline
Write-Host $text -NoNewline
Write-Host $([char]0x2502) -ForegroundColor $color
Write-Host $([char]0x2514) -ForegroundColor $color -NoNewline
Write-Host $(([char]0x2500).ToString()*$text.length) -NoNewline -ForegroundColor $color
Write-Host $([char]0x2518) -ForegroundColor $color



#write a prompt to the host
    write-host "[" -noNewLine
    write-host $(Get-Time) -foreground yellow -noNewLine
    write-host "] " -noNewLine
    # Write the path
    write-host $($(Get-Location).Path | Split-Path -Leaf) -foreground green -noNewLine
   write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine

return ""
}

function LL
{
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }

    foreach ($Item in $toList)  
    { 
        Switch ($Item.Extension)  
        { 
            ".exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
            ".msh" {$host.ui.rawui.foregroundColor = "Red"} 
            ".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
            Default {$host.ui.rawui.foregroundColor = $origFg} 
        } 
        if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
        $item 
    }  
    $host.ui.rawui.foregroundColor = $origFg 
}

function lla
{
    param ( $dir=".")
    ll $dir $true
}

function la { ls -force }

# behave like a grep command
# but work on objects, used
# to be still be allowed to use grep
filter match( $reg )
{
    if ($_.tostring() -match $reg)
        { $_ }
}

# behave like a grep -v command
# but work on objects
filter exclude( $reg )
{
    if (-not ($_.tostring() -match $reg))
        { $_ }
}

# behave like match but use only -like
filter like( $glob )
{
    if ($_.toString() -like $glob)
        { $_ }
}

filter unlike( $glob )
{
    if (-not ($_.tostring() -like $glob))
        { $_ }
}


write-ascii "Transcript logging..." -Fore Green
write-host ""
$Transcript = Start-Transcript -OutputDirectory "C:\Users\kenny\OneDrive\Documents\WindowsPowerShell\Transcripts\"
write-host $Transcript -ForegroundColor "Green"
write-host ""

Function funcOpenPowerShellProfile
{
    Notepad $PROFILE
}

Set-Alias fop funcOpenPowerShellProfile

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
