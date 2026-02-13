$s = Get-Content -Raw 'c:\Users\Lenovo\Desktop\Dualarla\lib\screens\journeys_page.dart'
$open = ($s.ToCharArray() | Where-Object { $_ -eq '{' }).Count
$close = ($s.ToCharArray() | Where-Object { $_ -eq '}' }).Count
Write-Output "open:$open close:$close"
