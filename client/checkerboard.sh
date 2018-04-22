IP=$1
while :;do cat checkerboard.gz ;done | gunzip | python rgbgmovie.py $IP /dev/stdin 160 120 0
