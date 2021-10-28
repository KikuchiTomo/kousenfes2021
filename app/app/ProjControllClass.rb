require "./IndexControllClass.rb"
require 'rubygems'

#$LOAD_PATH<<"/home/kouhou/.rbenv/versions/3.0.2/lib/ruby/gems/3.0.0/gems/commonmarker-0.23.2"
#require 'commonmarker'
#require "sinatra/base"

# require "../../home/kouhou/.rbenv/versions/3.0.2/lib/ruby/gems/3.0.0/gems/commonmarker-0.23.2"
# require 'redcarpet'

class ProjControllClass < IndexControllClass
   #  
    get '/proj/detail' do
        
        id = params['id']||=0
        if id==0||id==''||id==nil
            raise CommonErrorView, "不正なパラメータ-IDを指定してください"
            return false
        end

        if !(id.to_s=~/^[0-9]+$/)
            raise CommonErrorView, "不正なパラメータ-IDに整数を指定してください"
            return false
        end

        sql = 'select * from kouhou.proj where ena_flg=1 and del_flg=0 and id=?;'
        res = execSql(sql ,id)

        if res.count!=1
            return 404
        end

        sql = 'select cate,id from kouhou.cates where ena_flg=1 and del_flg=0;'
        cdb = execSql(sql)
        sql = 'select id,locate_name,floor,locate_id,locate_type from kouhou.locate where ena_flg=1 and del_flg=0;'
        ldb = execSql(sql)

        if cdb==nil||cdb.count==0||ldb==nil||ldb.count==0
            return 504
        end

        cates = {}
        cdb.each{ |c|
            cates[c['id']] = c['cate']
        }

        locate_name = {}
        locate_type = {}
        locate_floor = {}

        ldb.each{ |l|
            locate_name[l['id']]  = l['locate_name']
            locate_type[l['id']]  = l['locate_type']
            locate_floor[l['id']] = l['floor']
        }

        p locate_name
        row = res.first
        @proj = {}
        @proj['title']  = row['title']
        @proj['lname']  = locate_name[row['located']]
        @proj['ltype']  = locate_type[row['located']]
        @proj['lfloor'] = locate_floor[row['located']]
        @proj['cate']   = cates[row['cate']]
        @proj['cate_id']= row['cate']
        @proj['tags']   = row['tags']
        @proj['desc']   = row['description']
        @proj['org']    = row['organizer']
        @proj['path']   = row['image_path']
        #@proj['desc_html'] = CommonMarker.render_html(row['description'])
         p @proj['desc']
        erb :proj_detail
    end
end