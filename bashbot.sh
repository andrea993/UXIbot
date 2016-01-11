#!/bin/bash
# bashbot, the Telegram bot written in bash.
# Written by @topkecleon, Juan Potato (@awkward_potato), Lorenzo Santina (BigNerd95) and Daniil Gentili (danog)
# https://github.com/topkecleon/telegram-bot-bash

# Depends on ./JSON.sh (http://github.com/dominictarr/./JSON.sh),
# which is MIT/Apache-licensed
# And on tmux (https://github.com/tmux/tmux),
# which is BSD-licensed


# This file is public domain in the USA and all free countries.
# If you're in Europe, and public domain does not exist, then haha.

TOKEN=$1
URL='https://api.telegram.org/bot'$TOKEN
MSG_URL=$URL'/sendMessage'
PHO_URL=$URL'/sendPhoto'
FILE_URL='https://api.telegram.org/file/bot'$TOKEN'/'
UPD_URL=$URL'/getUpdates?offset='
OFFSET=0
cp -f admins.txt /tmp/admins #siccome il file è di uso frequente lo tengo in RAM
#trap "rm -f /tmp/admins" 0 1 2 5 15

send_message() {
	local chat="$1"
	local text="$(echo "$2" | sed 's/ mykeyboardstartshere.*//g;s/ myimagelocationstartshere.*//g')"
	local keyboard="$(echo "$2" | sed '/mykeyboardstartshere /!d;s/.*mykeyboardstartshere //g;s/ myimagelocationstartshere.*//g')"
	local image="$(echo "$2" | sed '/myimagelocationstartshere /!d;s/.*myimagelocationstartshere //g;s/ mykeyboardstartshere.*//g;')"
	if [ "$keyboard" != "" ]; then
		send_keyboard "$chat" "$text" "$keyboard"
		local sent=y
	fi
	if [ "$image" != "" ]; then
		send_photo "$chat" "$image"
		local sent=y
	fi
	if [ "$sent" != "y" ];then
		res=$(curl -s "$MSG_URL" -F "chat_id=$chat" -F "text=$text")
	fi
}

send_keyboard() {
	local chat="$1"
	local text="$2"
	shift 2
	local keyboard=init
	for f in $*;do local keyboard="$keyboard, [\"$f\"]";done
	local keyboard=${keyboard/init, /}
	res=$(curl -s "$MSG_URL" --header "content-type: multipart/form-data" -F "chat_id=$chat" -F "text=$text" -F "reply_markup={\"keyboard\": [$keyboard],\"one_time_keyboard\": true}")
}

send_photo() {
	res=$(curl -s "$PHO_URL" -F "chat_id=$1" -F "photo=@$2")
}

startproc() {
	local copname=$1
	copname=${copname//-/}
	local TARGET="$2"
	echo $copname $TARGET 
	mkdir -p "$copname"
	mkfifo $copname/out
	#tmux new-session -d -n $copname "./question 2>&1>$copname/out"
	#local pid=$(ps aux | sed '/tmux/!d;/'$copname'/!d;/sed/d;s/'$USER'\s*//g;s/\s.*//g')
	tmux new-session -d "./question 2>&1>$copname/out"
	local pid=$(ps aux | grep "/question 2>&1>$copname/out" | grep -v grep | awk '{ print $2 }')
	echo $pid>$copname/pid
	while ps aux | grep -v grep | grep -q $pid;do
		read -t 10 line
		[ "$line" != "" ] && send_message "$TARGET" "$line"
		line=
	done <$copname/out
}
inproc() {
	local copname="$1"
	local copid="$2"
	local MESSAGE="$3"
	local PHOTO_ID="$4"
	shift 2
	tmux send-keys -t $copname "$MESSAGE
"
	ps aux | grep -v grep | grep -q "$copid" || { rm -r $copname; };
}

searchURLbykey() {
	local url=$(curl -s --get --data-urlencode "q=$1" http://ajax.googleapis.com/ajax/services/search/web?v=1.0 | sed 's/"unescapedUrl":"\([^"]*\).*/\1/;s/.*GwebSearch",//')
	if [ ${url:0:1} = "{" ];then
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

 getManDesc() {
	 [ "$1" == "" ] && return 
	 local txt=$(bash -c "LANG="C" man $1 | col -b" 2> /dev/null)
	 if [ "$txt" == "" ]; then echo "Non c'è il manuale per $1" ; return; fi
	 echo $1 | tr '[:lower:]' '[:upper:]'
	 IFS=$'\n'
	 read -rd '' -a array <<<"$txt"
	 local i=0
	 local tabi=$(printf '\t')
	 while [ ${array[$i]} != "DESCRIPTION" ] && (( $i < ${#array[@]} )); do let i+=1; done 
	 let i+=1
	 while ( [[ "${array[$i]}" == " "* ]] || [[ "${array[$i]}" == $'\t'* ]] ) && (( $i < ${#array[@]} )); do 
		 echo ${array[$i]} | sed -e "s/[[:space:]]\+/ /g" | sed -e 's/^[ \t]*//'
		 let i+=1; 
	 done
	 echo "Continua a leggere su $(searchURLbykey "site:linux.die.net man $1")"
 }

isAnAdmin() {
	while read e; do
		[[ "$e" == "$1" ]] && return 0
	done </tmp/admins
	return 1
}

process_client() {
	local MESSAGE=$1
	local TARGET=$2
	local PHOTO_ID=$3
	local USERNAME=$4
	local MESSAGECMD=${MESSAGE%% *}
	local MESSAGEARG=${MESSAGE#* }
	[ "$MESSAGECMD" == "$MESSAGE" ] && MESSAGEARG=""
	MESSAGECMD=$(echo $MESSAGECMD | cut -f1 -d"@") #per i comandi da click
	local msg=""
	local copname="$TARGET"
	local copidname="$copname/pid"
	local copid="$(cat $copidname 2>/dev/null)"
	if [ "$copid" = "" ]; then
		case $MESSAGECMD in
			'/wikipedia')
				send_message "$TARGET" "$(searchURLbykey "site:it.wikipedia.org $MESSAGEARG")"	
				;;
			'/archwiki')
				send_message "$TARGET" "$(searchURLbykey "site:wiki.archlinux.org $MESSAGEARG")"
				;;
			'/debianwiki')
				send_message "$TARGET" "$(searchURLbykey	"site:wiki.debian.org $MESSAGEARG")"
				;;
			'/gentoowiki')
				send_message "$TARGET" "$(searchURLbykey "site:wiki.gentoo.org $MESSAGEARG")"
				;;
			'/ubuntuwiki')
				send_message "$TARGET" "$(searchURLbykey	"site:wiki.ubuntu.com $MESSAGEARG")"
				;;
			'/ubuntuwiki-it')
				send_message "$TARGET" "$(searchURLbykey	"site:wiki.ubuntu-it.org $MESSAGEARG")"
				;;
			'/fbsdwiki')
				send_message "$TARGET" "$(searchURLbykey	"site:wiki.freebsd.org $MESSAGEARG")"
				;;
			'/github')
				send_message "$TARGET" "$(searchURLbykey	"site:github.com $MESSAGEARG")"
				;;
			'/imgsrc')
				searchIMGbyKey "$MESSAGEARG"
				send_photo	"$TARGET" "/tmp/telegramimg.jpg"
				rm -f /tmp/telegramimg.jpg
				;;
			'/question')
				startproc "$copname" "$TARGET"&
				;;
			'/info')
				send_message "$TARGET" "Questo è UXIbot: il bot di Unix Italia"
				;;
			'/start' | '/help')
				send_message "$TARGET" "Cordiali sauti dal bot di Unix Italia
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
/man: Mostra la descrizione e il link di una pagina di manuale
/imgsrc: Cerca la minatura di un'immagine
/calc: Una rapida calcolatrice
/lsadmin: Mostra gli admin

