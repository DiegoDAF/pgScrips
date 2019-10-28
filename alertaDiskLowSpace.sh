#!/bin/sh
# set -x
# Manda mail si es menor a 2 gb libre
# -------------------------------------------------------------------------
# Setea el mail del que recibe
ADMIN=diego.feito@ingenico.com
# Setea la alerta en 2 gb
#ALERT=2147483648
# 4gb
#ALERT=4294967296
# 40 Gb
ALERT=42949672960
# Ejemplo: EXCLUDE_LIST="^Filesystem|tmpfs|cdrom|//|sv15"
EXCLUDE_LIST="^Filesystem|tmpfs|cdrom|//|sv15|sv27|bkprsp"
THISHOST=$(hostname -f)
THISIP=$(hostname -I)
#
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
function main_prog() {
while read output;
do
#echo $output


  busca=$(echo "$salto" | grep -o '%')
  control=$(echo $busca)
 # echo $control

#if [ "echo $control" =! "" ] ; then
if [ "$control" == "%" ] ; then

  usep=$(echo $output | awk '{ print $3}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{print $5}')
  filesys=$(echo $output | awk '{print $5}')
  porcen=$(echo $output | awk '{print $4}')
  size=$(echo $output | awk '{print $1}')

else

  usep=$(echo $output | awk '{ print $4}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{print $6}')
  filesys=$(echo $output | awk '{print $1}')
  porcen=$(echo $output | awk '{print $5}')
  size=$(echo $output | awk '{print $2}')
fi
#       echo $usep
#       echo $filesys

         if [ $usep -le $ALERT ] ; then
                 if [ $size -ge $ALERT ] ; then
             echo -e "$THISHOST \nEspacio libre: $usep\nPorcentaje de uso: $porcen \nParticion: $partition \nFilesystem: $filesys " | mutt -s "LOW DISK SPACE ALERT $THISHOST - $THISIP" $ADMIN
                 fi
         fi
#fi
done
}
if [ "$EXCLUDE_LIST" != "" ] ; then
  df -P | grep -vE "${EXCLUDE_LIST}" | awk '{ print $1 " " $2 " " $3 " " $4 " " $5 " " $6 }' | main_prog
else
  df -P | grep -vE "^Filesystem|tmpfs|cdrom|boot|//|sv15|sv27|bkprsp" | awk '{ print $1 " " $2 " " $3 " " $4 " " $5 " " $6 }' | main_prog

fi

