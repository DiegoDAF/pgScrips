# pgScrips
Bashes to check postgres

### NOTA: La mayoria de los scrips requieren mutt para el envio de e-mails, si esta linea no te funciona, tendras que adaptar en base a tu configuracion:

```sh
echo test  $(date +"%Y-%m-%d %H:%M:%S") - $(hostname -f) - $(hostname -I) | mutt -s "test $(date +"%Y-%m-%d %H:%M:%S") - $(hostname -f) - $(hostname -I)" -- diegodaf@gmail.com
```
Check howToInstallMutt.txt

### Lista de scripts

  * alertaDiskLowSpace.sh - Envia un e-mail cuando se detecta poco espacio en una particion de linux. 
  * aviso_log_size.sh - Envia un e-mail cuando se detecta mucho espacio ocupado en la carpeta de logs
  * pglogin - Script que envia una alerta por email cuando alguien inicia sesion en bash                          
  * .psqlrc - Mi gusto para la configuracion de PSQL
  * .psqlrc-commands.d - Mi adaptacion de [bitbucket.org/adamkg/libakg/src/default/dot/psqlrc-commands.d](https://daf.tf/urls/?r=159)
