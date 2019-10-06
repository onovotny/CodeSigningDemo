$currentDirectory = split-path $MyInvocation.MyCommand.Definition

# See if we have the ClientSecret available
if ([string]::IsNullOrEmpty($env:SignClientSecret)) {
    Write-Host "Client Secret not found, not signing packages"
    return;
}

dotnet tool install --tool-path . SignClient

# Setup Variables we need to pass into the sign client tool
$appSettings = "$currentDirectory\SignClient.json"
$filter = "$currentDirectory\filter.txt"

$nupgks = Get-ChildItem $Env:ArtifactDirectory\*.nupkg | Select-Object -ExpandProperty FullName

foreach ($nupkg in $nupgks) {
    Write-Host "Submitting $nupkg for signing"
    .\SignClient 'sign' -c $appSettings -f $filter -i $nupkg -r $env:SignClientUser -s $env:SignClientSecret -n 'CodeSignDemo' -d 'CodeSignDemo' -u 'https://github.com/onovotny/CodeSignDemo'
   if ($LASTEXITCODE -ne 0) {
      exit 1
	}
    Write-Host "Finished signing $nupkg"
}

Write-Host "Sign-package complete"