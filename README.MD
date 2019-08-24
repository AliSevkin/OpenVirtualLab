# OpenVirtualLab for Hyper V on windows 10
Deploys windows 2016 and 2019 server Core and Desktop Experience editions on Hyper-V for Windows 10 (pro and enterprise edition). For testing
and learning purpose. (Don't use it in production Environment, this project uses differencing disks.).

## Getting Started
Download the .zip file, unblock the .zip file. Right click on properties of the zip file, go to the general tab, at the bottom you will se an option to select unblock, select this option and click on ok. Unzip the file. And rename the folder OpenVirtualLab-master to OpenvirtualLab.

### Prerequisites
You'll need:
* Windows 10 Pro, Enterprise or Education edition with Hyper-V feature installed. 
* 16GB of Ram.
* at least 50GB freespace on C:\ drive (or the drive where the programdata resides on), for preparing the parentdisk.
* Enough space for the destination of the parentdisk that will be created at least 50GB.
* Enough space for the destination for the projects with the virtual machines, depending on the amount of servers used. at least 50GB.
* If all destination files will be on the same disk you need at least 150GB free of disk space.
* You'll need at least SSD disk(s), or very fast hd disk in raid5 or a hybride disk to get the full performance of the script.

### Installing.
Copy the OpenVirtualLab folder (that you have unziped and renamed), to the next location (asuming that your windows installation is on C:\ Drive). C:\Program Files\WindowsPowershell\Modules.
After copying the module you need to use Import-Module OpenVirtualLab.
after importing the module, you get access to 2 new functions.
New-OvDiskTemplate
and
New-OvLabDeploy


```
 Copy files to the location => C:\Program Files\WindowsPowershell\Modules\OpenvirtualLab

 Import-Module OpenVirtualLab
```

to see the examples and helpfiles for the functions.  Use help or get-help

```
 Help New-OvDiskTemplate    

 Help New-OvLabDeploy
```
To use the functions, you need to start powershell as an administrator.

There is also an parameter for exporting an configuration file for mRemoteNG, importing this file will create the rdp connections for you within mRemoteNG. (RDP connections are enabled by default during the deployment of a lab).

## Authors

* **Ali Sevkin**

## License
This project is licensed under the MIT License - see the [LICENSE.MD](https://github.com/Ali-Sevkin/OpenVirtualLab/blob/master/LICENSE.MD) file for details

## Acknowledgments
* Used New-IsoFile.ps1 from: 
    *AUTHOR: Chris Wu LASTEDIT: 03/23/2016 14:46:50*  
* Used the autounattend examples from Microsoft msdn sites


