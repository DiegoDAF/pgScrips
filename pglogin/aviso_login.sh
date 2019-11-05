echo "WHO:  

      $(w)

      $(who --all --boot --heading --runlevel)
      
      NOW:
      $(date +"%Y-%m-%d_%H%M%S")
      
" | mutt -s "PGLOGIN en $(hostname -f) - $(hostname -I)" -- diego@example.com
