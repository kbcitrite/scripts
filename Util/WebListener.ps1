param(
    $Hostname = 'localhost',
    $Port = '5002'
)
$Cancel = $false
do
{
    $httpListener = New-Object System.Net.HttpListener
    $httpListener.Prefixes.Add("http://$($Hostname):$Port/")
    $httpListener.Start()
    $context = $httpListener.GetContext()
    $context.Request.HttpMethod
    $context.Request.Url
    $context.Request.Headers.ToString()
    $requestBodyReader = New-Object System.IO.StreamReader $context.Request.InputStream
    $requestBodyReader.ReadToEnd()
    $context.Response.StatusCode = 200
    $context.Response.ContentType = 'application/json'
    $responseJson = '{"test": "response"}'
    $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
    $context.Response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
    $context.Response.Close()    
    $httpListener.Close()
    $httpListener.Dispose()
}
while (!$Cancel)
