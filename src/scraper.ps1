# Definir la URL de origen
param (
    [string] $url
)

try {
    # Registrar el inicio del proceso de scraping
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

    # Crear un array para almacenar los productos
    $products = @()

    # Recorrer cada nodo
    foreach ($node in $nodes) {
        # Crear un nuevo objeto PSObject
        $product = New-Object PSObject

        # Agregar la propiedad "Name" al objeto PSObject
        $NameNode = $node.getElementsByTagName("h2") | Where-Object { $_.className -eq "a-size-mini a-spacing-none a-color-base s-line-clamp-2" }
        if ($NameNode) {
            $product | Add-Member -MemberType NoteProperty -Name "Name" -Value ($NameNode.innerText -join ", ")
        }

        # Agregar la propiedad "Price" al objeto PSObject
        $priceNode = $node.getElementsByTagName("span") | Where-Object { $_.className -eq "a-offscreen" }
        if ($priceNode) {
            $product | Add-Member -MemberType NoteProperty -Name "Price" -Value ($priceNode.innerText -join ", ")
        }

        # Agregar la propiedad "ImageURL" al objeto PSObject
        $imgNode = $node.getElementsByTagName("img") | Where-Object { $_.className -eq "s-image s-image-optimized-rendering" }
        if ($imgNode) {
            $product | Add-Member -MemberType NoteProperty -Name "ImageURL" -Value $imgNode.src
        }

        # Solo agregar el producto si tiene nombre, precio e imagen
        if ($product.Name -and $product.Price -and $product.ImageURL) {
            # Agregar el objeto PSObject al array de productos
            $products += $product
        }
    }

    # Tomar los últimos 10 productos
    $last10Products = $products | Select-Object -Last 10

    # Registrar el número de productos encontrados
    Write-Host "Se obtenieron los ultimos  $($last10Products.Count) productos"

    # Convertir el array de los últimos 10 productos a JSON
    $productsJson = $last10Products | ConvertTo-Json

    # Registrar el fin del proceso de scraping
    Write-Host "El proceso de scraping ha finalizado con éxito"

    # Devolver el JSON de los últimos 10 productos
    return $productsJson
} catch {
    # Registrar el error ocurrido
    Write-Host "Se produjo un error durante el proceso de scraping: $($_.Exception.Message)"
}