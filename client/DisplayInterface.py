import socket
import time

DISP_DEFAULT_PORT = 3333
DISP_TIMEOUT = 10
DISP_RECV_JUNK = 128

class DisplayInterface(object):
    skt = None

    def __init__(self, ip_addr, port=DISP_DEFAULT_PORT):
        self.skt = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.skt.connect((ip_addr, port))
        self.skt.setblocking(1)
        self.send_cmd('!white\r\n')
        time.sleep(0.05)
        self.send_cmd('!clear\r\n')
        time.sleep(0.05)

    def send_cmd(self, cmd):
        writer = self.skt.makefile(mode='w')
        writer.write(cmd)
        writer.flush()

    def test(self):
        while True:
            self.send_cmd('!white\r\n')
            time.sleep(0.1)
            self.send_cmd('!clear\r\n')
            time.sleep(0.1)

if __name__ == "__main__":
    ifc = DisplayInterface('192.168.0.89')
    ifc.test()
