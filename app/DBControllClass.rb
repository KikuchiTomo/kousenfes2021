# coding: utf-8
require "rubygems"
require "sinatra/base"
require 'mysql2'

require "./CommonClass.rb"

#
# DBへのコントロールを行うクラス
#

class DBControllClass < CommonClass
  #
  # SQLを実行するメソッド
  #
  # @param sql [String] 実行するSQL文
  # @param args [*Objects] バインドで与えるデータ
  #
  # @return DBの出力結果
  #
  def execSql(sql, *args)
    # Statementの用意
    statement = @mysql.prepare(sql)
    # コマンドの作成
    command = 'statement.execute('
    args.size.times do |index|
      command += ',' if i>0
      commnad += "args[#{index}]"
    end
    command += ')'
    # コマンドをruby上で実行
    return eval(command)
  end

  before do
    # MySQLの設定準備
    @mysql = Mysql2::Client.new(:host => "localhost", :username => "kouhou", :password => 't!aEW0L|QicC', :database => 'kouhou', :charset => 'utf8mb4', :encoding => 'utf8mb4', :collation => 'utf8mb4_bin')
  end

  after do
    # MySQLの終了
    @mysql.close()
    @mysql = nil
  end
end

