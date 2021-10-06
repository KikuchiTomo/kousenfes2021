default: hup
ssql:
	sudo mysql
start:
	bundle exec unicorn -c unicorn.rb -D

stop:
	kill -QUIT `cat ../pids/unicorn.pid`

hup:
	kill -HUP `cat ../pids/unicorn.pid`

cleanlog:
	rm -i ../log/unicorn.std???.log

cleanbak:
	rm -rf *~

update:
	git pull origin main:main
