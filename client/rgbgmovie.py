import random, time, sys, os
from DisplayInterfaceData import DisplayInterfaceData

IP = sys.argv[1]
FILE_NAME = sys.argv[2]
WIDTH = sys.argv[3]
HEIGHT = sys.argv[4]
WAIT = sys.argv[5]

def main():
    ifc = DisplayInterfaceData(IP, int(WIDTH)/2, int(HEIGHT)/2, 3337)
    f = open(FILE_NAME, "rb")

    while True:
        ifc.get_frame_from_fp(f)
        ifc.output_frame()
        if WAIT: time.sleep(1 / 25.0)

if __name__ == "__main__":
    main()


    
