#!/bin/bash

# initialize dbus in order to be able to change wallpaper
# export $(dbus-launch)
# eval $( dbus-launch --auto-syntax )

pid=$(pgrep -xn plasmashell)
export DBUS_SESSION_BUS_ADDRESS="$(grep -ao -m1 -P '(?<=DBUS_SESSION_BUS_ADDRESS=).*?\0' /proc/"$pid"/environ)"

# constand s
maxDistance=1300       #max distance of sun from center
daySec=86400               #max size of day to secconds
maxSize=100                 #max size of sun %

# get current time (epoh style)
hour=$(date +%T | cut -d ":" -f1)
minute=$(date +%T | cut -d ":" -f2)
seccond=$(date +%T | cut -d ":" -f3)
timeSec=$(( $hour * 60 * 60 +$minute * 60 + $seccond ))
#timeSec=$1

#paths
path='/home/vamartid/Pictures/rick_and_morty_bg/'
pathBg=$path'bg.png'
pathImage=$path'sun.png'
pathTmpImage=$path'tmp_sun.png'
pathNewBg=$path'res'$timeSec'.jpg'
#set possition of sun
#can also check 1+-(x^2)/140
# find distance (x possition of 2*max) - max to have negatives
possition=$(( $maxDistance*2*$timeSec/daySec-maxDistance ))

# set size of sun
cs=$(bc<<<"100*$timeSec/$daySec")
size=$(bc<<<"( ($cs-50)/5.6 )^2+20")
#echo $cs "   "   $size

#resize image
# -brightness-contrast 0,-40 -alpha set 
convert $pathImage -resize $size% $pathTmpImage

#delete old bg
rm $path'res'*'.jpg' &>/dev/null

#merge bg with the resized image
convert $pathBg $pathTmpImage -gravity center -geometry +$possition+0 -compose over -composite $pathNewBg


# set bg
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
'var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {
	d = allDesktops[i];
	d.wallpaperPlugin = "org.kde.snow";
	d.currentConfigGroup = Array(
		"Wallpaper",
		"org.kde.image",
		"General"
	);
	d.writeConfig(
		"Image",
		"file://'$pathNewBg'"
	)
}' 2>/dev/null
