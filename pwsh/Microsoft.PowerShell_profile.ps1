# Oh my Posh is a great tool to make a pretty prompt in your PowerShell.
# See https://ohmyposh.dev/docs/windows
Import-Module posh-git
# My personal oh my posh theme
oh-my-posh --init --shell pwsh --config ~\AppData\Local\Programs\oh-my-posh\themes\pietdoe.omp.json | Invoke-Expression

<#
    .Description
    Start the Rnwood.Smtp4dev server interactively.
    It will listen on localhost on port 25 for smtp.
    Open http://localhost:8025 to view the dashboard.

    .Notes
    Needs Docker installed on your computer.
#>
function Start-Smtp4Dev {
    Write-Host $("*" * 79)
    Write-Host "Go to http://localhost:8025 to view the dashboard."
    Write-Host $("*" * 79)
    docker run --rm -it -p 8025:80 -p 25:25 rnwood/smtp4dev:v3
}

<#
    .Description
    Stop and remove all running docker containers.
#>
function Remove-Docker-Containers {
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
}

<#
    .Description
    Get the IP Address of a running Docker container.
#>
function Get-Container-IP($containerName) {
    docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $containerName
}
Set-Alias getip -Value Get-Container-IP

<#
    .Description
    Repeat a command multiple times.

    .Example
    repeat 5 Write-Host "Hello World"

    .Example
    repeat 10 docker run -d alpine
#>
function Repeat {
    [int] $times = $args[0]
    if ($args.Length -le 1) { 
        return
    }
    $command = ""
    for ($i = 1; $i -lt $args.Count; $i++) {
        $command += $args[$i]
        if ($i -le $args.Count - 1) {
            $command += " "
        }
    }
    for ($i = 0; $i -lt $times; $i++) {
        Invoke-Expression $command
    }
}

<#
    .Description
    Convert a raw JSON string to formatted intended JSON.
    .Example
    curl 'https://petstore.swagger.io/v2/pet/findByStatus?status=available' -H 'accept: application/json' | Format-Json
#>
function Format-Json {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $RawJson
    )
    $RawJson | ConvertFrom-Json | ConvertTo-Json -Depth 10
}

<#
    .Description
    Opens the related pull request for the current Git branch in Azure DevOps.

    .Notes
    The Azure DevOps CLI must be installed and configured.
    See: https://github.com/Azure/azure-devops-cli-extension

#>
function Open-PR {
    $currentBranch = git branch --show-current
    if (-not $currentBranch) { Return }
    $pullRequests = az repos pr list --detect | ConvertFrom-Json
    $pr = $pullRequests | Where-Object { $_.sourceRefName.EndsWith($currentBranch) }
    if (-not $pr) {
        Write-Error "Didn't find an open pull request for the current branch $currentBranch in Azure DevOps."
        Return
    }
    Write-Host "Found PR $($pr.pullRequestId). Opening the PR in the browser..."
    az repos pr show --id $pr.pullRequestId --open 1>$null
}

<#
    .Description
    Parses a JWT (JSON Web Token) and prints the header and payload as JSON.
#>
function Debug-JWT($token) {

	function parseJwtPart($part) {
		$tokenPayload = $part.Replace('-', '+').Replace('_', '/')
		# Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
		while ($tokenPayload.Length % 4) { 
			Write-Verbose "Invalid length for a Base-64 char array or string, adding ="
			$tokenPayload += "="
		}
		$tokenByteArray = [System.Convert]::FromBase64String($tokenPayload)
		$json = [System.Text.Encoding]::ASCII.GetString($tokenByteArray)
		Return $json | ConvertFrom-Json | ConvertTo-Json -Depth 10
	}

    # Validate as per https://tools.ietf.org/html/rfc7519
    # Access and ID tokens are fine, Refresh tokens will not work
    if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
	
	$parts = $token.Split(".");
 
    Write-Output "Header:"
	parseJwtPart($parts[0]) | Write-Output
 
	Write-Output "Payload:"
    parseJwtPart($parts[1]) | Write-Output
}