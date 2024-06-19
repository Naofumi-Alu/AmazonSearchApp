param (
    [string]$url
)

# Agretga la DLL de HtmlAgilityPack al contexto de PowerShell para poder utilizarla en el script de scraping de productos de Amazon

Add-Type -Path "C:\Users\Usuario\ATENTO_TEST\AmazonSearchApp\dll\htmlagilitypack.1.11.61\lib\netstandard2.0\HtmlAgilityPack.dll"
$web = New-Object 'HtmlAgilityPack.HtmlWeb'
$doc = $web.Load($url)

# Extraer la información de los productos

$products = $doc.DocumentNode.SelectNodes("//div[contains(@class, 's-result-item') and @data-asin]")
if ($products -eq $null) {
    Write-Error "No se encontraron productos en la página."
    exit 1
}

$totalProducts = $products.Count
Write-Output "Total de productos encontrados en la página: $totalProducts"

# Seleccionar los últimos 10 productos
$last10Products = $products | Select-Object -Last 10

# Filtrar y devolver los productos
$result = @()
foreach ($product in $last10Products) {
    $nameNode = $product.SelectSingleNode(".//span[@class='a-size-medium a-color-base a-text-normal']")
    $priceNode = $product.SelectSingleNode(".//span[@class='a-price-whole']")
    
    if ($nameNode -ne $null -and $priceNode -ne $null) {
        # Obtener el XPath de los nodos
        $nameXPath = $nameNode.XPath
        $priceXPath = $priceNode.XPath
        
        $result += [PSCustomObject]@{
            Name = $nameNode.InnerText
            Price = $priceNode.InnerText
            NameXPath = $nameXPath
            PriceXPath = $priceXPath
            UrlImage = $product.SelectSingleNode(".//img").Attributes["src"].Value
        }
    }
}

$result | ConvertTo-Json
