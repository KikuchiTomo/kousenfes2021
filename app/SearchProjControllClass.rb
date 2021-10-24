require "./ProjControllClass.rb"
require "cgi/escape"

class SearchProjControllClass < ProjControllClass
    get '/search' do
        sql = 'select * from kouhou.cates where del_flg=0 and ena_flg=1;'
        catedb = execSql(sql)
        catedb=[] if catedb==nil
        
        @cates = {}
        catedb.each{ |cate|
            @cates[cate['id']] = cate['cate']
        }

        # 企画場所の種類を取得
        sql = 'select id,locate_type,floor from locate where del_flg=0 and ena_flg=1;'
        loca_db = execSql(sql)
        locate_floor = {}
        locate_type = {}
        loca_db.each{ |locate|
            locate_floor[locate['id']] = locate['floor']
            locate_type[locate['id']] = locate['locate_type']
        }        

        words = params['words'] ||=''
        cate  = params['cate']  ||=-1
        floor = params['floor'] ||=-1

        @user_input_cate = 0;   
        @hit = 0
        @user_input_words = ""
        @show = []
        if(words==''&&cate==-1&&floor==-1)       
            sql = 'select * from kouhou.proj where ena_flg=1 and del_flg=0 order by upd_time desc;'            
            res = execSql(sql)
            if res!=nil
                @hit = res.count
                res.each{ |row|
                    h = {}
                    h['id']     = row['id']
                    h['title']  = row['title']
                    h['cate']   = @cates[row['cate']]
                    #h['locate'] = locates[row['located']]
                    h['desc']   = row['sub_description']
                    h['org']    = row['organizer']
                    h['img']    = row['icon_path']
                    h['time']   = row['upd_time']
                    @show.push(h)
                }
            end
        else
            if !(cate.to_s=~/^[0-9]+$/)&&cate.to_i!=-1 || !(floor.to_s=~/^[0-9]+$/)&&floor.to_i!=-1
                raise CommonErrorView, "不正なパラメータ-整数を指定してください"
                return false
            end
            cate = cate.to_i
            floor= floor.to_i

            if(cate!=-1&&floor!=-1)
                sql='select proj.words, proj.id,proj.title,proj.cate,proj.sub_description,proj.organizer,proj.icon_path,proj.upd_time from proj inner join locate on proj.located = locate.id where floor=? and cate=? and proj.ena_flg=1 and proj.del_flg=0;'
                res = execSql(sql, floor, cate)
                if res!=nil
                    @hit = res.count
                    res.each{ |row|
                        h = {}
                        h['id']     = row['id']
                        h['title']  = row['title']
                        h['cate']   = @cates[row['cate']]
                        #h['locate'] = locates[row['located']]
                        h['desc']   = row['sub_description']
                        h['org']    = row['organizer']
                        h['img']    = row['icon_path']
                        h['time']   = row['upd_time']
                        h['words']   = row['words'].gsub("\r\n", "\n").split("\n")
                        @show.push(h)
                    }
                end
            elsif(cate!=-1)
                sql='select * from kouhou.proj where ena_flg=1 and del_flg=0 and cate=?;'
                res = execSql(sql, cate)
                if res!=nil
                    @hit = res.count
                    res.each{ |row|
                        h = {}
                        h['id']     = row['id']
                        h['title']  = row['title']
                        h['cate']   = @cates[row['cate']]
                        #h['locate'] = locates[row['located']]
                        h['desc']   = row['sub_description']
                        h['org']    = row['organizer']
                        h['img']    = row['icon_path']
                        h['time']   = row['upd_time']
                        h['words']   = row['words'].gsub("\r\n", "\n").split("\n")
                        @show.push(h)
                    }
                end
            elsif(floor!=-1)
                sql='select proj.words,proj.id,proj.title,proj.cate,proj.sub_description,proj.organizer,proj.icon_path,proj.upd_time from proj inner join locate on proj.located = locate.id where floor=? and proj.ena_flg=1 and proj.del_flg=0;'
                res = execSql(sql, floor)
                if res!=nil
                    @hit = res.count
                    res.each{ |row|
                        h = {}
                        h['id']     = row['id']
                        h['title']  = row['title']
                        h['cate']   = @cates[row['cate']]
                        #h['locate'] = locates[row['located']]
                        h['desc']   = row['sub_description']
                        h['org']    = row['organizer']
                        h['img']    = row['icon_path']
                        h['time']   = row['upd_time']
                        h['words']   = row['words'].gsub("\r\n", "\n").split("\n")
                        @show.push(h)
                    }
                end
            else
                sql='select * from kouhou.proj where ena_flg=1 and del_flg=0;'
                res = execSql(sql)
                if res!=nil
                    @hit = res.count
                    res.each{ |row|
                        h = {}
                        h['id']     = row['id']
                        h['title']  = row['title']
                        h['cate']   = @cates[row['cate']]
                        #h['locate'] = locates[row['located']]
                        h['desc']   = row['sub_description']
                        h['org']    = row['organizer']
                        h['img']    = row['icon_path']
                        h['time']   = row['upd_time']
                        h['words']   = row['words'].gsub("\r\n", "\n").split("\n")
                        @show.push(h)
                    }
                end
            end
            
            @user_input_cate = cate.to_i
            @user_input_words = words
            if(!(words=='' || words=='　' || words==' '))
                word_ary = words.gsub("　", " ").split(" ")
                p word_ary
                @select = []
                @show.each{ |one|
                    tmp = one['words'] & word_ary
                    if(tmp.count>0)
                        @select.push(one)
                        next
                    end

                    word_ary.each{ |word|
                        search = one['title'] + one['desc'] + one['org']
                        if search.include?(word)
                            @select.push(one)
                            break
                        end
                    }
                }
                @show = @select
                p @show
            end
        end

        @user_input_words = CGI.escapeHTML(@user_input_words)
        @hit = @show.count
        p @show
        erb :search
    end
end