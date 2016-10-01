#!/bin/bash

searchURLbykey() {
	local query="$(echo $1 | tr " " +)"
	url=$(lynx -dump https://www.google.com/search?q=$query | grep -Po '(?<=d:)[^&]+' | grep http |head -n1)
	if [ -z "$url" ]; then
		url="La pagina non è disponibile"
	fi
	echo $url
}

searchIMGbyKey() {
	local query=$(echo $1 | tr " " +)
	local number=1
	local url=$(wget --user-agent 'Mozilla/5.0' -qO - "www.google.be/search?q=$query\&tbm=isch" | sed 's/</\n</g' | grep '<img' | head -n"$number" | tail -n1 | sed 's/.*src="\([^"]*\)".*/\1/')
	 wget -q -O /tmp/telegramimg.jpg $url
 }
 
searchYTbykey() {
	local query=$(echo $1 | tr " " +)
	local number=1
	local url=$(wget --user-agent 'Mozilla/5.0' -qO - "www.youtube.com/results?search_query=$query" | tail -n +1000 | awk -F 'href=' '{print $2}' | awk -vRS='"' '{print $1}' | grep 'watch?v' | head -n $number)
	echo "https://www.youtube.com$url"

 }

 getManDesc() {
	 [ "$1" == "" ] && return 
	 local txt="$(LANG='C' man "$1" | col -b 2> /dev/null)"
	 if [ "$txt" == "" ]; then echo "Non c'è il manuale per $1" ; return; fi
	 local out=$(echo "$txt" | ./mangrep)
	 echo -n "$out" | head -c 4000
	 echo "..."
	 echo "Continua a leggere su $(searchURLbykey "site:linux.die.net man $1")"
 }

isAnAdmin() {
	grep -wq "$1" /tmp/admins
	return $?
}

if [ "$1" = "source" ];then
	# Place the token in the token file
	TOKEN=$(cat token)
	# Set INLINE to 1 in order to receive inline queries.
	# To enable this option in your bot, send the /setinline command to @BotFather.
	INLINE=0
	# Set to .* to allow sending files from all locations
	FILE_REGEX='/tmp/telegramimg.jpg'

elif [ ${CHAT[ID]} == -1001059420604 ] || isAnAdmin "${USER[USERNAME]}"; then
	if ! tmux ls | grep -v send | grep -q $copname; then
		[ ! -z ${URLS[*]} ] && {
		curl -s ${URLS[*]} -o $NAME
			send_file "${CHAT[ID]}" "$NAME" "$CAPTION"
			rm "$NAME"
		}
		[ ! -z ${LOCATION[*]} ] && send_location "${CHAT[ID]}" "${LOCATION[LATITUDE]}" "${LOCATION[LONGITUDE]}"

		# Inline
		if [ $INLINE == 1 ]; then
			# inline query data
			iUSER[FIRST_NAME]=$(echo "$res" | sed 's/^.*\(first_name.*\)/\1/g' | cut -d '"' -f3 | tail -1)
			iUSER[LAST_NAME]=$(echo "$res" | sed 's/^.*\(last_name.*\)/\1/g' | cut -d '"' -f3)
			iUSER[USERNAME]=$(echo "$res" | sed 's/^.*\(username.*\)/\1/g' | cut -d '"' -f3 | tail -1)
			iQUERY_ID=$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -1)
			iQUERY_MSG=$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -6 | head -1)

			# Inline examples
			if [[ $iQUERY_MSG == photo ]]; then
				answer_inline_query "$iQUERY_ID" "photo" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg"
			fi

			if [[ $iQUERY_MSG == sticker ]]; then
				answer_inline_query "$iQUERY_ID" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			fi

			if [[ $iQUERY_MSG == gif ]]; then
				answer_inline_query "$iQUERY_ID" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			fi
			if [[ $iQUERY_MSG == web ]]; then
				answer_inline_query "$iQUERY_ID" "article" "GitHub" "http://github.com/topkecleon/telegram-bot-bash"
			fi
		fi
	fi
	MESSAGECMD=${MESSAGE%% *}
	MESSAGEARG=${MESSAGE#* }
	[ "$MESSAGECMD" == "$MESSAGE" ] && MESSAGEARG=""
	MESSAGECMD=$(echo "$MESSAGECMD" | cut -f1 -d"@") #per i comandi da click

	case "$MESSAGECMD" in
			'/wikipedia')
				send_message "${CHAT[ID]}" "$(searchURLbykey "site:it.wikipedia.org "$MESSAGEARG"")"	
				;;
			'/archwiki')
				send_message "${CHAT[ID]}" "$(searchURLbykey "site:wiki.archlinux.org "$MESSAGEARG"")"
				;;
			'/debianwiki')
				send_message "${CHAT[ID]}" "$(searchURLbykey	"site:wiki.debian.org "$MESSAGEARG"")"
				;;
			'/gentoowiki')
				send_message "${CHAT[ID]}" "$(searchURLbykey "site:wiki.gentoo.org "$MESSAGEARG"")"
				;;
			'/ubuntuwiki')
				send_message "${CHAT[ID]}" "$(searchURLbykey	"site:wiki.ubuntu.com "$MESSAGEARG"")"
				;;
			'/ubuntuwiki-it')
				send_message "${CHAT[ID]}" "$(searchURLbykey	"site:wiki.ubuntu-it.org "$MESSAGEARG"")"
				;;
			'/fbsdwiki')
				send_message "${CHAT[ID]}" "$(searchURLbykey	"site:wiki.freebsd.org "$MESSAGEARG"")"
				;;
			'/github')
				send_message "${CHAT[ID]}" "$(searchURLbykey	"site:github.com "$MESSAGEARG"")"
				;;
			'/imgsrc')
				searchIMGbyKey "$MESSAGEARG"
				send_file "${CHAT[ID]}" "/tmp/telegramimg.jpg"
				rm -f /tmp/telegramimg.jpg
				;;
		#	'/youtube')
		#		send_message "${CHAT[ID]}" "$(searchYTbykey  "site:www.youtube.com "$MESSAGEARG"")"
		#		;;
			'/info')
				send_message "${CHAT[ID]}" "Questo è UXIbot: il bot di @UnixItalia.
