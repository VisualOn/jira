Write-Host Starting test

$ErrorActionPreference = 'SilentlyContinue';
docker kill jiratest
docker rm -f jiratest

$ErrorActionPreference = 'Stop';
Write-Host Starting container
docker run --name jiratest -p 8080:8080 -d jira
Start-Sleep 20

docker exec -t jiratest java -version

try {
    Invoke-WebRequest -Uri http://localhost:8080 -RetryIntervalSec 5 -MaximumRetryCount 3
}
catch {
    $_.Exception.Response
    throw
}
docker logs jiratest

$ErrorActionPreference = 'SilentlyContinue';
docker kill jiratest
docker rm -f jiratest
