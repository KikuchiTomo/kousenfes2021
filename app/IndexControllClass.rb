# coding: utf-8
require "rubygems"
require "sinatra/base"
require 'mysql2'
require "cgi/escape"
require "./CommonClass.rb"
require "./DBControllClass.rb"
require "./UserControllClass.rb"

class IndexControllClass < UserControllClass
   
    get '/' do
        
        sql = 'select * from kouhou.news where ena_flg=1 and del_flg=0 order by notify_datetime desc;'
        news_db = execSql(sql)
        sql = 'select * from kouhou.proj where ena_flg=1 and del_flg=0 order by upd_time desc;'
        proj_db = execSql(sql)
        @news_ary = []
        @proj_ary = []
        
        news_cnt = 0
        p news_db.first
        
        news_db.each { |news| 
            break if news_cnt > 10
            notify_datetime = Time.parse(news['notify_datetime'].to_s)
            next if (Time.now - notify_datetime) < 0
            row = {}
            row['id'] = news['id']
            row['img'] = news['image_path']
            row['img'] = '' if news['image_path']=="NOIMAGE"
            row['title'] = news['title']
            row['summary'] = news['description']
            row['date']    = notify_datetime.strftime("%m/%d %H:%M %a")
            @news_ary.push(row)
            news_cnt+=1
        }   
       
        puts "news count : #{news_cnt}"
        # p @news_ary
        erb :index
    end
end