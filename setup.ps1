
# Verificar y establecer las variables de entorno necesarias
$envVars = @('DB_SERVER', 'DB_NAME', 'DB_USER', 'DB_PASSWORD')

foreach ($var in $envVars) {
    if (-not [System.Environment]::GetEnvironmentVariable($var)) {
        Write-Error "La variable de entorno $var no está definida. Defínela antes de ejecutar este script."
        exit 1
    }
}

# Obtener las variables de entorno
$dbServer = [System.Environment]::GetEnvironmentVariable('DB_SERVER')
$dbName = [System.Environment]::GetEnvironmentVariable('DB_NAME')
$dbUser = [System.Environment]::GetEnvironmentVariable('DB_USER')
$dbPassword = [System.Environment]::GetEnvironmentVariable('DB_PASSWORD')

# Crear la base de datos SQL Server desde el archivo database/schema.sql
$sqlCmd = "sqlcmd -S $dbServer -U $dbUser -P $dbPassword -i database/schema.sql"
Invoke-Expression $sqlCmd

# Crear y activar el entorno virtual
python -m venv env
.\env\Scripts\Activate

# Instalar las dependencias
pip install -r requirements.txt

# Guardar las variables de entorno en un archivo .env
echo "DB_SERVER=$dbServer" > .env
echo "DB_NAME=$dbName" >> .env
echo "DB_USER=$dbUser" >> .env
echo "DB_PASSWORD=$dbPassword" >> .env

# Ejecutar el script de Python
python main.py
