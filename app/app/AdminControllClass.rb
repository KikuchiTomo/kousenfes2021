require "./QRControllClass.rb"

class AdminControllClass < QRControllClass
    def generateAdminToken(uuid)
        puts "#{Time.now} - Generate token - Admin"
    
        token_admin  = SecureRandom.uuid # token
        expire_admin = Time.now + 60*60*24*2 # 2日後にログアウト        
        sql = 'update kouhou.admins set token=?,token_expire=? where ena_flg=1 and del_flg=0 and uuid=?;'
        # tokenを保存する
        execSql(sql, token_admin, expire_admin, uuid)
        res = {token_admin: token_admin, expire_admin: expire_admin}
        return res
    end

    def discardAdminToken(uuid)
        puts "#{Time.now} - Discard token - Admin : #{uuid}"
    
        token_admin  = 'setmetoken'
        expire_admin = Time.local(1960, 1, 1, 12, 0, 0, 0)
        
        sql = 'update kouhou.admins set token=?,token_expire=? where ena_flg=1 and del_flg=0 and uuid=?;'
        execSql(sql, token_admin, expire_admin, uuid)
    end

    def checkAdminToken(url)
        uuid_admin = session[:uuid_admin]
        token_admin = session[:token_admin]
    
        if uuid_admin==nil||uuid_admin==''
          redirect to(url)
          return false
        elsif token_admin==nil||token_admin==''
          redirect to(url)
          return false
        end
    
        sql = 'select token,token_expire from kouhou.admins where ena_flg=1 and del_flg=0 and uuid=?;'
        res = execSql(sql, uuid_admin)
    
        if res.count==0
          redirect to(url)
          return false
        elsif res.count>1
          redirect to(url)
          return false
        end
    
        expire_from_db_str = res.first['token_expire'].to_s
        token_from_db  = res.first['token']
        expire_from_db = Time.parse(expire_from_db_str)
    
        if token_from_db=='setmetoken'
          redirect to(url)
          return false
        end
    
        if token_from_db!=token_admin
          redirect to(url)
          return false
        end
    
        if (expire_from_db-Time.now)<0
          redirect to(url)
          return false
        end
    
        puts "You logined : OK #{uuid_admin} : #{Time.now}"
        return true
    end

    #==========================IMAGE=================================
    post '/kousenadmin/common/update/add/img' do
      # Check Admin User
      checkAdminToken('/kousenadmin/logout')        
      proj_p = session[:permit_proj].to_i
      news_p = session[:permit_news].to_i
      return "ERROR000" if proj_p!=1||news_p!=1

      puts Time.now.to_s + "POST IMAGES"
      if params[:file]==nil;   return "ERROR001";  end
  
      uuid0  = SecureRandom.uuid 
      uuid1  = SecureRandom.uuid 
      ext    = File.extname(params[:file][:filename]) 
      fpath0 = "/tmp/"           + uuid0+  ext    
      fpath1 = "/tmp/"           + uuid1 + ".jpg" 
      fpath2 = "../html/kouhou_images/" + uuid1 + ".jpg" 
      upath  = "/kouhou_images/"        + uuid1 + ".jpg" 
      
      begin 
        File.open(fpath0, 'wb'){ |f|  f.write( params[:file][:tempfile].read ) }
      rescue => error
        puts "POST: /kouhou_add_data_admin_img on error "; puts error; puts ""
        return "ERROR002"
      end
  
      `convert -auto-orient #{fpath0} -strip -resize '1024x>' #{fpath1}`
      md5 = `md5sum #{fpath1}`.split(" ")[0];
      
      a = `ls -t ../html/kouhou_images/*.jpg`.split
      a.each{|f|
        tmp = `md5sum #{f}`.split(" ")[0];
        if md5==tmp   
          puts "MATCH!!!!"
          `rm #{fpath1}`
          upath = "/kouhou_images/"+File.basename(f)
          return upath                       
          end
      }
      
      `mv #{fpath1} #{fpath2}`
      return upath   
    end

    #==========================LOGIN=================================
    get '/kousen/admin/0AEECC00-4D5E-5043-E97C-2CBF5A8B2356/STN/login' do
        erb :admin_login
    end

    post '/kousenadmin/STNOOB/login' do
        pass  = params['wijhafw'] ||=''
        email = params['email']   ||=''
        return "ERROR : wrong params" if ( pass==''  || pass==nil  )
        return "ERROR : wrong params" if ( email=='' || email==nil )
        p email
        sql = 'select * from kouhou.admins where ena_flg=1 and del_flg=0 and email=?;'
        res = execSql(sql, email)

        return "ERROR : no user"      if (res.count<1)
        return "ERROR : db is broken" if (res.count!=1)
        
        row = res.first
        uuid = row['uuid']
        hashdb = row['passhash']
        hashpm = HashSHA.get512(pass + uuid + 'STNOOB2042');
        puts "#{hashdb} <=> #{hashpm} : #{uuid}"
        return "ERROR : wrong params" if hashdb!=hashpm

        ses = generateAdminToken(uuid)
        session[:uuid_admin]  = uuid
        session[:email_admin] = email
        session[:token_admin] = ses[:token_admin] 
        session[:expire_admin]= ses[:expire_admin]

        # nilなら'0'にして権限剥奪
        session[:permit_user]  = row['permit_user'] ||=0
        session[:permit_bingo] = row['permit_bingo']||=0
        session[:permit_proj]  = row['permit_proj'] ||=0
        session[:permit_news]  = row['permit_news'] ||=0
        session[:permit_qr]    = row['permit_qr']   ||=0
        session[:permit_admin] = row['permit_admin']||=0

        session[:first_name]   = row['first_name']  ||='STRING_ERROR'
        session[:last_name]    = row['last_name']   ||='STRING_ERROR'
        puts "#{ses[:token_admin]}"
        
        redirect to('/kousenadmin/dashboard')
    end

    get '/kousenadmin/logout' do
        uuid_admin = session[:uuid_admin]
        session[:uuid_admin]   = nil
        session[:email_admin]  = nil
        session[:token_admin]  = nil
        session[:expire_admin] = nil

        if uuid_admin!=nil&&uuid_admin!=''
            puts "DISCARDING.... : #{uuid_admin}"
            discardAdminToken(uuid_admin) 
        else
            puts "UUID IS NIL!!!"
        end

        redirect '/kousen/admin/0AEECC00-4D5E-5043-E97C-2CBF5A8B2356/STN/login'
    end 

    get '/kousenadmin/dashboard' do
        uuid_admin = session[:uuid_admin]
        puts "HELLO THIS IS DASHBOARD! "
        isLogined = checkAdminToken('/kousenadmin/logout')
        return "ERROR : session is broken" if !isLogined
        puts "TOKEN ADMIN => #{isLogined}"
        
        @name = session[:first_name]
        @permit = {
          :user  => session[:permit_user],
          :bingo => session[:permit_bingo],
          :news  => session[:permit_news],
          :qr    => session[:permit_qr],
          :proj  => session[:permit_proj],
          :admin => session[:permit_admin]
        }
        
        sql = 'select id from kouhou.users where del_flg=0 and status=2;'
        @acc_cnt = execSql(sql).count ||=0
        erb :admin_dashboard
    end

    after do
        cache_control :no_cache
    end

    #========================START : NEWS=====================================
    get '/kousenadmin/news/dashboard' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0

      sql = 'select * from kouhou.news where del_flg=0 order by notify_datetime desc;'
      res = execSql(sql)
      @news_list = []
      if res.count<1
        @news_list = nil
      else
        res.each{ |news|
          hash = {}
          hash['id'] = news['id']
          hash['title'] = news['title']
          hash['dtitle'] = news['detail_title']
          hash['date'] = news['notify_datetime']
          hash['desc'] = news['description']
          hash['ddesc'] = news['detail_desc']
          hash['ena'] = news['ena_flg']
          @news_list.push(hash)
        }
      end

      erb :admin_news_list
    end

    post '/kousenadmin/news/update/showing_list' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0

      ena_ids = params['enable'] ||=''
      
      #
      return "PARAMS DONT HAVE ANT DATA" if ena_ids==''

      sql = 'select id from kouhou.news where del_flg=0;'
      res = execSql(sql)
      
      return "DB DONT HAS ANY DATA" if(res.count<1)
      # return "PARAMS WAS BROKEN"    if(res.count!=ena_ids.count)

      sql = 'update kouhou.news set ena_flg=? where del_flg=0 and id=?;'    
      
      res.each{ |row|
        
        if ena_ids.include?(row['id'].to_s)
          execSql(sql, 1, row['id'])
        else
          execSql(sql, 0, row['id'])
        end
      }

      redirect to('/kousenadmin/news/dashboard')
    end

    get '/kousenadmin/news/update/edit' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0

      id = params['id'] ||=''
      return "NEED ARGS : NEWS ID" if id==''

      sql = 'select * from kouhou.news where del_flg=0 and id=?;'
      res = execSql(sql, id)
      return "DB IS BROKEN" if res.count!=1

      row = res.first
      @is_create = false
      @news = {}
      @news['id'] = row['id']
      @news['title'] = row['title']
      @news['dtitle'] = row['detail_title']
      @news['desc'] = row['description']
      @news['ddesc'] = row['detail_desc']
      @news['date'] = Time.parse(row['notify_datetime'].to_s)
      @news['path'] = row['image_path']
      p @news
      erb :admin_news_edit
    end

    get '/kousenadmin/news/update/add' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0
      @is_create = true
      erb :admin_news_add
    end

    post '/kousenadmin/news/update/edit' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0

      id    = params['id'] ||=''
      title = params['title'] ||=''
      dtitle= params['detail_title']||=''
      desc  = params['description'] ||=''
      ddesc = params['detail_desc'] ||=''
      date  = params['notify_datetime'] ||=''
      path  = params['image_path'] ||= 'NOIMAGE'

      return "NEED ARGS : ANY" if(title==''||dtitle==''||desc==''||ddesc==''||date==''||id=='')
      return "TOO LONG DATA : ANY" if(title.size>60)

      notify_time = Time.parse(date)
      
      sql = 'update kouhou.news set title=?,detail_title=?,description=?,detail_desc=?,notify_datetime=?,image_path=? where id=?;'
      execSql(sql, title, dtitle, desc, "\r\n" + ddesc, date, path,  id);
      redirect to('/kousenadmin/news/dashboard')
    end

    get '/kousenadmin/news/update/delete' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0

      id = params['id'] ||=''
      return "NEED ARG" if id==''

      sql = 'update kouhou.news set del_flg=1 where id=?;'
      execSql(sql, id)
      redirect to('/kousenadmin/news/dashboard')
    end

    post '/kousenadmin/news/update/add' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_news]
      return "Permission denied : YOU CANT CONTROL NEWS" if permit==0

      img   = params['image_path'] ||='NOIMAGE'
      title = params['title'] ||=''
      dtitle= params['detail_title']||=''
      desc  = params['description'] ||=''
      ddesc = params['detail_desc'] ||=''
      date  = params['notify_datetime'] ||=''

      return "NEED ARGS : ANY" if(title==''||dtitle==''||desc==''||ddesc==''||date=='')
      return "TOO LONG DATA : ANY" if(title.size>60)

      notify_time = Time.parse(date)
      
      sql = 'insert into kouhou.news (title,detail_title,description,detail_desc,notify_datetime,image_path) values (?,?,?,?,?,?);'
      execSql(sql, title, dtitle, desc, "\r\n" + ddesc, date, img);
      redirect to('/kousenadmin/news/dashboard')
    end
    #=============================END : NEWS=====================================

    #===========================START : PROJ=====================================
    get '/kousenadmin/proj/dashboard' do 
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1

      sql = 'select * from kouhou.proj where del_flg=0;'
      res = execSql(sql)
      sql = 'select * from kouhou.cates where del_flg=0 and ena_flg=1;'
      catedb = execSql(sql)
      sql = 'select * from kouhou.locate where del_flg=0 and ena_flg=1;'
      locatedb = execSql(sql)
      res=[] if res==nil
      catedb=[] if catedb==nil
      locatedb=[] if locatedb==nil

      cates = {}
      catedb.each{ |cate|
        cates[cate['id']] = cate['cate']
      }

      locates = {}
      locatedb.each{ |locate|
        locates[locate['id']] = locate['locate_name']
      }

      @proj_list = []
      res.each { |row|
        h = {}
        h['cate'] = cates[row['cate']]
        h['id'] = row['id']
        h['organizer'] = row['organizer']
        h['title'] = row['title']
        h['located'] = locates[row['located']]
        h['ena'] = row['ena_flg']
        @proj_list.push(h)
      }

      erb :admin_proj_list
    end

    post '/kousenadmin/proj/update/showing_list' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1

      ena_ids = params['enable'] ||=''
      
      #return "PARAMS DONT HAVE ANT DATA" if ena_ids==''

      sql = 'select id from kouhou.proj where del_flg=0;'
      res = execSql(sql)
      
      return "DB DONT HAS ANY DATA" if(res.count<1)
      # return "PARAMS WAS BROKEN"    if(res.count!=ena_ids.count)

      sql = 'update kouhou.proj set ena_flg=? where del_flg=0 and id=?;'    
      
      res.each{ |row|
        
        if ena_ids.include?(row['id'].to_s)
          execSql(sql, 1, row['id'])
        else
          execSql(sql, 0, row['id'])
        end
      }

      redirect to('/kousenadmin/proj/dashboard')  
    end 

    get '/kousenadmin/proj/update/edit' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1

      id = params['id'] ||=''
      return "NEED ARGS : PROJ ID" if id==''

      sql = 'select * from kouhou.proj where del_flg=0 and id=?;'
      res = execSql(sql, id)
      return "DB IS BROKEN" if res.count!=1

      row = res.first
      @proj = {}
      @proj['id'] = row['id']
      @proj['title'] = row['title']
      @proj['icon'] = row['icon_path']
      @proj['image'] = row['image_path']
      @proj['cate'] = row['cate']
      @proj['desc'] = row['description']
      @proj['sub_desc'] = row['sub_description']
      @proj['tags'] = row['tags']
      @proj['words'] = row['words']
      @proj['organizer'] = row['organizer']
      @proj['located'] = row['located']

      sql = 'select * from kouhou.cates where del_flg=0 and ena_flg=1;'
      catedb = execSql(sql)
      catedb=[] if catedb==nil
      @cates = {}
      catedb.each{ |cate|
        @cates[cate['id']] = cate['cate']
      }

      sql = 'select * from kouhou.locate where del_flg=0 and ena_flg=1;'
      locatedb = execSql(sql)
      locatedb = [] if locatedb==nil
      @locates = {}
      locatedb.each{ |locate|
        @locates[locate['id']] = locate['locate_name']
      }

      erb :admin_proj_edit
    end

    post '/kousenadmin/proj/update/edit' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1

      id = params['id'] ||=''
      title = params['title'] ||=''
      organizer = params['organizer'] ||=''
      cate = params['cate'] ||=''
      located = params['located'] ||=''
      desc = params['description'] ||=''
      sub_desc = params['sub_description'] ||=''
      tags = params['tags'] ||=''
      words = params['words'] ||=''
      image_path = params['image_path'] ||='NOIMAGE'
      icon_path = params['icon_path'] ||='NOIMAGE'

      if tags!=''
        tags = tags.split('\n')
      else
        tags = ["NOTAGS"]
      end

      if words!=''
        words = words.split('\n')
      else
        words = ["NOWORDS"]
      end

      tags  = tags.join(',')
      words = words.join(',')

      return "ERROR: NEED TO ARGS" if id==''||title==''||organizer==''||cate==''||sub_desc==''||located==''

      sql = 'update kouhou.proj set title=?, organizer=?, located=?, cate=?, description=?, sub_description=?, tags=?, words=?, image_path=?, icon_path=? where del_flg=0 and id=?;'
      # sql  = 'insert into proj (title, organizer, located, cate, description, sub_description, tags, words, image_path, icon_path)'
      # sql += 'values (?,?,?,?,?,?,?,?,?,?) where id=?'
      execSql(sql, title, organizer, located, cate, "\r\n" + desc, sub_desc, tags, words, image_path, icon_path, id);
      redirect to('/kousenadmin/proj/dashboard')
    end

    get '/kousenadmin/proj/update/add' do 
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1
      sql = 'select * from kouhou.cates where del_flg=0 and ena_flg=1;'
      catedb = execSql(sql)
      catedb=[] if catedb==nil
      @cates = {}
      catedb.each{ |cate|
        @cates[cate['id']] = cate['cate']
      }

      sql = 'select * from kouhou.locate where del_flg=0 and ena_flg=1;'
      locatedb = execSql(sql)
      locatedb = [] if locatedb==nil
      @locates = {}
      locatedb.each{ |locate|
        @locates[locate['id']] = locate['locate_name']
      }

      @token = SecureRandom.uuid
      erb :admin_proj_add
    end

    post '/kousenadmin/proj/update/add' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1

      title = params['title'] ||=''
      organizer = params['organizer'] ||=''
      cate = params['cate'] ||=''
      located = params['located'] ||=''
      desc = params['description'] ||=''
      sub_desc = params['sub_description'] ||=''
      tags = params['tags'] ||=''
      words = params['words'] ||=''
      image_path = params['image_path'] ||='NOIMAGE'
      icon_path = params['icon_path'] ||='NOIMAGE'

      if tags!=''
        tags = tags.split('\n')
      else
        tags = ["NOTAGS"]
      end

      
      if words!=''
        words = words.split('\n')
      else
        words = ["NOWORDS"]
      end

      tags  = tags.join(',')
      words = words.join(',')

      return "ERROR: NEED TO ARGS" if title==''||organizer==''||cate==''||sub_desc==''||located==''

      sql  = 'insert into proj (title, organizer, located, cate, description, sub_description, tags, words, image_path, icon_path)'
      sql += 'values (?,?,?,?,?,?,?,?,?,?);'
      execSql(sql, title, organizer, located, cate, "\r\n" + desc, sub_desc, tags, words, image_path, icon_path);
      redirect to('/kousenadmin/proj/dashboard')
    end

    get '/kousenadmin/proj/update/delete' do
      checkAdminToken('/kousenadmin/logout')
      permit = session[:permit_proj]
      return "Permission denied : YOU CANT CONTROL PROJS" if permit!=1

      id = params['id'] ||=''
      return "NEED ARG" if id==''

      sql = 'update kouhou.proj set del_flg=1 where id=?;'
      execSql(sql, id)
      redirect to('/kousenadmin/proj/dashboard')
    end

    #=============================END : PROJ=====================================
end