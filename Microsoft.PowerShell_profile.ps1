#PowerShell Profile
#Kenny Lowe 2017
#Updated 15/08/2017

Import-Module Write-ASCII
Import-Module AzureRM

cd "C:\Users\Kenny\OneDrive - KennyLowe\Source Control\Scripts"

$username = "kenny@kennylowe.org"
$pwdTxt = Get-Content ".\ExportedPassword.txt"
$SecurePwd = $pwdTxt | ConvertTo-SecureString
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $SecurePwd

Login-AzureRMAccount -SubscriptionId b8f0035f-44e8-49af-ba68-9c7b8177e367 -Credential $credObject

If($Host.UI.RawUI.WindowTitle -like "*administrator*")
{
	Write-ASCII "Administrator" -Fore Green
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
  $realLASTEXITCODE = $LASTEXITCODE

  Write-Host($pwd.ProviderPath) -nonewline

  Write-VcsStatus

  $global:LASTEXITCODE = $realLASTEXITCODE
  return "> "
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
    # Write the time 
    write-host "[" -noNewLine
    write-host $(Get-Time) -foreground yellow -noNewLine
    write-host "] " -noNewLine
    # Write the path
    write-host $($(Get-Location).Path | Split-Path -Leaf) -foreground green -noNewLine
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
    return "> "
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
