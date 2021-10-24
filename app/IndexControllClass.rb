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
        #sql = 'select * from kouhou.proj where ena_flg=1 and del_flg=0 order by upd_time desc;'
        #proj_db = execSql(sql)
        @news_ary = []
        @proj_ary = []
        
        news_cnt = 0
        
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
            row['notify_time'] = notify_datetime
            @news_ary.push(row)
            news_cnt+=1
        }   
       
        sql = 'select id,cate, located, title, sub_description, organizer, icon_path, upd_time from proj where ena_flg=1 and del_flg=0 order by upd_time desc;'
        proj_db = execSql(sql)

        # 企画種類を取得
        sql = 'select id,cate from cates where ena_flg=1 and del_flg=0;'
        cate_db = execSql(sql)
        cates = {}
        cate_db.each{|cate|
            cates[cate['id']] = cate['cate']
        }

        # 企画場所の種類を取得
        sql = 'select id,locate_type from locate where del_flg=0 and ena_flg=1;'
        loca_db = execSql(sql)
        locates = {}
        loca_db.each{ |locate|
            locates[locate['id']] = locate['locate_type']
        }

        # 企画の情報を配列にキューイング
        proj_cnt = 0
        proj_db.each{ |row|
            break if proj_cnt>10
            h = {}
            h['id']     = row['id']
            h['title']  = row['title']
            h['cate']   = cates[row['cate']]
            h['locate'] = locates[row['located']]
            h['desc']   = row['sub_description']
            h['org']    = row['organizer']
            h['img']    = row['icon_path']
            h['time']   = row['upd_time']
            @proj_ary.push(h)
            proj_cnt+=1
        }

       # p @proj_ary
        erb :index
    end
end