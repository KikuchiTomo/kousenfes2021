# coding: utf-8
require "rubygems"
require "sinatra/base"
require 'mysql2'

require "./functions/hash_class.rb"
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
    sql = 'select count(*) from　kouhou.users where del_flg=0 and uuid=?;'
    cnt = execSql(sql, uuid)
    return -1 if cnt == nil
    return cnt.first
  end

  # ユーザパスコードの存在確認を行う
  # @param uuid [String]
  # @return ヒット数 [Int]
  def checkUserPasscodeDataExist(uuid)
    # ユーザ数をカウント
    sql = 'select count(*) from　kouhou.tmp_users where del_flg=0 and uuid=?;'
    cnt = execSql(sql, uuid)
    return -1 if cnt == nil
    return cnt.first
  end
  
  # Emailの一異性確認
  # @param email [String]
  # @return ヒット数 [Int]
  def checkUserEmail(email)
    # ユーザ数をカウント
    sql = 'select count(*) from　kouhou.users where del_flg=0 and emial=?;'
    cnt = execSql(sql, email)
    return -1 if cnt==nil
    return cnt.first
  end
  
  # パスコードの生成を行う
  # @return passcode [String] パスコード
  def generateTmpPasscode()
    passcode = SecureRandom.hex(8)
    return passcode
  end

  # パスコードの登録を行う
  # @param passcode [String]　パスコード
  def registerTmpPasscode(uuid, passcode)
    # 存在チェック
    return false if checkUserExist(uuid)!=1

    # ソルトはXQQ2021
    passcode_hash   = HashSHA.get512(passcode + uuid + 'XQQ2021');
    # 有効期限を10分
    passcode_expire = Time.now + 10 * 60
    passcode_count = checkUserPasscodeDataExsit(uuid)
    if tmp_user_cnt==1 then
      # 存在する場合は，更新する
      # ユーザ情報を更新
      sql = 'update kouhou.tmp_users set passcode_hash=?, access_key=?, expire=? where delete_flg=0 and uuid=?;'
      execSql(sql, passcode_hash, access_key, passcode_expire, uuid)
      return true
    elsif tmp_user_cnt==0 then
      # 存在する場合は，登録する
      sql = 'insert into kouhou.tmp_users (uuid, passcode_hash, access_key, expire) values (?,?,?,?);'
      execSql(sql, uuid, passcode_hash, access_key, passcode_expire)
      return true
    else
      return false
    end
  end

  get '/user/sinup' do
    erb :user_sinup
  end

  post '/user/sinup' do
    fname = params['first_name'] ||=''
    lname = params['last_name']  ||=''
    fname_rb = params['first_name_h'] ||=''
    lname_rb = params['last_name_h']  ||=''
    cate = params['cate'] ||=''
    cate = cate.to_i if cate!=''
    sname = params['school-name'] ||=''
    grade = params['grade'] ||=''
    course = params['course'] ||=''
    password = params['password'] ||=''
    email = params['email'] ||=''

    mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

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

    # uuid生成
    uuid = SecureRandom.uuid
    if checkUserPasscodeDataExist(uuid)>0
      raise CommonErrorView, '処理エラー-ユーザIDの生成に失敗しました．'
      return false
    end
    
    # passcode生成
    passcode = generateTmpPasscode()
    # DBへ登録
    registerTmpPasscode(uuid, passcode)

    # 可読性が落ちるけどテーブル作る時間もないので
    return fname
  end
    #TODO+ tempolary_user_passcodeのdelete_flagを1に
    #TODO+ usersのenable_flagを2に
    # 0 : 無効 , 1 : 未認証, 2 : 認証済み
end
