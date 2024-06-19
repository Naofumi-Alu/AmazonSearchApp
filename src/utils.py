import pyodbc


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

# Example usage

if __name__ == '__main__':
    db_file = "DRIVER={SQL Server};SERVER=server_name;DATABASE=database_name;UID=username;PWD=password"
    create_table_sql = """
        CREATE TABLE IF NOT EXISTS products (
            id INT PRIMARY KEY IDENTITY(1,1),
            title NVARCHAR(MAX) NOT NULL,
            price NVARCHAR(MAX) NOT NULL,
            url NVARCHAR(MAX) NOT NULL
        );
    """

    conn = dataBase.create_connection(db_file)
    if conn is not None:
        dataBase.create_table(conn, create_table_sql)
        conn.close()
    else:
        print("Error! cannot create the database connection.")