import requests


URL = "https://beeit.cz/"  

def send_request():
    try:
        response = requests.get(URL)
        print(f"✅ Response Code: {response.status_code}")
        print(f"✅ Response Body:\n{response.text}")
    except requests.RequestException as e:
        print(f"❌ ERROR: {e}")

if __name__ == "__main__":
    send_request()

print("App is running...")

