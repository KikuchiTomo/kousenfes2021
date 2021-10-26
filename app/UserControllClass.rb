# coding: utf-8
require "rubygems"
require "sinatra/base"
require 'mysql2'
require "cgi/escape"

require "./functions/hash_class.rb"
require "./functions/send_email.rb"
require "./CommonClass.rb"
require "./DBControllClass.rb"

#
# Userの管理を行うクラス
#
class UserControllClass < DBControllClass

  # ユーザの存在確認を行う
  # @param uuid [String]
  # @return ヒット数 [Int]
  def checkUserExist(uuid)
    # ユーザ数をカウント
    sql = 'select uuid from kouhou.users where del_flg=? and uuid=?;'
    cnt = execSql(sql, 0, uuid)
    return -1 if cnt == nil
    return cnt.size
  end

  # ユーザパスコードの存在確認を行う
  # @param uuid [String]
  # @return ヒット数 [Int]
  def checkUserPasscodeDataExist(uuid)
    # ユーザ数をカウント
    sql = 'select id from kouhou.tmp_users where del_flg=? and uuid=?;'
    cnt = execSql(sql, 0, uuid)
    return -1 if cnt == nil
    return cnt.size
  end
  
  # Emailの一異性確認
  # @param email [String]
  # @return ヒット数 [Int]
  def checkUserEmail(email)
    # ユーザ数をカウント
    sql = 'select uuid from kouhou.users where del_flg=? and email=?;'
    cnt = execSql(sql, 0, email)
    return -1 if cnt==nil
    return cnt.size
  end
  
  # パスコードの生成を行う
  # @return passcode [String] パスコード
  def generateTmpPasscode()
    passcode = SecureRandom.alphanumeric(8)
    return passcode
  end

  # パスコードの登録を行う
  # @param passcode [String]　パスコード
  def registerTmpPasscode(uuid, passcode, access_key, isupdate)
    # 存在チェック
    user_cnt = checkUserExist(uuid)
    return false if !(user_cnt==1||user_cnt==0)

    # ソルトはXQQ2021
    passcode_hash   = HashSHA.get512(passcode + uuid + 'XQQ2021');
    # 有効期限を10分
    passcode_expire = Time.now + 10 * 60
    if isupdate then
      # 存在する場合は，更新する
      # ユーザ情報を更新
      puts "upd user -> #{uuid}"
      sql = 'update kouhou.tmp_users set passcode_hash=?, access_key=?, expire=? where del_flg=0 and uuid=?;'
      execSql(sql, passcode_hash, access_key, passcode_expire, uuid)
      return true
    else
      # 存在する場合は，登録する
      puts "reg user -> #{uuid}"
      sql = 'insert into kouhou.tmp_users (uuid, passcode_hash, access_key, expire) values (?,?,?,?);'
      execSql(sql, uuid, passcode_hash, access_key, passcode_expire)
      return true
    end
  end

  def generateUserToken(uuid)
    puts "#{Time.now} - Generate token - User"

    token = SecureRandom.uuid # tokenログアウト
    expire = Time.now + 60*60*24*30 # 30日後にログアウト        
    sql = 'update kouhou.users set token=?,token_expire=? where status=2 and del_flg=0 and uuid=?;'
    # tokenを保存する
    execSql(sql, token, expire, uuid)
    res = {token: token, expire: expire}
    return res
  end

  def discardUserToken(uuid)
    puts "#{Time.now} - Discard token - User"

    token  = 'setmetoken'
    expire = Time.local(1960, 1, 1, 12, 0, 0, 0)
    sql = 'update kouhou.users set token=?,token_expire=? where status=2 and del_flg=0 and uuid=?;'
    execSql(sql, token, expire, uuid)
  end

  def checkUserToken(url)
    uuid = session[:uuid]
    token = session[:token]

    if uuid==nil||uuid==''
      redirect to(url)
      return false
    elsif token==nil||token==''
      redirect to(url)
      return false
    end

    sql = 'select token,token_expire from kouhou.users where status=2 and del_flg=0 and uuid=?;'
    res = execSql(sql, uuid)

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

    if token_from_db!=token
      redirect to(url)
      return false
    end

    if (expire_from_db-Time.now)<0
      redirect to(url)
      return false
    end

    puts "You logined : OK #{uuid}"
    return true
  end

  get '/kousenuser/sinup' do
    erb :user_sinup
  end

  post '/kousenuser/sinup' do
    fname = params['first_name'] ||=''
    lname = params['last_name']  ||=''
    fname_rb = params['first_name_h'] ||=''
    lname_rb = params['last_name_h']  ||=''
    cate = params['cate'] ||=''
    cate = cate.to_i if cate!=''
    sname = params['school-name'] ||=''
    grade = params['grade'] ||=-1
    course = params['course'] ||=''
    password = params['password'] ||=''
    email = params['email'] ||=''

    mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    # DEBUG 
    start0 = Time.now
    # 内容チェック    
    if fname==''||lname==''||fname_rb==''||lname_rb=='' # 名前の欄が空白
      raise CommonErrorView, '入力が不正です-氏名，またはふりがなのデータが不正です．お手数ですが入力し直してください'
      return false
    elsif password=='' # パスワードが空欄
      raise CommonErrorView, '入力が不正です-登録パスワードが入力されていません．'
      return false
    elsif password.size<8||password.size>32
      raise CommonErrorView, '入力が不正です-登録パスワードの形式が不正です．'
      return false
    elsif email=='' # メールアドレスが空欄
      raise CommonErrorView, '入力が不正です-登録メールアドレスが入力されていません．'
      return false
    elsif !email.match? mailRegex # メールアドレスが不正
      raise CommonErrorView, '入力が不正です-登録メールアドレスの形式が不正です．'
      return false
    elsif cate!='' # カテゴリ入力あり
      if cate>=1&&cate<=5 # 1~5の間のintである
        if cate==1 # 高専本科
          if course==''||grade==''
            raise CommonErrorView, '入力が不正です-コースまたは学年が登録されていません'
            return false
          end
        elsif cate==2 # 高専専攻科
          if course==''
            raise CommonErrorView, '入力が不正です-学年が登録されていません'
            return false
          end
        elsif cate==3 # 中学生
          if grade==''||sname==''
            raise CommonErrorView, '入力が不正です-学年または学校名が登録されていません'
            return false
          end
        else # 保護者・その他
        end
      else # 1~5の間以外
        raise CommonErrorView, '入力が不正です-学年入力形式が不正です．'
        return false
      end
    end

    #puts "#{(Time.now - start0)} ValChekced"
    # uuid生成
    uuid = SecureRandom.uuid
    uuid_cnt = checkUserPasscodeDataExist(uuid)
    #puts "#{(Time.now - start0)} PasscodeChekced"
    if uuid_cnt!=0
      raise CommonErrorView, '処理エラー-ユーザIDの生成に失敗しました．'
      return false
    end

    if checkUserEmail(email)!=0
      raise CommonErrorView, '処理エラー-このメールアドレスはすでに登録済みです.'
      return false
    end
    #puts "#{(Time.now - start0)} EmailChekced"
    # passcode生成
    passcode = generateTmpPasscode()
    access_key = HashSHA.get512(SecureRandom.uuid + "#{Time.now}")
    # DBへ登録
    result = registerTmpPasscode(uuid, passcode, access_key, false) if(uuid_cnt==0)
    #puts "#{(Time.now - start0)} Reged tmp"
    if !result
      raise CommonErrorView, '登録エラー-サーバで処理エラーが発生しました'
      return false
    end

    # 可読性が落ちるけどテーブル作る時間もないので
    # 登録処理
    sql = 'insert into kouhou.users (uuid, email, first_name, last_name, first_name_rb, last_name_rb, grade, passhash, token, token_expire, course, status) values (?,?,?,?,?,?,?,?,?,?,?,?);'
    expired_time = Time.local(1960, 1, 1, 12, 0, 0, 0);
    set_me_token = 'setmetoken'
    grade_int = (grade!='') ? grade.to_i : -1; 
    
    # ソルトはXQQ2021
    password_hash = HashSHA.get512(password + uuid + 'XQQ2021');
    execSql(sql, uuid, email, fname, lname, fname_rb, lname_rb, grade_int, password_hash, set_me_token, expired_time, course, 0);
    puts "#{(Time.now - start0)} Reged user"

    # メール送る
    sendAuthEmail(email, fname, passcode, access_key, uuid)
    puts "#{(Time.now - start0)} Sent email"
    # メッセージ画面へ遷移
    redirect to('/user_sinup_msg.html')
  end

  get '/kousenuser/sinup/entry' do
    puts "Entry...."
    uuid = params['uuid'] ||=nil
    access_key = params['accesskey'] ||=nil

    # パラメータチェック
    if uuid==nil || access_key==nil || uuid=='' || access_key==''
      raise CommonErrorView, 'パラメータが不正です-指定されたパラメータは不正です。'
      return false
    end
    puts "Params OK...."

    # 存在と有効期限チェック      
    sql = 'select status from kouhou.users where del_flg=0 and uuid=?;'
    res = execSql(sql, uuid)

    # ユーザの存在確認
    if(res.size!=1 || res==nil)
      raise CommonErrorView, 'データベースの整合性が不正です-指定されたUUIDは不正です。有効なユーザは存在しません。'
      return false
    end
    puts "Exist OK...."

    status = res.first['status'].to_i

    # 前回、sinupの処理が行われているかステータスを確認(-1: 不正, 0:sinup直後, 1: アクセスキー承認, 2:パスコード承認・承認済み)
    if(!(status==0||status==1))
      raise CommonErrorView, 'ユーザステータスが不正です-指定されたUUIDのユーザは登録可能ではありません。'
      return false;
    end
    puts "Status OK...."

    sql = 'select access_key, expire from kouhou.tmp_users where del_flg=0 and ena_flg=1 and uuid=?;'
    res = execSql(sql, uuid)

    p res
    # 一時パスコード保管テーブルの存在確認
    if(res.size!=1||res==nil)
      raise CommonErrorView, 'データベースの整合性が不正です-指定されたUUIDは不正です。有効な一時ユーザは存在しません。'
      return false 
    end
    puts "DB OK...."

    access_key_db = res.first['access_key']

    # 有効期限確認
    expire_time = Time.parse(res.first['expire'].to_s)
    now_time = Time.now

    if expire_time < now_time 
      # 期限切れ
      raise CommonErrorView, '有効期限切れです-指定URLは有効期限が切れています。'
      return false
    end

    puts "Expire OK...."
    # アクセスキーの確認
    if access_key_db != access_key
      raise CommonErrorView, '指定URLは不正です-指定URLのアクセスキーが不正です。'
      return false
    end

    # ここまでたどり着いたらちゃんとしたアクセス
    # 確認できたお
    sql = 'update kouhou.users set status=? where uuid=?;'
    execSql(sql, 1, uuid)

    @uuid = uuid
    erb :user_entry
  end

  post '/kousenuser/sinup/entry' do
    passcode = params['passcode'] ||=''
    uuid     = params['uuid'] ||=''

    # パラメータチェック
    if(passcode==''||uuid=='')
      raise CommonErrorView, 'パラメータが不正です-指定されたパラメータは不正です。'
      return false
    end

    # パスコードの長さは8
    if(passcode.length!=8)
      raise CommonErrorView, 'パスコードが間違っています-指定されたパラメータは不正です。'
      return false
    end

    # ハッシュに変換
    passcode_hash = HashSHA.get512(passcode + uuid + 'XQQ2021');

    # サーバ処理
    sql = 'select passcode_hash from kouhou.tmp_users where del_flg=0 and ena_flg=1 and uuid=?;'
    res = execSql(sql, uuid)

    puts "#{res.size} entry ... "
    # 返ってきたデータの数がおかしくないか
    if(res==nil||res.size!=1)
      raise CommonErrorView, '整合性エラー-有効な一時ユーザは存在しません。'
      return false 
    end

    # パスコードのチェック
    hash = res.first['passcode_hash']
    if(hash!=passcode_hash)
      raise CommonErrorView, 'パスコードが間違っています-指定されたパラメータは不正です。'
      return false
    end

    # ここまでたどり着いたら正解
    # ユーザを有効にする
    sql = 'update kouhou.users set status=? where uuid=?;'
    execSql(sql, 2, uuid)

    # ログイン画面にリダイレクト
    redirect to('/kousenuser/login')
    return true
  end

  get '/kousenuser/login' do
    erb :user_login
  end

  post '/kousenuser/STN/login' do
    email  = params['STMxxOHCE'] ||=''
    passwd = params['STNxxECHO'] ||=''
  
    sql = 'select * from kouhou.users where del_flg=0 and status=2 and email=?;'
    res = execSql(sql, email)

    if res.size!=1||res==nil||res.first['status'].to_i!=2||res.first['del_flg']==1
      raise CommonErrorView, 'ユーザエラー-Emailまたはパスワードが不正です。'
      return false
    end

    person      = res.first # 一つ取り出す
    uuid        = person['uuid']
    passhash_db = person['passhash']
    passhash_pm = HashSHA.get512(passwd + uuid + 'XQQ2021');

    # パスワードチェック
    puts "BD => #{passhash_db} , PARAM => #{passhash_pm}"
    if passhash_db!=passhash_pm
      raise CommonErrorView, 'ユーザエラー-Emailまたはパスワードが不正です。'
      return false
    end

    ses = generateUserToken(uuid)

    session[:uuid] = uuid
    session[:email] = email
    session[:token] = ses[:token]
    session[:expire] = ses[:expire]

    redirect to('/kousen/mypage')
  end

  get '/kousen/mypage' do
    isLogined = checkUserToken('/kousenuser/logout')
    return 403 if !isLogined
    
    uuid = session[:uuid]
    sql = 'select first_name from kouhou.users where del_flg=0 and status=2 and uuid=?;'
    res = execSql(sql, uuid)
    @first_name = res.first['first_name']
    erb :user_mypage
  end
  
  get '/kakunin_login' do
    isLogined = checkUserToken('/logouted')

    if isLogined
      return "LOGINED"
    else
      return "NOT_LOGINED"
    end
  
  end

  get '/kousenuser/logout' do
    uuid = session[:uuid]
    discardUserToken(uuid) if uuid!=nil && uuid!=''
    session[:uuid] = nil
    session[:email] = nil
    session[:token] = nil
    session[:expire] = nil
    redirect '/kousenuser/login'
    return true
  end

  get '/kousenuser/reset' do
    erb :user_reset
  end

  post '/kousenuser/STN/reset' do
    email = params['RSTxxOHCE'] ||=''
    mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    if email==nil || email==''# || !email.match? mailRegex
      raise CommonErrorView, "形式エラー-形式が不正です"
      return false
    end

    sql = 'select uuid from kouhou.users where email=? and del_flg=0;'
    res = execSql(sql, email)
    
    if res.count!=1
      raise CommonErrorView, "不正ユーザ-ユーザは存在しません"
      return false
    end

    uuid = res.first['uuid']
    password = generateTmpPasscode()
    password_hash = HashSHA.get512(password + uuid + 'XQQ2021');

    sql = 'update kouhou.users set passhash=? where uuid=? and email=? and del_flg=0;'
    execSql(sql, password_hash, uuid, email)

    sendNewPassEmail(email, password)

    redirect to('/user_reset_msg.html')
  end
end
