import sys
import json
import time
import requests

try:
    import serial
    import serial.tools.list_ports
except ImportError:
    print("Warning: 'pyserial' package not found. Serial Mode will not be available.")
    print("Please install it using: pip install pyserial")

try:
    from pynput import keyboard
except ImportError:
    print("Warning: 'pynput' package not found. Keyboard Interceptor Mode will not be available.")
    print("Please install it using: pip install pynput")

# ==================== CONFIGURATION ====================
DEFAULT_SERVER_URL = "http://localhost:8080"
# =======================================================

def send_to_server(server_url, session_id, epc):
    """Sends the scanned RFID EPC to the backend API"""
    url = f"{server_url.rstrip('/')}/api/rfid/scan"
    payload = {
        "epc": epc,
        "session_id": session_id
    }
    headers = {
        "Content-Type": "application/json"
    }
    
    print(f"[*] Sending EPC '{epc}' to session '{session_id}'...")
    try:
        response = requests.post(url, data=json.dumps(payload), headers=headers, timeout=5)
        if response.status_code == 200:
            res_data = response.json()
            if res_data.get("status") == "ok":
                print(f"[+] Success: Added '{res_data.get('nama_item')}' ({res_data.get('kode_oracle')})")
            else:
                print(f"[-] Tag not recognized in database: {res_data.get('epc')}")
        else:
            print(f"[-] Server returned status code {response.status_code}: {response.text}")
    except Exception as e:
        print(f"[!] Network error: {e}")

# ==================== MODE 1: KEYBOARD INTERCEPTOR ====================
class KeyboardInterceptor:
    """
    Captures keyboard inputs globally in the background.
    Detects rapid sequences of characters ending with Enter (typical of USB RFID scanners).
    """
    def __init__(self, server_url, session_id):
        self.server_url = server_url
        self.session_id = session_id
        self.buffer = []
        self.last_key_time = time.time()
        self.threshold_seconds = 0.05  # Time window between keystrokes for automated input

    def on_press(self, key):
        current_time = time.time()
        time_diff = current_time - self.last_key_time
        self.last_key_time = current_time

        try:
            # Handle standard character keys
            char = key.char
            if char is not None:
                # If there's a long pause, clear the buffer (prevents mixing manual typing)
                if time_diff > 0.3:
                    self.buffer = []
                self.buffer.append(char)
        except AttributeError:
            # Handle special keys like Enter
            if key == keyboard.Key.enter:
                epc = "".join(self.buffer).strip()
                self.buffer = []
                # Only process if it matches typical RFID length and speed
                if len(epc) >= 8:
                    send_to_server(self.server_url, self.session_id, epc)
                else:
                    print(f"[*] Input ignored (too short): {epc}")

    def run(self):
        print("\n=== KEYBOARD INTERCEPTOR MODE ACTIVE ===")
        print("[*] Running in background. You do NOT need to click the browser input field.")
        print("[*] Scan any RFID tag now...")
        with keyboard.Listener(on_press=self.on_press) as listener:
            listener.join()

# ==================== MODE 2: SERIAL PORT (USB COM) ====================
def run_serial_mode(server_url, session_id):
    """
    Reads directly from the serial port.
    Assumes Chainway R1 is set to Virtual COM Mode and outputs raw bytes or ASCII strings.
    """
    print("\n=== SERIAL PORT MODE ACTIVE ===")
    ports = list(serial.tools.list_ports.comports())
    if not ports:
        print("[!] No COM ports detected. Please connect the Chainway R1 via USB.")
        return
        
    print("[*] Available Ports:")
    for idx, p in enumerate(ports):
        print(f"  [{idx}] {p.device} - {p.description}")
        
    try:
        choice = int(input("\nSelect port index: "))
        selected_port = ports[choice].device
    except (ValueError, IndexError):
        print("[!] Invalid selection.")
        return

    baudrate = 115200  # Default baudrate for Chainway R1
    try:
        ser = serial.Serial(selected_port, baudrate, timeout=1)
        print(f"[+] Connected to {selected_port} at {baudrate} baud.")
        print("[*] Listening for tags...")
        
        buffer = bytearray()
        while True:
            if ser.in_waiting > 0:
                data = ser.read(ser.in_waiting)
                for b in data:
                    buffer.append(b)
                    
                # Chainway R1 Frame Protocol (Simplified / Auto-Read parser)
                # Usually: BB 02 22 00 11 ... 7E (or similar pattern)
                # If in pure ASCII line output:
                if b'\n' in buffer:
                    lines = buffer.split(b'\n')
                    for line in lines[:-1]:
                        epc = line.decode('utf-8', errors='ignore').strip()
                        if len(epc) >= 8:
                            send_to_server(server_url, session_id, epc)
                    buffer = bytearray(lines[-1])
            time.sleep(0.05)
            
    except Exception as e:
        print(f"[!] Error: {e}")

# ==================== MAIN EXECUTION ====================
if __name__ == "__main__":
    print("=" * 50)
    print("      CHAINWAY R1 MIDDLEWARE BRIDGE (OPTION 2)")
    print("=" * 50)
    
    server_url = input(f"Enter Server URL [{DEFAULT_SERVER_URL}]: ").strip()
    if not server_url:
        server_url = DEFAULT_SERVER_URL
        
    session_id = input("Enter Active Session ID (look at browser screen): ").strip()
    if not session_id:
        print("[!] Session ID is required.")
        sys.exit(1)
        
    print("\nSelect Connection Mode:")
    print("  [1] Keyboard Interceptor (Listens globally - scanner in keyboard wedge mode)")
    print("  [2] Serial Port (Virtual COM Port - scanner in USB-CDC mode)")
    
    mode = input("Choose mode [1 or 2]: ").strip()
    
    if mode == "1":
        try:
            interceptor = KeyboardInterceptor(server_url, session_id)
            interceptor.run()
        except KeyboardInterrupt:
            print("\nExiting...")
    elif mode == "2":
        try:
            run_serial_mode(server_url, session_id)
        except KeyboardInterrupt:
            print("\nExiting...")
    else:
        print("[!] Invalid mode selected.")
