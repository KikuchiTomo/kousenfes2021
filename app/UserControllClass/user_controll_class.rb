# coding: utf-8
require "rubygems"
require "sinatra/base"
require 'mysql2'

require "./hash_class.rb"
require "../CommonClass/common_class.rb"
require "../DBControllClass/db_controll_class.rb"

#
# Userの管理を行うクラス
#
class UserControllClass < DBControllClass

  # ユーザの存在確認を行う
  # @param uuid [String]
  # @return ヒット数 [Int]
  def checkUserExist(uuid)
    # ユーザ数をカウント
    sql = 'select count(*) from　kouhou_db.users where delete_flg=0 and uuid=?;'
    cnt = execSql(sql, uuid).first
    return cnt
  end

  # Emailの一異性確認
  # @param email [String]
  # @return ヒット数 [Int]
  def checkUserEmail(email)
    # ユーザ数をカウント
    sql = 'select count(*) from　kouhou_db.users where delete_flg=0 and emial=?;'
    cnt = execSql(sql, email).first
    return cnt
  end
  
  # パスコードの生成を行う
  # @return passcode [String] パスコード
  def geneTmpPassCode()
    passcode = SecureRandom.hex(8)
    return passcode
  end

  # パスコードの登録を行う
  # @param passcode [String]　パスコード
  def regTmpPassCode(uuid, passcode)
    # 存在チェック
    return false if checkUserExist(uuid)!=1
    # ソルトはXQQ2021
    tmp_pass_hash   = HashSHA.get512(passcode + uuid + 'XQQ2021');
    # 有効期限を10分
    tmp_pass_expire = Time.now + 10 * 60;
    # ユーザ情報を更新
    sql = 'update kouhou_db.users set tmp_pass_hash=?, tmp_pass_expire=? where delete_flg=0 and uuid=?;'
    execSql(sql, tmp_pass_hash, tmp_pass_expire, uuid)
    return true
  end

  def regUserInfo(config)
    return false if checkUserExist(config[:uuid]) !=0
    return false if checkUserEmail(config[:email])!=0
    sql = 'insert into kouhou_db.users (uuid, email, pass_hash, tmp_pass_hash, tmp_pash_expire, permission, last_name, first_name, ip_last, grade_id, school_id, course_id, state) values (?,?,?,?,?,?,?,?,?,?,?,?,?);'
    # ユーザを登録
    execSql(sql,
            config[:uuid],
            config[:email],
            config[:pass_hash],
            config[:tmp_pass_hash],
            config[:tmp_pass_expire],
            config[:permission],
            config[:last_name],
            config[:first_name],
            config[:ip_last],
            config[:grade_id],
            config[:school_id],
            config[:course_id],
            config[:state])
    return true;
  end
end
