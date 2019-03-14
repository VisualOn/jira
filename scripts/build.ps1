$ErrorActionPreference = 'Stop';

Write-Host Starting build
docker build -t jira .
