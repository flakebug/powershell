############################################################
##
## ## DO NOT MODIFY THIS SECTION ##
##
## Program Name :
##     liwabackup
## Author :
##     Liang
## Organization :
##     CTCI
## Initial Release Date :
##     2017/12/2
## Description :
##     Backup user's file to assigned place
##     The main feature is compressing and set password to the archive file
##     This keeps personal secrecy
##     Although the program named as "liwabackup"
##     It's not limited to use in liwa project
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


############################################################
## [Begin of] Modify this section for user's requirement
############################################################

# Define backup source directory here
# Dont put '\' in the last directory
# For example
#     Correct :
#         c:\sample\dir
#     Not correct :
#         c:\sample\dir\
$BACKUP_SOURCE_DIR = @(
    #'c:\sample\dir',   ##This is the sample line of user's source path
    [Environment]::GetFolderPath("Desktop")
)

#Define backup master destination directory here
$BACKUP_DESTINATION_DIR = '\\192.168.54.2\Data\Instrument\Liang\Backup'
#Define password protection for zip file
$ARCHIVE_PASSWORD = 'ctcibackup'

############################################################
## [End of] Modify this section for user's requirement
############################################################


############################################################
## Do not modify below programs if you don't understand
############################################################
$SYS_USER_NAME = [Environment]::UserName
$SYS_USER_BACKUP_DIR = "$BACKUP_DESTINATION_DIR\$SYS_USER_NAME"
$SYS_SCRIPT_DIR = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$SYS_7Z_FULLPATH = ("$SYS_SCRIPT_DIR\System\7za\7za.exe" -replace ' ', '` ')  #escape the space character
$SYS_COMPRESSING_DIR_NAME = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$SYS_COMPRESSING_DIR = "$SYS_SCRIPT_DIR\System\$SYS_COMPRESSING_DIR_NAME"

#Create temporary directory for compressing intermediate files
New-Item -ItemType directory -Path $SYS_COMPRESSING_DIR

#Create the user profile directory in the master destination directory
if (!(Test-Path $SYS_USER_BACKUP_DIR))
{
    New-Item -ItemType directory -Path $SYS_USER_BACKUP_DIR
}

#Compressing source directory to individual archive files
ForEach ($src_dir in $BACKUP_SOURCE_DIR) {
    $archive_name = $src_dir | ForEach {$_ -replace "[\:\\]", "_"}
    $parameter_string = "a -mx0 -tzip ""$SYS_COMPRESSING_DIR\$archive_name.zip"" ""$src_dir"""
    $command_string = "$SYS_7Z_FULLPATH $parameter_string"
    Invoke-Expression $command_string
}

#Compressing all archive files into single file to destination
$parameter_string = "a -mx9 -tzip -p$ARCHIVE_PASSWORD ""$SYS_USER_BACKUP_DIR\$SYS_COMPRESSING_DIR_NAME.zip"" ""$SYS_COMPRESSING_DIR"""
$command_string = "$SYS_7Z_FULLPATH $parameter_string"
Invoke-Expression $command_string

#Remove the intermediate files
Remove-Item $SYS_COMPRESSING_DIR -recurse

Echo '***************'
Echo 'Backup complete'
Echo '***************'