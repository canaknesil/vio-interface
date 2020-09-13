import socket
import subprocess
import threading
import time
import sys

class Vio:
    max_response_size = 1024
    vio_server_script = "vio_server.tcl"

    def __init__(self,
                 tclsh="tclsh",
                 port=33000):
        self.tclsh = tclsh
        self.port = port

    def start(self):
        # Start server
        def vio_server_start():
            subprocess.run([self.tclsh, Vio.vio_server_script, str(self.port)],
                           stdout=sys.stdout, stderr=sys.stderr)
            
        self.vio_server_thread = threading.Thread(target=vio_server_start)
        self.vio_server_thread.start()
        print("Started VIO server.")
        time.sleep(0.5)
                
        # Connect to server
        while True:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            try:
                self.socket.connect(("127.0.0.1", self.port))
                break
            except ConnectionRefusedError:
                print("Connection refused. Trying again.")
            self.socket.close()
            time.sleep(1)
        print("Socket connected.")


    def _execute_vio_command(self, command):
        self.socket.send(bytes(command + "\n", 'utf-8'))
        response = self.socket.recv(Vio.max_response_size).decode("utf-8")
                        
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
        
    def _print_response(response):
        print("Response: \"" + response + "\"")

    def test(self):
        res = self._execute_vio_command("test")
        if res == None or res != "Test successfull.":
            print("Test command unsuccessfull.")
            return False
        
        res = self._execute_vio_command("asdf")
        if res != None:
            print("Unsupported command did not reported.")
            return False
        
        res = self._execute_vio_command("read")
        if res == None:
            return False
        
        res = self._execute_vio_command("write")
        if res == None:
            return False
        
        return True

    def stop(self):
        # Stop server
        res = self._execute_vio_command("exit")
        
        # Disconnect client
        self.socket.close()
        print("Socket closed.")

        
def main():
    vio = Vio()
    vio.start()
    if vio.test():
        print("Server test successfull.")
    else:
        print("Server test FAILED.")

    # Read Write

    vio.stop()


if __name__ == "__main__":
    main()
