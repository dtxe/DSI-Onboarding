
function Confirm-ExistAndVersion {
    # Helper function to determine if a required package is installed and if it is the correct version
    param (
        [string]$command,
        [string]$version
    )

    $cmdexist = Get-Command $command -ErrorAction SilentlyContinue
    if (!$cmdexist) {
        return $false
    }

    # if no version specified, then just check if command exists
    if ((!$version) -or ($version -eq "")) {
        return $true
    }

    $command_version = Invoke-Expression "$command --version" | Out-String
    $command_version = [regex]::Replace($command_version, "[^\.0-9]", "")
    $command_version = [regex]::Replace($command_version, "\.\.", ".")

    if ([System.Version]$command_version -lt [System.Version]$version) {
        return $false
    }

    return $true
}

# PREREQUISITE: winget
Write-Output ">>> winget <<<"
if (!(Confirm-ExistAndVersion winget 1.6)) {
    Write-Warning "winget version 1.6 or newer is required to install the course software. Please update App Installer in the Microsoft Store and try running this script again."
    Read-Host -Prompt “Press ENTER to quit...”
    exit 1
} 


###################################################################################
# install windows terminal
Write-Output ">>> Windows Terminal <<<"
if (Confirm-ExistAndVersion wt) {
    Write-Host "Windows Terminal: Installed"
}
else {
    Write-Host "Windows Terminal: ... installing!"
    winget install --id Microsoft.WindowsTerminal -e -s winget --accept-source-agreements --accept-package-agreements
}

###################################################################################
# check for git
Write-Output ">>> Git <<<"
if (Confirm-ExistAndVersion git 2.39) {
    Write-Host "Git: Installed"
}
else {
    Write-Host "Git: ... installing!"
    winget install --id Git.Git -e -s winget --accept-source-agreements --accept-package-agreements
}

###################################################################################
# update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 

# NOTE: Git Bash is now auto detected by Windows Terminal and manual installation is no longer required (and would be redundant)

###################################################################################
# check for vscode
Write-Output ">>> VSCode <<<"
if (Confirm-ExistAndVersion code) {
    Write-Host "VSCode: Installed"
}
else {
    Write-Host "VSCode: ... installing!"
    winget install --id Microsoft.VisualStudioCode -e -s winget --accept-source-agreements --accept-package-agreements
}

# update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 

# install remote/wsl extension    
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension mhutchie.git-graph


###################################################################################
# install Anaconda
$userprofile = [System.Environment]::GetFolderPath("UserProfile")
$minicondabin = $userprofile + '\miniconda3\python.exe'
$anacondabin = $userprofile + '\anaconda3\python.exe'

Write-Output ">>> Anaconda <<<"
if (Confirm-ExistAndVersion $minicondabin -or (Confirm-ExistAndVersion $anacondabin)) {
    Write-Host "Anaconda: Installed"
}
else {
    Write-Host "Anaconda: ... installing!"
    Invoke-WebRequest https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -out miniconda.exe
    Start-Process miniconda.exe -Wait "/InstallationType=JustMe /S /D=$userprofile\miniconda3"
    Remove-Item miniconda.exe
}

# initialize anaconda
$userprofile = [System.Environment]::GetFolderPath("UserProfile")
$conda_hook = $userprofile+'\miniconda3\shell\condabin\conda-hook.ps1'
& $conda_hook
conda activate
conda init bash

# install python packages
Write-Host "Python packages: Checking and installing required packages"
conda install -y matplotlib numpy pandas scipy scikit-learn seaborn jupyter pyyaml plotly conda-forge::python-kaleido requests openpyxl nbformat pytest


###################################################################################
# install db browser for sqlite
# NOTE: sql may not happen for Cohort #2, so commenting out for now.

# Write-Output ">>> DB Browser for SQLite <<<"
# if (Confirm-ExistAndVersion dbbrowser) {
#     Write-Host "DB Browser for SQLite: Installed"
# }
# else {
#     Write-Host "DB Browser for SQLite: ... installing!"
#     winget install --id DB.Browser.for.SQLite -e -s winget --accept-source-agreements --accept-package-agreements
# }



