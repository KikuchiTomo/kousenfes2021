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

  GET '/user/sinup' do
    erb: 
  end

  GET '/user/sinup/email_check' do
    param_access_key = params[:access_key] ||= ''
    param_uuid       = params[:uuid]       ||= ''

    # 必須パラメータがない時は，共通エラー画面へ遷移
    if isNilParams(param_uuid, param_access_key)
      raise CommonErrorView, '不正なパラメータ-必須パラメータが取得できませんでした'
      return
    end

    # uuidからアクセスキーを調べる
    sql = 'select access_key from kouhou_db.tempolary_user_passcode where uuid=? and enable_flag=1 and delete_flag=0;'
    res = execSql(sql, param_uuid);
    access_key = res.first[:access_key]

    # 共通エラー画面に飛ばす
    if(access_key != param_access_key)
      raise CommonErrorView, "不正なアクセス-アクセスキー("+param_access_key+")は存在しませんでした."
      return      
    end

    # enable_flagを2(アクセスキー認証済み)に変更
    sql = 'update kouhou_db.tempolary_user_passcode set enable_flag=? where uuid=? and enable_flag=1 and delete_flag=0;'
    execSql(sql, 2, param_uuid);

    erb :sinup_email_check
  end

  POST '/user/sinup/email_check' do
    param_uuid = params[:uuid] ||= ''
    param_passcode = params[:passcode] ||=''

    if isNilParams(param_uuid, param_passcode)
      raise CommonErrorView, '不正なパラメータ-必須パラメータが取得できませんでした'
      return 
    end

    sql = 'select passcode_hash from kouhou_db.tempolary_user_passcode where uuid=? and enable_flag=2 and delete_flag=0;'
    res = execSql(sql, param_uuid);
    passcode_hash = res.first[:passcode_hash]

    param_passcode_hash = HashSHA.get512(param_passcode + param_uuid + 'XQQ2021')

    if param_passcode_hash != passcode_hash
      raise CommonErrorView, "不正なアクセス-このパスコードは有効ではありません"
      return            
    end

    #TODO+ tempolary_user_passcodeのdelete_flagを1に
    #TODO+ usersのenable_flagを2に
    # 0 : 無効 , 1 : 未認証, 2 : 認証済み
  end
end
