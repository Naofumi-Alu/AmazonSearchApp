# Crear y activar el entorno virtual
python -m venv env
.\env\Scripts\Activate

# Instalar las dependencias
pip install -r requirements.txt

# Crear la base de datos sql server desde el archivo datrabase/schema.sql con el nombre "db" y el usuario "sa" con la contraseña "Password123"
sqlcmd -S localhost -U sa -P Password123 -i database/schema.sql

# Crear el archivo .env con las variables de entorno
echo "DB_SERVER=localhost" > .env
echo "DB_NAME=db" >> .env
echo "DB_USER=sa" >> .env
echo "DB_PASSWORD
=Password123" >> .env

# Setear las variables de entorno
```powershell
$env:DB_SERVER = "localhost"
$env:DB_NAME
$env:DB_USER
$env:DB_PASSWORD
```
# Ejecutar el script de python
```powershell
python main.py
```



