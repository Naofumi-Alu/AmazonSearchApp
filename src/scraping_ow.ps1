# Definir la URL de origen
param (
    [string] $url
)

try {
    Write-Host "Iniciando el proceso de scraping en $url"

    # Obtener el contenido HTML de la URL
    $html = Invoke-WebRequest -Uri $url

    # Crear un nuevo objeto HTMLFile
    $doc = New-Object -ComObject HTMLFile

    # Escribir el contenido HTML en el objeto HTMLFile
    $doc.IHTMLDocument2_write($html.Content)

    # Obtener los nodos que coinciden con el criterio especificado
    $nodes = $doc.getElementsByTagName("div") | Where-Object { $_.className -eq "sg-col-inner" }

    # Registrar el número de nodos encontrados
    Write-Host "Se encontraron $($nodes.Count) nodos"

    # Crear un array para almacenar los productos y otro para los no capturados
    $allProducts = @()
    $capturedProducts = @()
    $missedProducts = @()

    # Recorrer cada nodo
    foreach ($node in $nodes) {
        # Crear un nuevo objeto PSObject
        $product = New-Object PSObject

        # Agregar la propiedad "Name" al objeto PSObject
        $NameNode = $node.getElementsByTagName("span") | Where-Object { $_.className -eq "a-size-medium a-color-base a-text-normal" }
        if ($NameNode) {
            $product | Add-Member -MemberType NoteProperty -Name "Name" -Value ($NameNode.innerText -join ", ")
        }
        
        # Agregar la propiedad "Price" al objeto PSObject
        $priceNode = $node.getElementsByTagName("span") | Where-Object { $_.className -eq "a-offscreen" }
        if ($priceNode) {
            $product | Add-Member -MemberType NoteProperty -Name "Price" -Value ($priceNode.innerText -join ", ")
        }

        # Encontrar el elemento que activa el popover
        $popoverTrigger = $node.getElementsByTagName("a") | Where-Object { $_.className -eq "a-popover-trigger a-declarative" }

        # Si se encuentra el elemento que activa el popover
        if ($popoverTrigger) {
            Write-Host "Activando el popover para el producto: $($product.Name)"
            # Ejecutar el evento "onmouseover" para activar el popover
            $popoverTrigger.fireEvent("onmouseover")

            #Esperar un segundo para que se cargue el popover
            #Start-Sleep -Seconds 1

            #Acceder al contenido que se muestra en el popover
            $rateNode = $node.getElementsByTagName("span") | Where-Object { $_.className -eq "a-icon-alt" }
            if ($rateNode) {
                $product | Add-Member -MemberType NoteProperty -Name "Rate" -Value ($rateNode.innerText -join ", ")
            }
        }

        # Agregar el producto a la lista completa
        $allProducts += $product

        # Verificar si el producto tiene nombre, precio y rate
        if ($product.Name -and $product.Price -and $product.Rate) {
            # Agregar el objeto PSObject al array de productos capturados
            $capturedProducts += $product
        } else {
            # Agregar al array de productos no capturados
            $missedProducts += $product
        }
    }

    # Registrar el número de productos encontrados
    Write-Host "Se obtuvieron $($capturedProducts.Count) productos"

    try {
        # Convertir los productos totales, los capturados y los no capturados a formato JSON
        $allProductsJson = $allProducts | ConvertTo-Json
        $capturedProductsJson = $capturedProducts | ConvertTo-Json
        $missedProductsJson = $missedProducts | ConvertTo-Json

        #Crea el directorio ResultScraping si no existe
        if (-not (Test-Path "ResultScraping")) {
            New-Item -ItemType Directory -Path "ResultScraping"
        }

        
        # Guardar los resultados en archivos JSON with date and time
        $date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $allProductsJson | Out-File -FilePath "ResultScraping/allProducts_$date.json"
        $capturedProductsJson | Out-File -FilePath "ResultScraping/capturedProducts_$date.json"
        $missedProductsJson | Out-File -FilePath "ResultScraping/missedProducts_$date.json"
    } catch {
        # Registrar el error ocurrido al convertir a JSON
        Write-Host "Se produjo un error al convertir los productos a JSON: $($_.Exception.Message)"
    }

    #Imprime las variables de salida
    Write-Host "allProductsJson: $allProductsJson"
    Write-Host "capturedProductsJson: $capturedProductsJson"
    Write-Host "missedProductsJson: $missedProductsJson"

    # Registrar el fin del proceso de scraping
    Write-Host "El proceso de scraping ha finalizado con éxito"

    # Devolver los JSON de los productos capturados y los no capturados
    return @{
        CapturedProducts = $capturedProductsJson
        MissedProducts = $missedProductsJson
    }

} catch {
    # Registrar el error ocurrido durante el proceso de scraping
    Write-Host "Se produjo un error durante el proceso de scraping: $($_.Exception.Message)"
    #asignar excepcion a una variable de salida
    $error = $_.Exception.Message
    # Devolver un mensaje de error
    return "Se produjo un error durante el proceso de scraping: $($_.Exception.Message)"
}
