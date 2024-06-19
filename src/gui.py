import tkinter as tk
from tkinter import messagebox
from src.main_screen import MainScreen  # Importando la lógica de la ventana principal

class LoginScreen:
    def __init__(self, root):
        self.root = root
        self.root.title("Amazon Search Automation - Login")
        self.root.geometry("300x200")
        self.create_login_screen()

    def create_login_screen(self):
        self.login_frame = tk.Frame(self.root)
        self.login_frame.pack(pady=20)

        self.username_label = tk.Label(self.login_frame, text="Username:")
        self.username_label.grid(row=0, column=0, padx=10, pady=10)
        self.username_entry = tk.Entry(self.login_frame)
        self.username_entry.grid(row=0, column=1, padx=10, pady=10)

        self.password_label = tk.Label(self.login_frame, text="Password:")
        self.password_label.grid(row=1, column=0, padx=10, pady=10)
        self.password_entry = tk.Entry(self.login_frame, show="*")
        self.password_entry.grid(row=1, column=1, padx=10, pady=10)

        self.login_button = tk.Button(self.login_frame, text="Login", command=self.validate_login)
        self.login_button.grid(row=2, columnspan=2, pady=20)

    def validate_login(self):
        username = self.username_entry.get()
        password = self.password_entry.get()

        # Simulación de validación de login
        if username == "admin" and password == "admin":
            messagebox.showinfo("Login Success", "Welcome to Amazon Search Automation!")
            self.login_frame.pack_forget()
            MainScreen(self.root)  # Navegar a la ventana principal
        else:
            messagebox.showerror("Login Failed", "Invalid username or password")

if __name__ == "__main__":
    root = tk.Tk()
    app = LoginScreen(root)
    root.mainloop()