Il bot è un fork di telegram-bash-bot
I sorgenti software sono reperibili al seguente link: https://github.com/andrea993/UXIbot"
				;;
			'/start' | '/help')
				send_message "${CHAT[ID]}" "Cordiali saluti dal bot di Unix Italia
Vieni a trovarci su Facebook: https://www.facebook.com/groups/unixitaliagroup

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
/imgsrc: Cerca la minatura di un'immagine
/man: Mostra una pagina di manuale
/lsadmin: Mostra gli admin

Comandi per soli amministratori:
/say: Ripete 10 volte
/random: Scrive n caratteri casuali
/link: Link bot developers
/addadmin: Aggiunge un admin
/deladmin: Rimuove un admin
/calc: Calcola con octave
/exec: Esegue un comando sul server !!CAUTELA!!
"
				;;
				'/lsadmin')
					send_message "${CHAT[ID]}" "$(cat /tmp/admins)"
				;;
				'/man')
					send_message "${CHAT[ID]}" "$(getManDesc "$MESSAGEARG")"
				;;
			*)
				#send_message "${CHAT[ID]}" "$MESSAGE" #ripete i comandi
		esac
		#ADMIN commands
		if isAnAdmin "${USER[USERNAME]}" ;then	
			case "$MESSAGECMD" in
				'/say')
					for i in {1..10} ;do
						send_message "${CHAT[ID]}" "$MESSAGEARG"
					done
				;;
				'/addadmin')
					if (( ${#MESSAGEARG} > 4)); then
						if ! isAnAdmin $MESSAGEARG ;then
							echo $MESSAGEARG >> admins.txt
							cp -f admins.txt /tmp/admins
							send_message "${CHAT[ID]}" "$MESSAGEARG aggiunto tra gli admin"
						else
							send_message "${CHAT[ID]}" "$MESSAGEARG è già un admin"
						fi
					fi
				;;
				'/deladmin')
					if isAnAdmin $MESSAGEARG ;then
						sed "/$MESSAGEARG/d" /tmp/admins > ./admins.txt
				      cp -f admins.txt /tmp/admins	
					   send_message "${CHAT[ID]}" "$MESSAGEARG rimosso dagli gli admin"
					else
						send_message "${CHAT[ID]}" "$MESSAGEARG non è stato trovato tra gli admin"
					fi
				;;
				'/link') 
					send_message "${CHAT[ID]}" '
Github: https://github.com/andrea993/UXIbot
BotFather: https://core.telegram.org/bots 
API: https://core.telegram.org/bots/api
Curl:
http://unnikked.ga/getting-started-with-telegram-bots/
https://www.domoticz.com/wiki/Telegram_Bot#Using_Telegram_Bot_to_Send_Messages_with_Curl'
				;;
				'/random')
					if [[ $MESSAGEARG =~ ^-?[0-9]+$ ]]; then
						send_message "${CHAT[ID]}" "$(./random $MESSAGEARG)"
					fi
				;;
				'/calc')
					send_message "${CHAT[ID]}" "$(sh -c "octave --silent --eval \"$MESSAGEARG\"" 2>&1)"
				;;
				'/exec')
					local out=$(bash -c "$MESSAGEARG 2>&1")
					send_message "${CHAT[ID]}" "$out"
				;;
			esac
		fi
else 
	send_message "${CHAT[ID]}" "Questo bot funziona soltanto su @UnixItalia"
fi
