# pgScrips
Bashes to check postgres

### NOTA: La mayoria de los scrips requieren mutt para el envio de e-mails, si esta linea no te funciona, tendras que adaptar en base a tu configuracion:

```sh
echo test  $(date +"%Y-%m-%d %H:%M:%S") - $(hostname -f) - $(hostname -I) | mutt -s "test $(date +"%Y-%m-%d %H:%M:%S") - $(hostname -f) - $(hostname -I)" -- diegodaf@gmail.com
```

### Lista de scripts

  - alertaDiskLowSpace.sh - Envia un e-mail cuando se detecta poco espacio en una particion de linux. 
  - aviso_log_size.sh - Envia un e-mail cuando se detecta mucho espacio ocupado en la carpeta de logs
                            
