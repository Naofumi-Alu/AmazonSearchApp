import pyodbc
import os
import logging


class dataBase:
    def create_connection(db_file):
        """Create a database connection to the SQL Server database specified by db_file"""
        try:
            conn = pyodbc.connect(db_file)
            print(f"Connected to database: {db_file}")
            return conn
        except pyodbc.Error as e:
            print(e)
        return None

    def create_table(conn, create_table_sql):
        """Create a table from the create_table_sql statement"""
        try:
            cursor = conn.cursor()
            cursor.execute(create_table_sql)
            print("Table created successfully")
        except pyodbc.Error as e:
            print(e)

    def insert_product(conn, product):
        """Insert a new product into the products table"""
        sql = '''INSERT INTO products(title, price, url)
                 VALUES(?, ?, ?)'''
        cursor = conn.cursor()
        cursor.execute(sql, product)
        conn.commit()
        return cursor.lastrowid

    def fetch_all_products(conn):
        """Fetch all products from the products table"""
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products")
        rows = cursor.fetchall()
        return rows

class logs:
    
    # Crear el directorio de logs si no existe
    log_dir = 'logs'
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logging.basicConfig(
        filename=os.path.join(log_dir, 'app.log'), 
        level=logging.ERROR,
        format='%(asctime)s:%(levelname)s:%(message)s'
    )

    def log_error(message):
        """
        Registra un mensaje de error en el archivo de log.
        """
        logging.error(message)

    def validate_username(username):
        """
        Valida que el nombre de usuario no esté vacío y cumpla con ciertos criterios.
        """
        if not username:
            raise ValueError("El nombre de usuario no puede estar vacío.")
        # Aquí puedes agregar más validaciones si es necesario
        return True

    def transform_product_data(product):
        """
        Transforma los datos del producto en un formato deseado.
        """
        return {
            'Name': product.get('Name', 'N/A'),
            'Price': product.get('Price', 'N/A'),
            'Name': product.get('Name', 'N/A'),
            'UrlImage': product.get('UrlImage', ''),
        }
    def format_product_display(character):
        """
        Formatea los datos del personaje para su visualización.
        """
        return f"Nombre: {character['name']}\nEstatus: {character['status']}\nEspecie: {character['species']}"

    # Ejemplo de uso de funciones utilitarias
    if __name__ == "__main__":
        try:
            # Simulando una validación de nombre de usuario
            validate_username("admin")
        except ValueError as ve:
            log_error(f"Validation Error: {ve}")
        except Exception as e:
            log_error(f"Unexpected Error: {e}")
        else:
            print("Nombre de usuario válido.")
        finally:
            print("Proceso de validación completado.")
        