###################################################################################
Write-Output @"
MMMMMMMMMMMWWMWWWK0kodo,ll.;d; .cd,'xOodKXXWMMMMMMMMMMMMMMMM
MMMMMMMMWWWWWXkl;.....'..'...'.......'..,;,:okXWMMMMMMMMMMMM
MMMMMMMMWWNOlo:.c;'l;'o;.ll.;dd;.co'.::.'c,.';,oKNWMMMMMMMMM
MMMMMMMWKo:..''.'.............,...'..''..:,.,;..;:dKWMWWMMMM
MWMMMWXk:.,'.::.;:.:l.,o,.c:.;do'.c:.'c'.::..,.....;dXWWMMMM
MMMWWk;'..'..'..',..,..'...'...'...'..'..,,..'.......:ONMMMM
MMMXd'.,'.;,.,'.:c.,l,.cc.'c'.,cc.'c'.:;.',...........;OWMMM
MMKc'..,'.'..''..,..;'.',..,'...'..'..................';oXMM
WK:.'..,'.''.''.':..c;.':..l:. ':..:;.',.',........';';,'dXW
Nx'.,'.,'.,,.;:.';'.;:..;'.',. .;,',,..............,,';..:xN
k,..'..'..c0KXNKKXK0XXl,;'.,lllkNXXNXK0x;'..d000Oc.;,':.'c:k
c,..,'.,'.lNMMMWWWWWWMWKd;.,kNWMMNKXNWMWXl.'OWWMXc':.':..;.c
'...'.....:XMMW0c:co0WWWWk.lWMWMWx'';lkdl;.'kWWMX:.;..,..,.'
.,..;'.,'.:XMMMk.':.,0MWWK;;KMMMWXOxllc....,0WWMK;,l.'c.':..
.'..'..''.:XWMMk..'..xMWWX:.:k0KWWWWMMN0x:.,0WWWK;.,..,..'..
.,..,..,;.:XWMMO'.;.'OWMWK:.,'.'looxONMWWKocOMWWK;,c.':..,..
',..,,..,.;KMWMO,.,ckNWWWk,,coxko'...dNWMWk:kMWWK;.'..'..'.'
;'..''..,.;KMMMWXKNWWMWXx:'lXWMWWKkdxKWMWKl;kMWWK;';..,..,.:
d;'.';..;':0WWWWWNWNK0O:.'..lOOKNWWMMWWNkl:,kWNW0;';..,.',.o
0c...'.....,;;;;;;;;..'..'.....';clllc;;.',.,:;;,..,..'..,:K
W0:..;..,;..;'.',..;..,..'..........;',:.;:.,;.,;.',.',.'l0W
WWx..'...'......'..................',.',.''..'.....'..'.,0MM
MMWk,,,..;..,,..;..;..,..........;',;.::.,;.,;.',.,;.',;kWMM
MMMW0l,..'......'.............'.',.,'.,'....''........l0WMMM
MMMMMW0;.,'..,..,..,..'......,:',;.;,.;;.''.,,.''.',;OWWMMMM
MMMMMMWKd:,..,..'..'........',..;,.:;.;,.,,.,,.,'.;dKWMMMMMM
MMMMMMMMWN0c''..'...........',..''.,'.''.''.''.;dkXMWMMMMMMM
MMMMMMMMMMMN0d:;,........';':;..c;.l;.:''c,'lod0WMMMMMMMMMMM
MMMMMMMMMMMMMMWXOoc;.....''.,. .'..'..;,cOk0WMWWMMMMMMMMMMMM
MMMMMMMMMMMMMMMMWWWXOdl:;oc;xc.,d:,l:lxOXWWWMMMMMMMMMMMMMMMM


################# INSTALLATION COMPLETE! ###################


"@
