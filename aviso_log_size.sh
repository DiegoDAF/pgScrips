#!/bin/sh
# set -x
# Manda mail si es menor a 2 gb libre
# -------------------------------------------------------------------------
# Setea el mail del que recibe
ADMIN=diego.feito@ingenico.com
# Setea la alerta en 2 gb
#ALERT=2147483648
# 4gb
ALERT=4294967296
# 40 Gb
#ALERT=42949672960
# Ejemplo: EXCLUDE_LIST="^Filesystem|tmpfs|cdrom|//|sv15"
EXCLUDE_LIST="^Filesystem|tmpfs|cdrom|//|sv15|sv27|bkprsp"
THISHOST=$(hostname -f)
THISIP=$(hostname -I)
#
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#

 pgLOGFOLDER=$(psql -c "select setting from pg_settings where name = 'log_directory';" -t)
 pgLOGSIZE=$(du $pgLOGFOLDER --max-depth=1 --bytes | cut -f1)
 
 if [ $pgLOGSIZE -ge $ALERT ] ; then
    echo "[$(date +"%Y-%m-%d %H:%M:%S")][ALERT] LOG FOLDER SIZE $pgLOGSIZE > $ALERT --> $pgLOGFOLDER"   
    echo -e "$THISHOST \nAlerta de uso de espacio en LOG FOLDER: $pgLOGFOLDER - $pgLOGSIZE > $ALERT" | mutt -s "TOO MUTCH LOG ALERT $THISHOST - $THISIP" $ADMIN
 fi