Comandi per soli amministratori:
/say: Ripete 10 voltei
/random: Scrive n caratteri casuali
/link: Link bot developers
/addadmin: Aggiunge un admin
/deladmin: Rimuove un admin
"
				;;
				'/lsadmin')
					send_message "$TARGET" "$(cat /tmp/admins)"
				;;
				'/man')
					send_message "$TARGET" "$(getManDesc $MESSAGEARG)"
				;;
				'/calc')
					send_message "$TARGET" "$(bash -c "echo $MESSAGEARG | bc" 2> /dev/null)"
				;;
			*)
				#send_message "$TARGET" "$MESSAGE" #ripete i comandi
		esac
		#ADMIN commands
		if isAnAdmin $USERNAME ;then	
			case $MESSAGECMD in
				'/say')
					for i in {1..10} ;do
						send_message "$TARGET" "$MESSAGEARG"
					done
				;;
				'/addadmin')
					if (( ${#MESSAGEARG} > 4)); then
						if ! isAnAdmin $MESSAGEARG ;then
							echo $MESSAGEARG >> admins.txt
							cp -f admins.txt /tmp/admins
							send_message "$TARGET" "$MESSAGEARG aggiunto tra gli admin"
						else
							send_message "$TARGET" "$MESSAGEARG è già un admin"
						fi
					fi
				;;
				'/deladmin')
					if isAnAdmin $MESSAGEARG ;then
						sed "/$MESSAGEARG/d" /tmp/admins > ./admins.txt
				      cp -f admins.txt /tmp/admins	
					   send_message "$TARGET" "$MESSAGEARG rimosso dagli gli admin"
					else
						send_message "$TARGET" "$MESSAGEARG non è stato trovato tra gli admin"
					fi
				;;
				'/link') 
					send_message "$TARGET" '
Github: https://github.com/andrea993/UXIbot
BotFather: https://core.telegram.org/bots 
API: https://core.telegram.org/bots/api
Curl:
http://unnikked.ga/getting-started-with-telegram-bots/
https://www.domoticz.com/wiki/Telegram_Bot#Using_Telegram_Bot_to_Send_Messages_with_Curl'
				;;
				'/random')
					if [[ $MESSAGEARG =~ ^-?[0-9]+$ ]]; then
						send_message "$TARGET" "$(./random $MESSAGEARG)"
					fi
				;;
			esac
		fi
	else
		case $MESSAGE in
			'/cancel')
				kill $copid
				rm -r $copname
				send_message "$TARGET" "Command canceled."
				;;
			*) inproc "$copname" "$copid" "$MESSAGE" "$PHOTO_ID";;
		esac
	fi
}

while true; do {


res=$(curl -s $UPD_URL$OFFSET)

	TARGET=$(echo $res | ./JSON.sh | egrep '\["result",0,"message","chat","id"\]' | cut -f 2)
	OFFSET=$(echo $res | ./JSON.sh | egrep '\["result",0,"update_id"\]' | cut -f 2)
	MESSAGE=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","text"\]' | cut -f 2 | cut -d '"' -f 2)
	PHOTO_ID=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","photo",.*,"file_id"\]' | cut -f 2 | cut -d '"' -f 2 | sed -n '$p')

	USERNAME=$(echo $res | ./JSON.sh -s | egrep '\["result",0,"message","from","username"\]' | cut -f 2 | cut -d '"' -f 2)

	OFFSET=$((OFFSET+1))

	if [ $OFFSET != 1 ]; then
		process_client "$MESSAGE" "$TARGET" "$PHOTO_ID" "$USERNAME"&
	fi

}; done

