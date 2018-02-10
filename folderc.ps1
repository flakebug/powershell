<#
.SYNOPSIS
Make hierarchy directories(or folders) by definition file

.DESCRIPTION
This script makes hierarchy directories by the definition csv file

For example, if you have a csv file
The csv file content as below : (Note : First row as column name)
Folder_1	Folder_2	Folder_3
Dir1        Dir11       Dir111
Dir1        Dir12       

Then you will get the directories as below
/Dir1/Dir11/Dir111
/Dir1/Dir12

.PARAMETER DefinitionFile
(Mandatory) Assign the definition csv file

.PARAMETER OutputPath
(Mandatory) Assign the output directory

.PARAMETER TemplatePath
(Optional) Assign the template folder that you want to copy to each directory

.PARAMETER ForceRun
(Optional) If force run is not assigned, it runs only trial mode
If you want to start the permanent process, then you have to assign this parameter

.EXAMPLE
.\folderc.ps1 -TemplatePath .\TemplateFolder -FolderDefinitionFile .\Definition.csv -OutputPath .\Output
.EXAMPLE
.\folderc.ps1 -TemplatePath .\TemplateFolder -FolderDefinitionFile .\Definition.csv -OutputPath .\Output -ForceRun
.NOTES
Author : Liang
Initial Release : 2017/12/3
#>
param (
    [Parameter(Mandatory=$TRUE)]
        [ValidatePattern('^[^<>:;,?"*|/]+$')] #validate the filename format
        [string]$DefinitionFile = '',
    [Parameter(Mandatory=$TRUE)]
        [ValidatePattern('^[^<>:;,?"*|/]+$')] #validate the filename format
        [string]$OutputPath = '',
    [Parameter(Mandatory=$FALSE)]
        [ValidatePattern('^[^<>:;,?"*|/]+$')] #validate the filename format
        [string]$TemplatePath = '',
    [switch]$ForceRun = $FALSE
)


Try
{
    If(!($TemplatePath -eq ''))
    {
        If(!(Test-Path $TemplatePath))
        {
            Throw [System.IO.FileNotFoundException] "[ERROR] [-TemplatePath $TemplatePath] directory not found"
        }
        $TemplatePath = $TemplatePath.TrimEnd('\')  #remove the trailing slash(\) if user assigned
    }   
    If(!($DefinitionFile -eq ''))
    {
        If(!(Test-Path $DefinitionFile))
        {
            Throw [System.IO.FileNotFoundException] "[ERROR] [-FolderDefinitionFile $DefinitionFile] file not found"
        }
    }    
    If(!($OutputPath -eq ''))
    {
        If(!(Test-Path $OutputPath))
        {    
            New-Item -ItemType directory -Path $OutputPath | Out-Null
        }
        If(!(Test-Path $OutputPath))
        {
            Throw [System.IO.FileNotFoundException] "[ERROR] -OutputPath $OutputPath directory is not valid"
        }
        $OutputPath = $OutputPath.TrimEnd('\') #remove the trailing slash(\) if user assigned
    }    
}
Catch [System.IO.FileNotFoundException]
{
    Write-Host $_.Exception.Message
    Exit
}





$SYS_SCRIPT_PATH = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

$folderDef = Import-CSV $DefinitionFile

$rowNumber = 2 #the csv content row starts from 2
$errorFlag = $FALSE
$directoryNameStructure = '^[^<>:;,?"*|/\\]+$'
ForEach ($folderrow in $folderDef)
{
    Write-Host "Definition file verification, row : $rowNumber"
    If ( 
        !($folderRow.Folder_1.Trim() -eq '') -AND
        !($folderRow.Folder_1 -match $directoryNameStructure)
       )
    {
        $errorMessage = "[Error Row : $rowNumber] Invalid directory format : " + $folderRow.Folder_1 
        $errorFlag = $TRUE
        Write-Host $errorMessage
    }
    If ( 
        !($folderRow.Folder_2.Trim() -eq '') -AND
        !($folderRow.Folder_2 -match $directoryNameStructure)
       )
    {
        $errorMessage = "[Error Row : $rowNumber] Invalid directory format : " + $folderRow.Folder_2
        $errorFlag = $TRUE
        Write-Host $errorMessage
    } 
    If ( 
        !($folderRow.Folder_3.Trim() -eq '') -AND
        !($folderRow.Folder_3 -match $directoryNameStructure)
       )
    {
        $errorMessage = "[Error Row : $rowNumber] Invalid directory format : " + $folderRow.Folder_3 
        $errorFlag = $TRUE
        Write-Host $errorMessage
    }
    
    $rowNumber = $rowNumber + 1
}
If($errorFlag)
{
    Write-Host 'Multiple errors found'
    Write-Host 'Check csv definition file'
    Write-Host 'Program terminated'
    Exit
}

$runMode = ""
If ($ForceRun)
{
    $runMode = '[Force Run]'
}
Else
{
    $runMode = '[Dry Run]'
}
ForEach ($folderrow in $folderDef)
{
    $folderFullPath = $OutputPath + '\' + $folderRow.Folder_1 + '\' + $folderRow.Folder_2 + '\' + $folderRow.Folder_3
    If($ForceRun)
    {
        If(!(Test-Path $folderFullPath))
        {
            New-Item -ItemType directory -Path $folderFullPath | Out-Null
        }
        If(!($TemplatePath -eq ''))
        {
            Copy-Item -Path $TemplatePath\* -Destination $folderFullPath -Recurse
        }
    }
    Write-Host "$runMode $folderFullPath folder created"
}

############################################################
##
## ## DO NOT MODIFY THIS SECTION ##
##
## Program Name :
##     folderc.ps1
## Author :
##     Liang
## Organization :
##     CTCI
## Initial Release Date :
##     2017/12/3
## Description :
##     Create the hirearchy directories structure by csv definition file
##
## ## DO NOT MODIFY THIS SECTION ##
##
############################################################

############################################################
## Versions Information
##
## 0.1, 2017/12/2
##     Initial release
##     Backup files to server
##
############################################################