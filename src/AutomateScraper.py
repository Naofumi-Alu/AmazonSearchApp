from src.utils import logs
import selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import subprocess
import json

# Clase para automatizar el scraping de productos en Amazon
class AutomateScraper:
    # Definir la URL base de Amazon globalmente
    BASE_URL = "https://www.amazon.com/"

    @staticmethod
    def get_Products(search_term):
        try:
            print(f"Search term: {search_term}")
            products = AutomateScraper.AutomateSearch(search_term)
            print("Button clicked")
            
            # print each product of products json
            for product in products:
                print(f"EachProduct validate get_products function: {product}")
            return products
        except Exception as e:
            logs.log_error(f"Error in get_Products: {e}")
            return
        
    @staticmethod
    def AutomateSearch(search_term):
        try:
            # Open Amazon using Selenium in Google Chrome
            driver = webdriver.Chrome()
            driver.get(AutomateScraper.BASE_URL)
            driver.maximize_window()
            
            # Wait for the search bar to be present and interactable
            wait = WebDriverWait(driver, 10)
            search_bar = wait.until(EC.presence_of_element_located((By.ID, "twotabsearchtextbox")))
            search_bar.send_keys(search_term)
            
            # send enter key to search the product
            search_bar.submit()
           
            #Delay a seconds for the oher page can load
            driver.implicitly_wait(2)
           
     
            # Get the current URL of the page
            url = driver.current_url
            print(f"Current URL: {url}")
            
            # Execute the PowerShell script to scrape the products
            products = AutomateScraper.run_powershell_script(url)
            
            #alidate if products is empty or null or Error
            if products is None or products == "" or products == "Error":
                raise Exception("No products found")
            else:
                
                #Show each product of products json
                for product in products:
                    print(f"EachProduct: {product}")
                            # Return the products
                return products
            

        except selenium.common.exceptions.WebDriverException as e:
            logs.log_error(f"WebDriver Error in fetch_products: {e}")
            raise e  # Re-raise the exception to be handled by the caller
        except Exception as e:
            logs.log_error(f"Unexpected Error in fetch_products: {e}")
            driver.quit()  # Ensure the browser window is closed
            raise e  # Re-raise the exception to be handled by the caller
    
    @staticmethod
    def run_powershell_script(url):
            try:
                # Ejecutar el script de PowerShell para obtener los productos
                script_path = "src/scraper.ps1"
                process = subprocess.Popen(["powershell.exe", "-File", script_path, url], stdout=subprocess.PIPE)
                
                return process
            except Exception as e:
                logs.log_error(f"Error in run_powershell_script: {e}")
                return
            
 