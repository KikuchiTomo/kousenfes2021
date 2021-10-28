# coding: utf-8
require "rubygems"
require "sinatra/base"
#require "./../../home/kouhou/.rbenv/versions/3.0.2/lib/ruby/gems/3.0.0/gems/cross_origin-0.0.2/lib/cross_origin-0.0.2.rb"
require 'mysql2'
require 'json'
require 'sinatra/cross_origin'

require "./functions/hash_class.rb"
require "./CommonClass.rb"
require "./DBControllClass.rb"
require "./UserControllClass.rb"
require "./NewsControllClass.rb"

#
# Bingoの管理を行うクラス
#
class BingoControllClass < NewsControllClass

  # ビンゴカードを作成する
  # @return ビンゴカード配列 [Int]
  def generateBingoCard()
    data = Array.new
    5.times do |tr|
      num_table = Array(1+(15*tr)..15+(15*tr))
  
      # 中央には0が入る
      if tr == 2
        data_tr = num_table.sample(4)
        data_tr.insert(2, 0)
      else
        data_tr = num_table.sample(5)
      end
      data << data_tr
    end

    # 被っていないか確認
    bingo_json = {num: data}.to_json
    sql = 'select bingo from kouhou.bingo_users where bingo=? and ena_flg=1 and del_flg=0;'
    res = execSql(sql, bingo_json);
    if res.size != 0
      return generateBingoCard()
    else
      return data
    end

  end

  # ビンゴしているか判定する
  #
  # param @bingo [String] ビンゴカードJSON
  # param @num [Int] 抽選済み番号の配列
  # 
  # @return ステータス [Int] -2がビンゴ,1がリーチ,2がダブルリーチ,3がトリプルリーチ,4が...
  def bingoCheck(bingo, num)
    is_open = Array.new
    status = 0
    # numに0(フリー)を追加する
    num << 0
    # JSON展開
    data = JSON.parse(bingo)

    5.times do |tr|
      op = Array.new
      5.times do |td|
        if num.count(data['num'][tr][td]) >= 1
          op << 1
        else
          op <<0
        end
      end
      is_open << op
    end

    # リーチが見つかったらstatusに足していく,ビンゴが見つかったら即座に-2(BINGO)を返す
    # 縦列でのビンゴを探す
    5.times do |tr|
      add = 0
      5.times do |td|
        add += is_open[tr][td]
      end
      # 判定 add=4ならリーチ,add=5ならビンゴ
      if add == 4
        status += 1
      elsif add == 5
        return -2
      end
    end

    # 横列でのビンゴを探す
    5.times do |td|
      add = 0
      5.times do |tr|
        add += is_open[tr][td]
      end
      # 判定 add=4ならリーチ,add=5ならビンゴ
      if add == 4
        status += 1
      elsif add == 5
        return -2
      end
    end
    
    # 斜め\でのビンゴを探す
    add = 0
    5.times do |n|
      add += is_open[n][n]
    end
    # 判定 add=4ならリーチ,add=5ならビンゴ
    if add == 4
      status += 1
    elsif add == 5
      return -2
    end

    # 斜め/でのビンゴを探す
    add = 0
    5.times do |n|
      add += is_open[n][4-n]
    end
    # 判定 add=4ならリーチ,add=5ならビンゴ
    if add == 4
      status += 1
    elsif add == 5
      return -2
    end

    return -1 if status == 0
    return status
  end

  # ビンゴゲームの状態を保存・取得
  def startBingoGame()
    sql = 'update kouhou.bingo_game_status set status=1 where ena_flg=1 and del_flg=0 and game_id=2021;'
    execSql(sql)
  end

  def stopBingoGame()
    sql = 'update kouhou.bingo_game_status set status=-1 where ena_flg=1 and del_flg=0 and game_id=2021;'
    execSql(sql)
  end

  def isStartBingoGame()
    sql = 'select status from kouhou.bingo_game_status where ena_flg=1 and del_flg=0 and game_id=2021;'
    res = execSql(sql)
    return false if res.count!=1
    return false if res.first['status']!=1
    return true if res.first['status']==1
    return false
  end

  def getNowTurn()
    sql = 'select turn from kouhou.bingo_game_status where ena_flg=1 and del_flg=0 and game_id=2021;'
    res = execSql(sql)
    return -1 if res.count!=1
    return res.first['turn']
  end

  def indcBingoGameTurn(diff)
    turn = getNowTurn() 
    return false if !isStartBingoGame()
    return false if turn==-1
    sql = 'update kouhou.bingo_game_status set turn=? where ena_flg=1 and del_flg=0 and game_id=2021;'
    execSql(sql, turn+diff)
    return true
  end

  # ビンゴカードを生成し、登録する
  get '/kousenadmin/bingo/generate' do
    # トークンチェック
    if checkAdminToken('/kousenuser/logout') == false
      return false
    end
    # uuidの初期値は'0-0-0-0'
    uuid = '0-0-0-0'
    300.times do |n|
      bingo = generateBingoCard()

      # 平坦化したビンゴカードのJSON
      hash_bingo = {num: bingo.flatten}.to_json
      # ソルトはBNG2021 
      hash = HashSHA.get512(hash_bingo + 'BNG2021');
      bingo_data = {num: bingo}.to_json

      sql = 'insert into kouhou.bingo_users (uuid, hash, bingo) values (?,?,?);'
      execSql(sql, uuid, hash, bingo_data);
    end

    redirect to('/kousenadmin/dashboard')
  end

  # ビンゴカードをユーザに割り当てる
  get '/bingo/entry' do
    uuid = session[:uuid]

    # トークンチェック
    unless checkUserToken('https://www.kousensai.jp/kousenuser/logout')
      return false
    end

    unless isStartBingoGame()
      raise CommonErrorView, "ビンゴ開始前-ビンゴゲームは開始されていません"
      return false
    end
    # 既にデータの割り振られたuuidでないか確認
    sql = 'select id from kouhou.bingo_users where uuid=? and ena_flg=1 and del_flg=0;'
    res = execSql(sql, uuid);

    if res.size == 0
      sql = 'select id from kouhou.bingo_users where uuid=? and ena_flg=1 and del_flg=0;'
      res = execSql(sql, "0-0-0-0");

      if res.count <= 0
        raise CommonErrorView, "ビンゴエラー-ビンゴデータが不足しています"
        return false
      end

      ids = []
      res.each do |n|
        ids.push(n['id'])
      end
      id = ids.sample

      sql = 'update kouhou.bingo_users set uuid=?, status=? where id=? and ena_flg=1 and del_flg=0;'
      execSql(sql, uuid, -1, id);
    end

    erb :play_bingo
  end

  # ビンゴデータをクライアントに渡す
  register Sinatra::CrossOrigin
  get '/bingo/entry/play' do
    cross_origin
    uuid = session[:uuid]
    # トークンチェック
    #if checkUserToken('https://www.kousensai.jp/kousenuser/logout') == false
    #  return false
    #end

    sql = 'select bingo from kouhou.bingo_users where uuid=? and ena_flg=1 and del_flg=0;'
    res = execSql(sql, uuid);

    data = {
      bingo: res.first['bingo']
    }
    return res.first['bingo']#data.to_json
  end

  # ビンゴしているか判定し、クライアントにステータスと抽選済みの番号配列を返す
  get '/bingo/entry/numbers' do
    cross_origin
    param_hash = params['hash']
    uuid = session[:uuid]
    # game_idは2021を使用
    game_id = 2021

    # トークンチェック
    #unless checkUserToken('/kousenuser/logout')
    #  return false
    #end

    sql = 'select bingo, hash from kouhou.bingo_users where uuid=? and ena_flg=1 and del_flg=0;'
    res = execSql(sql, uuid);

    # ハッシュの確認
    if param_hash != res.first[:hash]
      # ERROR
      return false
    end

    sql ='select num from kouhou.bingo_nums where game_id=? and status=? and ena_flg=1 and del_flg=0;'
    num = execSql(sql, game_id, 1);
    # numを配列化
    is_open = Array.new
    num.each do |hash|
      is_open << hash.values
    end
    is_open.flatten!

    sql = 'select status from kouhou.bingo_users where ena_flg=1 and del_flg=0 and uuid=?;'
    sdb = execSql(sql, uuid)

    if sdb.count!=1
      return "Error"
    end

    # 前回ビンゴしていないならばビンゴのturn数を更新する
    status_db = sdb.first['status']
    status = bingoCheck(res.first['bingo'], is_open)
    turn_b = getNowTurn()
    
    if status_db!=-2    
      # ユーザのステータスを変更      
      sql = 'update kouhou.bingo_users set status=?, turn=? where uuid=? and ena_flg=1 and del_flg=0;'
      execSql(sql, status, turn_b, uuid);
    else
      # 前回ビンゴならずっとビンゴ状態のままにしておく
      sql = 'update kouhou.bingo_users set status=? where uuid=? and ena_flg=1 and del_flg=0;'
      execSql(sql, -2, uuid);
    end    

    turn_b = 0 if turn_b==nil
    data = {
      bingo_id: game_id,
      status: status,
      is_open: is_open,
      turn: turn_b
    }
    return data.to_json
  end

  # 指定されたnumのstarusを1(Opened)にする
  get '/kousenadmin/bingo/lottery' do
    num = params['num']||=''
    
    return "NEED ARGS" if(num=='')

    # トークンチェック
    unless checkAdminToken('/kousenuser/logout')
      return false
    end

    return "not started" if !isStartBingoGame()
    # すでにオープンだったら閉じる
    sql = 'select status from kouhou.bingo_nums where ena_flg=1 and del_flg=0 and num=?;'
    res = execSql(sql, num)
    return "ERROR: NO NUM" if res.count==0
    status = res.first['status']
    
    is_open = 1
    is_open = 0 if(status==1)
    sql = 'update kouhou.bingo_nums set status=? where num=? and ena_flg=1 and del_flg=0;'
    execSql(sql, is_open, num);

    if is_open==1
      indcBingoGameTurn(1)      
    else
      indcBingoGameTurn(-1)
    end

    redirect to('/kousenadmin/bingo/dashboard')
  end

  # ビンゴ,リーチしている人数をカウントして返す
  get '/bingo/isbingo/num' do
    sql = 'select id from kouhou.bingo_users where status=?;'
    bingo = execSql(sql, -2);

    sql = 'select id from kouhou.bingo_users where status>?;'
    reach = execSql(sql, 0);

    data = {
      bingo: bingo.count,
      reach: reach.count
    }
    return data.to_json
  end

  get '/kousenadmin/bingo/dashboard' do
    unless checkAdminToken('/kousenadmin/logout')
      return false
    end
   
    sql ='select num from kouhou.bingo_nums where game_id=? and status=? and ena_flg=1 and del_flg=0;'
    num = execSql(sql, 2021, 1);
    # numを配列化
    is_open = Array.new
    num.each do |hash|
      is_open << hash.values
    end

    is_open.flatten! if is_open!=nil

    @nums = [0] 
    @nums = @nums + is_open if is_open!=nil
    p @nums
    @turn_b = getNowTurn()
    erb :admin_bingo_dashboard
  end

  get '/kousenadmin/bingo/start' do
    unless checkAdminToken('/kousenadmin/logout')
      return false
    end
    
    startBingoGame()
    redirect to('/kousenadmin/bingo/dashboard')
  end

  get '/kousenadmin/bingo/stop' do
    unless checkAdminToken('/kousenadmin/logout')
      return false
    end
    
    stopBingoGame()
    redirect to('/kousenadmin/bingo/dashboard')
  end

  def parse_html(hash, iteration=0 )
    iteration += 1
    output = ""
    hash.each do |key, value|

        if value.is_a?(Hash)
            output += "<div class='entry' style='margin-left:#{iteration}em'> <span style='font-size:#{250 - iteration*20}%'>#{key}: </span><br>"
            output += parse(value,iteration)
            output += "</div>"
        elsif value.is_a?(Array)
            output += "<div class='entry' style='margin-left:#{iteration}em'> <span style='font-size:#{250 - iteration*20}%'>#{key}: </span><br>"
            value.each do |value|
                if value.is_a?(String) then
                    output += "<div style='margin-left:#{iteration}em'>#{value} </div>"
                else
                    output += parse(value,iteration-1)
                end
            end
            output += "</div>"

        else
            output += "<div class='entry' style='margin-left:#{iteration}em'> <span style='font-weight: bold'>#{key}: </span>#{value}</div>"
        end
    end
    return output
