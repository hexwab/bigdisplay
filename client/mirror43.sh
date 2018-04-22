IP=$1
W=$2
H=$3
gst-launch-1.0 -q  ximagesrc startx=160 endx=1120 starty=40 endy=760 ! videoconvert ! videoscale ! \
	       video/x-raw,width=$W,height=$H,framerate=60/1 ! \
	       rgb2bayer ! video/x-bayer,format=gbrg ! fdsink \
    | python rgbgmovie.py $IP /dev/stdin $W $H 0
