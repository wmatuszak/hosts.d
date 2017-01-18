# hosts.d

This project is a set of Powershell scripts to automatically
generate local hosts files for Windows.

## Download Latest Version

Code located in the `master` branch is under development (for now).

- [Download [zip]](https://github.com/wmatuszak/hosts.d/archive/master.zip)

## Execution

Enable execution of PowerShell scripts:

    PS> Set-ExecutionPolicy Unrestricted

Execute the installation script as Admin:

    PS > .\Install-Managaged-Hosts-File.ps1

## Usage 
	
	Simply add files to the directories listed with the extension ".hosts" and they will be appended to the hosts file.
	
## Structure 

* C:\Windows\System32\drivers\etc\hosts.d
 * Update-HostsFile.ps1 : The main script. This generates the hosts file given the source files in the directories listed below.
 * hosts.cache : A XML object containing the MD5 sums of the hosts files that were last processed.
 * base.hosts : Base hosts file. Generated at setup time from the existing hosts file.
 * xxxx.hosts : Static hosts file. Contents are appended during generation.
 * xxxx.dhosts : Dynamic hosts file. Contains a URL to a hosts file to be downloaded and appended during generation.
			
* Install-Managaged-Hosts-File.ps1 - Setup Script
 * Creates directories
 * Places main script
 * Creates scheduled task
 * Creates base.hosts 

## Liability

**All scripts are provided as is and you use them at your own risk.**

## Contribute

Just open an issue or send me a pull request.

## License

    "THE BEER-WARE LICENSE" (Revision 42):

    As long as you retain this notice you can do whatever you want with this
    stuff. If we meet some day, and you think this stuff is worth it, you can
    buy us a beer in return.

    This project is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.
