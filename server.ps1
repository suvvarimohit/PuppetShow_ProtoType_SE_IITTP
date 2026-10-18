$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath($PSScriptRoot)
$port = 4174
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
$types = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.svg'  = 'image/svg+xml'
    '.txt'  = 'text/plain; charset=utf-8'
    '.json' = 'application/json; charset=utf-8'
}

try {
    $listener.Start()
    Write-Host "Puppet Story Studio: http://127.0.0.1:$port"
    [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) |
        Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork -and -not $_.IPAddressToString.StartsWith('127.') } |
        ForEach-Object { Write-Host "Network access:     http://$($_.IPAddressToString):$port" }
    Write-Host 'Speech uses the voices provided by each browser/device.'
    Write-Host 'Keep this window open while using the app. Press Ctrl+C to stop.'

    while ($true) {
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            while ($null -ne ($header = $reader.ReadLine()) -and $header.Length -gt 0) { }

            $status = '200 OK'
            $body = [byte[]]@()
            $contentType = 'application/octet-stream'
            if ($requestLine -match '^(GET|HEAD)\s+(\S+)\s+HTTP/') {
                $method = $Matches[1]
                $urlPath = [Uri]::UnescapeDataString(($Matches[2] -split '\?', 2)[0]).TrimStart('/')
                if ([string]::IsNullOrWhiteSpace($urlPath)) { $urlPath = 'index.html' }
                $target = [System.IO.Path]::GetFullPath((Join-Path $root $urlPath))
                $rootPrefix = $root.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
                if (-not $target.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and $target -ne $root) {
                    $status = '403 Forbidden'
                    $body = [System.Text.Encoding]::UTF8.GetBytes('Forbidden')
                    $contentType = 'text/plain; charset=utf-8'
                } elseif (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
                    $status = '404 Not Found'
                    $body = [System.Text.Encoding]::UTF8.GetBytes('Not found')
                    $contentType = 'text/plain; charset=utf-8'
                } else {
                    $extension = [System.IO.Path]::GetExtension($target).ToLowerInvariant()
                    if ($types.ContainsKey($extension)) { $contentType = $types[$extension] }
                    if ($method -ne 'HEAD') { $body = [System.IO.File]::ReadAllBytes($target) }
                }
            } else {
                $status = '400 Bad Request'
                $body = [System.Text.Encoding]::UTF8.GetBytes('Bad request')
                $contentType = 'text/plain; charset=utf-8'
            }

            $headerText = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nConnection: close`r`nX-Content-Type-Options: nosniff`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headerText)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            if ($body.Length -gt 0) { $stream.Write($body, 0, $body.Length) }
            $stream.Flush()
            $reader.Dispose()
            $stream.Dispose()
        } catch {
            Write-Host "Request failed: $($_.Exception.Message)"
        } finally {
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}
