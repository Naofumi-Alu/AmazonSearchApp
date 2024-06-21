import tkinter as tk
from tkinter import Toplevel, messagebox
from PIL import Image, ImageTk
from src.AutomateScraper import AutomateScraper
import os
import sys

class MainScreen:
    def __init__(self, root):
        self.root = root
        self.root.title("Amazon Search Automation - Main")
        self.create_main_screen()
        self.image_refs = []  # Lista para mantener referencias a ImageTk.PhotoImage
        self.product_detail_window = None  # Inicializar la ventana de detalles del producto

    def create_main_screen(self):
        self.main_frame = tk.Frame(self.root)
        self.main_frame.pack()
        
        #Create a label to display the search term
        self.search_label = tk.Label(self.main_frame, text="Search products:")
        #create a textbox to enter the search term
        self.search_entry = tk.Entry(self.main_frame)
        self.search_entry.pack()
        
        #Create a button to search the products
        self.search_button = tk.Button(self.main_frame, text="Search prodcts", command=self.get_ProductsFunc)
        self.search_button.pack(pady=10)
    
        #Create a listbox to display the products
        self.product_list = tk.Listbox(self.main_frame)
        self.product_list.pack(pady=10)
        self.product_list.bind("<<ListboxSelect>>", self.display_product)
        

    def get_ProductsFunc(self):
        search_term = self.search_entry.get()
        if not search_term:
            messagebox.showwarning("Warning", "Please enter a search term")
            return
        try:
            #wait that the user enter the search term 
            self.products = AutomateScraper.get_Products(search_term)
            
            # Insert the products in the listbox
            self.product_list.delete(0, tk.END)
            
            for product in self.products:
                self.product_list.insert(tk.END, product['Name'])
                
        # Manejar excepciones específicas si falla el scraping de la  función get_Products
        
        except Exception as e:
            print(f"Error fetching products: {e} at line {sys.exc_info()[-1].tb_lineno}")
            messagebox.showerror("Error", f"Failed to fetch products: {e} at line {sys.exc_info()[-1].tb_lineno}")
           
           
        finally:
            print("Fetching products completed")    
            
        

    def display_product(self):
        if not self.product_list.curselection():
            return  # No hay selección, salir de la función

        selected_index = self.product_list.curselection()[0]
        product = self.products[selected_index]

        try:
            print(f"Fetching image from: {product['UrlImage']}") 
            
            image_data = product['UrlImage']
            
            print(f"UrlImage: {image_data} ...")

            # Guardar la imagen localmente
            image_path = f"assets/images/{product['name'].replace(' ', '_')}.png"
            os.makedirs(os.path.dirname(image_path), exist_ok=True)
            with open(image_path, 'wb') as f:
                f.write(image_data)
            print(f"Image saved at: {image_path}")

            # Mostrar la imagen en la interfaz utilizando PIL
            self.buildWindowproduct(product, image_path)

        except Exception as e:
            print(f"Unexpected error: {e}")
            messagebox.showerror("Error", f"Failed to display image: {e}")

    def buildWindowproduct(self, product, image_path):
        if self.product_detail_window:  # Destruir la ventana existente si hay una
            self.product_detail_window.destroy()

        self.product_detail_window = Toplevel(self.root)
        self.product_detail_window.title(product['Name'])

        info_frame = tk.Frame(self.product_detail_window)
        info_frame.pack(pady=10)

        image = Image.open(image_path)
        image = image.resize((200, 200), Image.LANCZOS)
        photo = ImageTk.PhotoImage(image)

        # Asigna un nombre al label del producto para identificarlo en las pruebas
        product_info_label = tk.Label(info_frame, text=self.format_product_display(product), justify=tk.LEFT, name='product_name')
        product_info_label.grid(row=0, column=0, padx=10)

        product_image_label = tk.Label(info_frame, image=photo)
        product_image_label.grid(row=0, column=1, padx=10)
        product_image_label.image = photo  # Mantener referencia

    @staticmethod
    def transform_product_data(product):
        return {
            'Name': product.get('Name', 'N/A'),
            'Price': product.get('Price', 'N/A'),
            'Name': product.get('Name', 'N/A'),
            'UrlImage': product.get('UrlImage', ''),
        }

    @staticmethod
    def format_product_display(product):
        return f"Name: {product['Name']}\nPrice: {product['Price']}\nUrlImage: {product['UrlImage'][:20]} ..."

if __name__ == "__main__":
    root = tk.Tk()
    app = MainScreen(root)
    root.mainloop()
