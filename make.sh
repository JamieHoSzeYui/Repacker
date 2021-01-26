#!/bin/bash

OUTDIR=$(realpath out)
tmpdir=$(realpath temp)
I2S="img2sdat/img2sdat.py"
echo "Creating work directories."
rm -rf temp/ out/ >> /dev/null
mkdir temp out 
if [[ ! -n $1 ]]; then 
    echo "BRUH : What are you doing?"
    exit 
fi 

DEVICE=$2 
IMGDIR=$(realpath $3) 

if [[ ! -n $3 ]]; then 
    mkdir pull 
    echo "No input provided, pulling Images !"
    adb reboot recovery
    echo "Pulling system."
    adb pull /dev/block/mapper/system pull/system.img >> /dev/null 
    echo "Pulling vendor."
    adb pull /dev/block/mapper/vendor pull/vendor.img >> /dev/null 
    echo "Pulling boot."
    adb pull /dev/block/by-name/boot pull/boot.img >> /dev/null 
    IMGDIR=$(realpath pull/)
fi 

NAME=$1

echo "Converting raw image to sparse.."
img2simg $IMGDIR/system.img $tmpdir/system.img 
img2simg $IMGDIR/vendor.img $tmpdir/vendor.img 
cp -f $IMGDIR/boot.img $OUTDIR/boot.img 

echo "Converting sparse image into dat.."
python3 $I2S -o $OUTDIR -v 4 -p system "$tmpdir/system.img" >> /dev/null 
python3 $I2S -o $OUTDIR -v 4 -p vendor "$tmpdir/vendor.img" >> /dev/null 

echo "Compressing with brotli.."
brotli -3jf $outdir/system.new.dat 
brotli -3jf $outdir/vendor.new.dat 

echo "Compression done. "
echo "You can now zip the zip but script won't do it cuz i got bored"

