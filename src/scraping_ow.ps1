
# Definir la URL de origen y el nombre del producto
param (
    [string] $url,
    [string] $productName
)


try {
    Write-Host "Iniciando el proceso de scraping en $url"

    # Obtener el contenido HTML de la URL
    $html = Invoke-WebRequest -Uri $url

    # Crear un nuevo objeto HTMLFile
    $doc = New-Object -ComObject HTMLFile
    $doc.IHTMLDocument2_write($html.Content)

    # Seleccionar nodos directamente
    $nameNodes = $doc.getElementsByTagName("h2") | Where-Object { $_.className -eq "a-size-mini a-spacing-none a-color-base s-line-clamp-2" -or $_.className -eq "a-size-mini a-spacing-none a-color-base s-line-clamp-4" }
    $priceNodes = $doc.getElementsByTagName("span") | Where-Object { $_.className -eq "a-offscreen" }
    $rateNodes = $doc.getElementsByTagName("span") | Where-Object { $_.className -eq "a-icon-alt" }

    $allProducts = @()
    $capturedProducts = @()
    $missedProducts = @()

    # Calcular el máximo número de nodos entre nameNodes, priceNodes y rateNodes
    $maxCount = $nameNodes.Count
    if ($priceNodes.Count -gt $maxCount) {
        $maxCount = $priceNodes.Count
    }
    if ($rateNodes.Count -gt $maxCount) {
        $maxCount = $rateNodes.Count
    }

    for ($i = 0; $i -lt $maxCount; $i++) {
        $product = New-Object PSObject

        if ($i -lt $nameNodes.Count) {
            $product | Add-Member -MemberType NoteProperty -Name "Name" -Value ($nameNodes[$i].innerText -join ", ")
        }

        if ($i -lt $priceNodes.Count) {
            $product | Add-Member -MemberType NoteProperty -Name "Price" -Value ($priceNodes[$i].innerText -join ", ")
        }

        if ($i -lt $rateNodes.Count) {
            $product | Add-Member -MemberType NoteProperty -Name "Rate" -Value ($rateNodes[$i].innerText -join ", ")
        }

        # Agregar el producto a la lista completa
        $allProducts += $product

        # Verificar si el producto tiene nombre, precio y rate
        if ($product.Name -and $product.Price -and $product.Rate) {
            # Agregar el objeto PSObject al array de productos capturados
            $capturedProducts += $product
        }elseif ($product.Price -and $product.Rate) {
            # Agregar al array de productos no capturados
            $missedProducts += $product
        }
    }

    # Registrar el número de productos totales
    Write-Host "Se obtuvieron $($allProducts.Count) productos"
    # Registrar el número de productos encontrados
    Write-Host "Se obtuvieron $($capturedProducts.Count) productos"
    # Registrar el número de productos no capturados
    Write-Host "Se obtuvieron $($missedProducts.Count) productos no capturados"


    try {
        # Convertir los productos totales, los capturados y los no capturados a formato JSON
        $allProductsJson = $allProducts | ConvertTo-Json
        $capturedProductsJson = $capturedProducts | ConvertTo-Json
        $missedProductsJson = $missedProducts | ConvertTo-Json

        # Crear el directorio ResultScraping si no existe
        if (-not (Test-Path "ResultScraping")) {
            New-Item -ItemType Directory -Path "ResultScraping"
        }

        # Guardar los resultados en archivos JSON con fecha y hora
        $date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $allProductsJson | Out-File -FilePath "ResultScraping/allProducts_$date.json"
        $capturedProductsJson | Out-File -FilePath "ResultScraping/capturedProducts_$date.json"
        $missedProductsJson | Out-File -FilePath "ResultScraping/missedProducts_$date.json"
    } catch {
        # Registrar el error ocurrido al convertir a JSON
        Write-Host "Se produjo un error al convertir los productos a JSON: $($_.Exception.Message)"
        # Registra la linea donde se produjo el error
        Write-Host "Error en la linea: $($_.InvocationInfo.ScriptLineNumber)"
    }

    # Imprimir las variables de salida
    Write-Host "allProductsJson: $allProductsJson"
    Write-Host "capturedProductsJson: $capturedProductsJson"
    Write-Host "missedProductsJson: $missedProductsJson"

    # Registrar el fin del proceso de scraping
    Write-Host "El proceso de scraping ha finalizado con éxito"

    # Devolver los JSON de los productos capturados y los no capturados
    return @{
        capturedProductsJson = $capturedProductsJson
        missedProductsJson = $missedProductsJson
    }

} catch {
    # Registrar el error ocurrido durante el proceso de scraping
    Write-Host "Se produjo un error durante el proceso de scraping: $($_.Exception.Message)"
    # Asignar excepción a una variable de salida
    $error = $_.Exception.Message
    # Devolver un mensaje de error
    return "Se produjo un error durante el proceso de scraping: $($_.Exception.Message)"
}
