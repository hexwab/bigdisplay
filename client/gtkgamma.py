import gtk
import gobject
import math
import socket
import struct
import time
import random
import pickle
import subprocess32
import sys
skt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
SAVEFILE = "display.gamma"
IP = sys.argv[1]
print IP
def send(cmd,data):
    #print cmd, data
    skt.sendto(struct.pack("<B",cmd)+data, (IP, 3337))
    


class PyApp(gtk.Window):

    def __init__(self):
        super(PyApp, self).__init__()

        #self.set_title("Simple drawing")
        self.resize(800, 250)
        self.set_position(gtk.WIN_POS_CENTER)
        self.connect("destroy", gtk.main_quit)
        self.vbox = gtk.VBox()
        self.hbox = gtk.HBox()
        self.hbox2 = gtk.HBox()
        self.hbox3 = gtk.HBox()
        self.ranges = [ gtk.HScale(), gtk.HScale(), gtk.HScale() ]
        self.curves = [ gtk.Curve(), gtk.Curve(), gtk.Curve() ]
        self.buttons = [ gtk.Button(), gtk.Button(), gtk.Button(), gtk.Button() ]
        self.testarea = gtk.DrawingArea()
        self.test = False
#        self.testarea.set_width(250)
#        self.testarea.set_height(250)
        for curve in self.curves:
            curve.set_range(0,255,0,0xffef)
            curve.set_gamma(2.0)
            #curve.connect('event',self.frame,curve)
            self.hbox.add(curve)
        for range in self.ranges:
            range.set_range(0,1023)
            #range.set_draw_value(False)
            self.hbox2.add(range)
        for button in self.buttons:
            self.hbox3.add(button)
        self.buttons[0].set_label("Load")
        self.buttons[0].connect('clicked',self.load,self)
        self.buttons[1].set_label("Save")
        self.buttons[1].connect('clicked',self.save,self)
        self.buttons[2].set_label("Free")
        self.buttons[2].connect('clicked',self.settype,"free")
        self.buttons[3].set_label("Spline")
        self.buttons[3].connect('clicked',self.settype,"spline")
        self.testcheck = gtk.CheckButton('Test')
        self.testcheck.connect('toggled',self.settest)
        self.hbox3.add(self.testcheck)
        self.ranges[0].set_value(900)
        self.ranges[1].set_value(500)
        self.ranges[2].set_value(1023)
        #self.hbox.add(self.testarea)
        self.vbox.add(self.hbox)
        self.vbox.add(self.hbox2)
        self.vbox.add(self.hbox3)
        self.add(self.vbox)
        self.show_all()
        #print "%x" % self.testarea.window.xid
        timer = gobject.timeout_add(200, self.frame, self.curves)
        
    #def load(self,*args):
    #    print(self.buttons[0].get_label())
        
    def frame(self, curve, *args):
        c0 = curve[0].get_vector()
        c1 = curve[1].get_vector()
        c2 = curve[2].get_vector()
        #print struct.pack("<128H", *c0[0:128])
        send(0xd0, struct.pack("<128H", *c0[0:128]))
        send(0xd1, struct.pack("<128H", *c0[128:256]))
        send(0xd2, struct.pack("<128H", *c1[0:128]))
        send(0xd3, struct.pack("<128H", *c1[128:256]))
        send(0xd4, struct.pack("<128H", *c2[0:128]))
        send(0xd5, struct.pack("<128H", *c2[128:256]))
        send(0xde,'') # user

        send(0xc0,struct.pack("<3H",
                              self.ranges[0].get_value(),
                              self.ranges[1].get_value(),
                              self.ranges[2].get_value()
                              )) # set OE widths
        #send(0xdf,'') # flash

        if self.test:
            w = 16
            h = 1
            for y in range(16):
                line = ""
                for x in range(16):
                    line += struct.pack("BBB",x+y*16,x+y*16,x+y*16)
                x = 0
                send(0xe2, struct.pack(">BBBBH", x, y, x + w, y + h, (w * h * 3)) + line)
            send(0xf0,'') # flush

                
        #print curve.get_vector()
        timer = gobject.timeout_add(200, self.frame, curve)

    def save(self,*args):
        file = open(SAVEFILE, "w")
        obj = [self.curves[0].get_vector(), 
               self.curves[1].get_vector(), 
               self.curves[2].get_vector(),
               self.ranges[0].get_value(),
               self.ranges[1].get_value(),
               self.ranges[2].get_value()
        ]
        pickle.dump(obj, file, -1)
        
    def load(self,*args):
        file = open(SAVEFILE, "r")
        obj = pickle.load(file)
        for i in range(3):
            self.curves[i].set_vector(obj[i])
            self.ranges[i].set_value(obj[i+3])

    def settype(self,*args):
        for i in range(3):
            self.curves[i].set_curve_type(args[1])

    def settest(self,*args):
        self.test = self.testcheck.get_active()

PyApp()
gtk.main()