end

  get '/kousenadmin/bingo/get/bingo/users/list' do
    is_admin = checkAdminToken('/kousenadmin/logout')
    unless is_admin
      return false
    end

    permit_user  = session[:permit_user]
    permit_bingo = session[:permit_bingo]

    unless permit_user==1 && permit_bingo==1
      return "Permission denied: bye"
    end

    sql = 'select users.id, users.last_name, users.first_name, users.grade, users.course, users.email, users.uuid, bingo_users.turn from users inner join bingo_users on users.uuid = bingo_users.uuid where bingo_users.status = -2 order by bingo_users.turn desc;'
    res = execSql(sql)

    if(res.count<=0)
      return "ビンゴ者はいません"
    end

    @us = []
    res.each{ |row|
      h = {}
      h['name'] = row['last_name'].to_s + " " + row['first_name'].to_s
      h['grade'] = row['course'].to_s + row['grade'].to_s
      h['email'] = row['email']
      h['uuid']  = row['uuid']
      h['id']  = row['id']
      h['turn'] = row['turn']
      @us.push(h)
    }

    
    return parse_html(JSON.parse(@us.to_json))
  end
  # もう使わない
  #get '/kousenadmin/bingo/num_prepare' do
  #  checkAdminToken('/kousenadmin/logout')
  #  game = params['game_id']||=''
  #  return "need args" if game==''

  #  sql = 'insert into bingo_nums (num,  game_id) values (?,?);'
    
  #  for num in 1..75 
  #    execSql(sql, num, game)
  #  end

  #  return "DONE"
  #end

end