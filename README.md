#UXIbot

<img src="uxibot_photo.jpg" width="250">

UXIbot è il bot di di [Unix Italia](https://www.facebook.com/groups/unixitaliagroup) pensato per gestire gruppi telegram che trattano UNIX

Questo progetto è un fork di [bashbot](https://github.com/topkecleon/telegram-bot-bash), usa [json.sh](https://github.com/dominictarr/JSON.sh) e tmux 

##Funzionalità
````
Comandi disponibili:
/start: Avvia il bot e mostra questo messaggio
/info: A proposito
/wikipedia: Cerca su wikipedia
/archwiki: Cerca nella wiki di arch
/debianwiki: Cerca nella wiki di debian
/gentoowiki: Cerca nella wiki di gentoo
/ubuntuwiki: Cerca nella wiki di ubuntu in inglese
/ubuntuwiki-it: Cerca nella wiki di ubuntu in italiano
/fbsdwiki: Cerca nella wiki di freeBSD
/github: Cerca un progetto o un developer su github
/man: Mostra la descrizione e il link di una pagina di manuale
/imgsrc: Cerca la minatura di un'immagine
/calc: Una rapida calcolatrice
/lsadmin: Mostra gli admin

Comandi per soli amministratori:
/say: Ripete 10 volte
/random: Scrive n caratteri casuali
/link: Link bot developers
/addadmin: Aggiunge un admin
/deladmin: Rimuove un admin
/exec: Esegue un comando sul server !!CAUTELA!!
```

##Installazione
````
$ make
# make install
````
##Avvio
E' necessario munirsi di un TOKEN fornito da [BotFather](https://core.telegram.org/bots)
````
$ uxibot $TOKEN
````
##Disinstallazione
```
# make uninstall
````
