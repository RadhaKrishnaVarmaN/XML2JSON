
# Use Newtonsoft tool to convert xml to json otherwise use Powershell built-in functions
$useNetonsoft=$true

$path = Split-Path $script:MyInvocation.MyCommand.Path
#"path: $path"


if ($useNetonsoft) {
    [Reflection.Assembly]::LoadFile([IO.Path]::Combine($path, "Newtonsoft.Json.dll”))
}

$files_count = Get-ChildItem -Path $path -Filter *.xml -File | Measure-Object | %{$_.Count}
#"files: $files_count"

if ($files_count -eq 0) {
    Write-Host "No XML file exists" -ForegroundColor Red
    Read-Host "Press Enter to close..."
    Exit
}

Get-ChildItem -Path $path -Filter *xml | ForEach-Object {

    $file = $_.FullName
    $fileNameNoExt = [IO.Path]::GetFileNameWithoutExtension($_.Name) + ".json"
    $fileNameJson = [IO.Path]::Combine($path, $fileNameNoExt)

    Write-Host ""
    Write-Host (Get-Date).ToString("HH.mm.ss : ") "file: $file"

    # skip if file was already converted.
    if ((Test-Path $fileNameJson) -ne 0){
        Write-Host (Get-Date).ToString("HH.mm.ss : ") "Json File $fileNameJson already exists. To re-run, clear/delete .json file." -ForegroundColor Red
        Write-Host ""
        return
    }

    #Read file
    Write-Host (Get-Date).ToString("HH.mm.ss : ") "Read file Started..."
    $xml = New-Object -TypeName XML
    $xml.XmlResolver = $null
    $xml.Load($file)

    Write-Host (Get-Date).ToString("HH.mm.ss : ") "Convert xml to json initiated."

    if($xml.FirstChild.NodeType -eq 'XmlDeclaration')
    {
        $xml.RemoveChild($xml.FirstChild) | Out-Null
    }

    if ($useNetonsoft) {
        [Newtonsoft.Json.JsonConvert]::SerializeXmlNode($xml, [Newtonsoft.Json.Formatting]::Indented) | Out-File $fileNameJson
    } else {
        $xml | ConvertFrom-Xml | ConvertTo-Json -Depth 100 | Out-File $fileNameJson
    }

}

Read-Host "Press Enter to close..."
