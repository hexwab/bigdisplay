import socket
import time
import pygame
import struct
import random
import math
#import cv2

DISP_DEFAULT_PORT = 3337
DISP_TIMEOUT = 10
DISP_RECV_JUNK = 128
DISP_DEFAULT_IP = '192.168.0.89'    
DISP_DEFAULT_DIMS = (64, 30)

SURF_UDP_BLOCK_WIDTH = 16
SURF_UDP_BLOCK_HEIGHT = 15

FMT_DISPLAY_CLEAR = 0xe0
FMT_DISPLAY_WRITE_SUB = 0xe1
FMT_DISPLAY_WRITE_RGB = 0xe2
FMT_DISPLAY_FLUSH = 0xf0

class DisplayInterfaceData(object):
    def __init__(self, ip_addr, width, height, port=DISP_DEFAULT_PORT):
        self.skt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.ip_addr = ip_addr
        self.port = port
        self.pixels = []
        self.disp_dims = (width, height)

        for yy in range(height):
            self.pixels.append([])
            for xx in range(width):
                self.pixels[yy].append([0, 0, 0, 0])

    def get_frame_from_fp(self, fp):
        # read dims[0] x dims[1] x 4 bytes of data from fp
        bytes_ = self.disp_dims[0] * self.disp_dims[1] * 4
        data = fp.read(bytes_)
        #data = map(ord,fp.read(bytes_))
        x = 0
        y = 0
        s = []

        # bayer offsets
        w, h = self.disp_dims
        grn_t_off = 0
        blu_off = 1
        grn_b_off = (w * 2) + 1
        red_off = (w * 2)
        
        # calculate pixels on a per-row/col basis
        for y in range(h):
            row_off = y * (w * 4)
            rd = data[row_off+red_off  :row_off+red_off+w*2  :2]
            g1 = data[row_off+grn_t_off:row_off+grn_t_off+w*2:2]
            bl = data[row_off+blu_off  :row_off+blu_off+w*2  :2]
            g2 = data[row_off+grn_b_off:row_off+grn_b_off+w*2:2]

            self.pixels[y] = map(lambda x:(rd[x]+g1[x]+bl[x]+g2[x]),range(w))

            # for x in range(w):
            #     # PANEL order: green top, blue, green bottom, red (physical pixels)
            #     # DATA order:  red, green top, blue, green bottom
            #     #s = (data[row_off + (x * 2) + red_off], data[row_off + (x * 2) + grn_t_off], data[row_off + (x * 2) + blu_off], data[row_off + (x * 2) + grn_b_off])
            #     #s = map(ord, s)
            #     #s = (ord(data[row_off + (x * 2) + red_off]), ord(data[row_off + (x * 2) + grn_t_off]), ord(data[row_off + (x * 2) + blu_off]), ord(data[row_off + (x * 2) + grn_b_off]))
            #     #s = map(ord, s)
            #     #s = (ord(rd[x]), ord(g1[x]), ord(bl[x]), ord(g2[x]))
            #     s = (rd[x], g1[x], bl[x], g2[x])
            #     #s = map(ord, s)
            #     self.pixels[y][x] = s
            #     #print (s)

    def output_frame(self):
        # break output into blocks
        for xx in range(0, int(self.disp_dims[0] / SURF_UDP_BLOCK_WIDTH)):
            x = xx * SURF_UDP_BLOCK_WIDTH
            for yy in range(0, int(self.disp_dims[1] / SURF_UDP_BLOCK_HEIGHT)):
                y = yy * SURF_UDP_BLOCK_HEIGHT
                self.output_frame_region(x, y, SURF_UDP_BLOCK_WIDTH, SURF_UDP_BLOCK_HEIGHT)

        # send refresh command
        self.send_cmd_packet(FMT_DISPLAY_FLUSH, "")

    def output_frame_region(self, x, y, w, h):
        header = struct.pack(">BBBBBH", FMT_DISPLAY_WRITE_SUB, x, y, x + w, y + h, (w * h * 4))
        data = header

        for yy in range(y, y + h):
            #for xx in range(x, x + w):
            #    pix = self.pixels[yy][xx]
            #    #print(pix)
            #    data += struct.pack("BBBB", *list(pix))
            #pix = map(lambda s: struct.pack("BBBB",*list(s)), self.pixels[yy][x:x+w])
            pix = self.pixels[yy][x:x+w]
            data += ''.join(pix)
        #print len(data)
        self.send_cmd(data)
    
    def send_cmd_packet(self, cmd, data):
        header = struct.pack(">B", cmd)
        self.send_cmd(header + data)
        
    def send_cmd(self, cmd):
        self.skt.sendto(cmd, (self.ip_addr, self.port))
  
class DisplayInterfaceRGB(DisplayInterfaceData):
    skt = None
    surf = None

    def __init__(self, ip_addr, width, height, port=DISP_DEFAULT_PORT):
        super(DisplayInterfaceRGB, self).__init__(ip_addr, width, height, port)

        # Create Pygame surface
        pygame.init()
        self.surf = pygame.Surface((width, height))
        self.surf.fill((255, 255, 0))

    def send_all_surface(self):
        w = self.surf.get_width()
        h = self.surf.get_height()
        
        # send blocks (w/in UDP MTU size)
        for xx in range(0, int(w / SURF_UDP_BLOCK_WIDTH)):
            x = xx * SURF_UDP_BLOCK_WIDTH
            for yy in range(0, int(h / SURF_UDP_BLOCK_HEIGHT)):
                y = yy * SURF_UDP_BLOCK_HEIGHT
                self.send_surface_region(x, y, SURF_UDP_BLOCK_WIDTH, SURF_UDP_BLOCK_HEIGHT)

        # send refresh command
        self.send_cmd_packet(FMT_DISPLAY_FLUSH, "")
 
    def send_surface_region(self, x, y, w, h):
        header = struct.pack(">BBBBBH", FMT_DISPLAY_WRITE_RGB, x, y, x + w, y + h, (w * h * 3))
        data = header
        
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                #print(xx, yy)
                pix = self.surf.get_at((xx, yy))
                data += struct.pack("BBB", pix.r, pix.g, pix.b)

        self.send_cmd(data)

def test_mode(ip_addr, size):
    ifc = DisplayInterfaceRGB('192.168.0.89', size[0], size[1])
    col = pygame.Color("blue")
    h = 0
    n = 0
    patt = 0
    
    while True:
        ifc.surf.fill(col)

        if patt == 0:
            for y in range(size[1]):
                hsv = list(col.hsva)
                hsv[0] = (h + (y * 8)) % 360
                col.hsva = tuple(hsv)
                pygame.draw.line(ifc.surf, col, (0, y), (size[0], y), 1)

            n += 1
            h += 0.025
            h %= 360
        
        ifc.send_all_surface()

if __name__ == "__main__":
    test_mode(DISP_DEFAULT_IP, DISP_DEFAULT_DIMS)
