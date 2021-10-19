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
    
        puts "You logined : OK #{uuid_admin}"
        return true
    end
    
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

        puts "#{ses[:token_admin]}"
        #isLogined = checkAdminToken('/kousen/admin/0AEECC00-4D5E-5043-E97C-2CBF5A8B2356/STN/login')
        #return "ERROR : session is broken" if !isLogined

        redirect to('/kousenadmin/dashboard')
    end

    get '/kousenadmin/logout' do
        uuid_admin = session[:uuid_admin]
        session[:uuid_admin] = nil
        session[:email_admin] = nil
        session[:token_admin] = nil
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
        puts "HELLO THIS IS DASHBOARD! "
        isLogined = checkAdminToken('/kousenadmin/logout')
        return "ERROR : session is broken" if !isLogined
        puts "TOKEN ADMIN => #{isLogined}"
        erb :admin_dashboard
    end

    after do
        cache_control :no_cache
    end
end