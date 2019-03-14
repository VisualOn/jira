$ErrorActionPreference = 'Stop';

git config --global core.autocrlf true

if ($env:APPVEYOR_REPO_TAG -eq "true")
{
    Update-AppveyorBuild -Version ($env:APPVEYOR_REPO_TAG_NAME).TrimStart("v")
}
