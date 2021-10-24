require "./SearchProjControllClass.rb"

class NewsControllClass < SearchProjControllClass
    get '/news/detail' do
        id = params['id']||=0
        if id==0||id==''||id==nil
            raise CommonErrorView, "不正なパラメータ-IDを指定してください"
            return false
        end

        if !(id.to_s=~/^[0-9]+$/)
            raise CommonErrorView, "不正なパラメータ-IDに整数を指定してください"
            return false
        end

        sql = 'select * from kouhou.news where ena_flg=1 and del_flg=0 and id=?;'
        res = execSql(sql ,id)

        if res.count!=1
            return 404
       end

        row = res.first
        @news = {}
        @news['title']  = row['detail_title']
        @news['desc']   = row['detail_desc']
        @news['date']   = row['notify_datetime']
        @news['path']   = row['image_path']
        erb :news_detail
    end

    get '/news' do
        sql = 'select * from kouhou.news where ena_flg=1 and del_flg=0 order by notify_datetime desc;'
        news_db = execSql(sql)
        @news_ary = []
        
        
        news_db.each { |news| 
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
        }   

        erb :news_list
    end
end