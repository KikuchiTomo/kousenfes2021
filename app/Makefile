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

cleanhup: stop clearlog start
        -echo '=== cleanhup done==='

cleanbak:
        rm -rf *~
