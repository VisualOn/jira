Write-Host Starting test

$ErrorActionPreference = 'SilentlyContinue';
docker kill jiratest
docker rm -f jiratest

$ErrorActionPreference = 'Stop';
Write-Host Starting container
docker run --name jiratest -p 8080:8080 -d jira
Start-Sleep 10

docker exec -t jiratest java --version

docker logs jiratest

$ErrorActionPreference = 'SilentlyContinue';
docker kill jiratest
docker rm -f jiratest
