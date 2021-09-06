# coding: utf-8

# unicorn service start : % bundle exec unicorn -c unicorn.rb -D
# unicorn service stop  : % kill `cat pids/unicorn.pid`

require './RootApplication.rb'
run KousenFestivalRootApplication
