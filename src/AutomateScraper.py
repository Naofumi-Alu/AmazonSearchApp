import requests
from src.utils import log_error
import selenium 
from selenium import webdriver 
from selenium.webdriver.common.by import By
import subprocess
import json


# Clase para automatizar el scraping de productos en Amazon


class AutomateScraper:
    # Definir la URL base de Amazon globalmente
    BASE_URL = "https://www.amazon.com/"
    search_term = "laptop DELL"
   
    def run_powershell_script(url):
        result = subprocess.run(
            ["powershell", "-File", "scraper.ps1", "-url", url],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"Error executing PowerShell script: {result.stderr}")

        products = json.loads(result.stdout)
        return products
        
        
    def get_Products(search_term):
        try:
            #Open amazon using selenium in google chrome
            driver = webdriver.Chrome()
            driver.get(AutomateScraper.BASE_URL)
            #Search products using input parameter search_term in the search bar 
            search_bar = driver.find_element_by_id("twotabsearchtextbox")
            search_bar.send_keys(search_term)
            search_button = driver.find_element_by_xpath("//input[@value='Go']")
            search_button.click()
            #Get Current url of the page
            url = driver.current_url
            #Use run_powershell_script method to run the powershell script
            products = AutomateScraper.run_powershell_script(url)
            # Use Webdirver to get the products using the xpath of the product
            products = driver.find_elements(By.XPATH, "//div[@data-component-type='s-search-result']")
            return products
        except selenium.common.exceptions.WebDriverException as e:
            log_error(f"Webdriver Error in fetch_products: {e}")
            raise e # Re-raise the exception to be handled by the caller
        except Exception as e:
            log_error(f"Unexpected Error in fetch_products: {e}")
            raise e # Re-raise the exception to be handled by the caller
        finally:
            driver.quit() # Close the browser window

         