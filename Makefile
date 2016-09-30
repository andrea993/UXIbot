build:	
	gcc -o random random.c || exit 1
	gcc -o mangrep mangrep.c || exit 1
	echo "Insert you token" ; \
	read -e token ; \
	echo $$token > token	

install:
	mkdir -p /opt/uxibot || exit 1
	cp -rf ./JSON.sh /opt/uxibot || exit 1
	cp -n ./admins.txt /opt/uxibot || exit 1
	cp -f ./bashbot.sh /opt/uxibot || exit 1
	cp -f ./commands.sh /opt/uxibot || exit 1
	cp -f ./question /opt/uxibot || exit 1
	cp -f ./mangrep /opt/uxibot || exit 1
	cp -f ./random /opt/uxibot || exit 1
	cp -f ./token /opt/uxibot || exit 1
	chmod +x /opt/uxibot/random || exit 1
	chmod +x /opt/uxibot/mangrep  || exit 1
	chmod 777 /opt/uxibot/admins.txt
	ln -sf /opt/uxibot/bashbot.sh /usr/bin/uxibot	
	
uninstall:
	rm -rf /opt/uxibot || exit 1
	rm -f /usr/bin/uxibot || exit 1

