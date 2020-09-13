import socket
import subprocess
import threading
import time
import sys


tclsh = "/usr/local/bin/tclsh8.6"
port = 33000
max_response_size = 1024

# Start VIO server
def vio_server_start():
    subprocess.run([tclsh, "vio_server.tcl", str(port)], stdout=sys.stdout, stderr=sys.stderr)
    
vio_server_thread = threading.Thread(target=vio_server_start)
vio_server_thread.start()
print("Started VIO server.")
time.sleep(0.5)

# Client
while True:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect(("127.0.0.1", port))
        break
    except ConnectionRefusedError:
        print("Connection refused. Trying again.")
        sock.close()
    time.sleep(1)
print("Socket connected.")

def execute_vio_command(sckt, command):
    sckt.send(bytes(command + "\n", 'utf-8'))
    response = sckt.recv(max_response_size).decode("utf-8")

    status = response[0]
    response = response[1:]

    length = len(response) # response ends with \r\n
    response = response[0:length-2]
    
    if status == "1":
        return response
    elif status == "0":
        print("Command failed.")
        return None
    else:
        print("Response has invalid status byte")
        return None

def print_response(response):
    print("Response: \"" + response + "\"")

def vio_server_test(sckt):
    res = execute_vio_command(sckt, "test")
    if res == None or res != "Test successfull.":
        print("Test command unsuccessfull.")
        return False

    res = execute_vio_command(sckt, "asdf")
    if res != None:
        print("Unsupported command did not reported.")
        return False

    res = execute_vio_command(sckt, "read")
    if res == None:
        return False

    res = execute_vio_command(sckt, "write")
    if res == None:
        return False

    return True

if vio_server_test(sock):
    print("Server test successfull.")
else:
    print("Server test FAILED.")


    
# Stop server.
res = execute_vio_command(sock, "exit")


# Stop client.
sock.close()
print("Socket closed.")

