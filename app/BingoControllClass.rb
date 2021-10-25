# coding: utf-8
require "rubygems"
require "sinatra/base"
require 'mysql2'
require 'json'

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

  # ビンゴカードを生成し、登録する
  get '/kousenadmin/bingo/generate' do
    # トークンチェック
    if checkAdminToken('/kousenuser/logout') == false
      return false
    end
    # uuidの初期値は'0-0-0-0'
    uuid = '0-0-0-0'
    bingo = generateBingoCard()

    # 平坦化したビンゴカードのJSON
    hash_bingo = {num: bingo.flatten}.to_json
    # ソルトはBNG2021 
    hash = HashSHA.get512(hash_bingo + 'BNG2021');
    bingo_data = {num: bingo}.to_json

    sql = 'insert into kouhou.bingo_users (uuid, hash, bingo) values (?,?,?);'
    execSql(sql, uuid, hash, bingo_data);

    return true
  end

  # ビンゴカードをユーザに割り当てる
  get '/bingo/entry' do
    uuid = session[:uuid]

    # トークンチェック
    unless checkUserToken('/kousenuser/logout')
      return false
    end

    # 既にデータの割り振られたuuidでないか確認
    sql = 'select id from kouhou.bingo_users where uuid=? and ena_flg=1 and del_flg=0;'
    res = execSql(sql, uuid);
    if res.size != 0
      # ERROR
      return false
    end

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
    id = res.sample

    sql = 'update kouhou.bingo_users set uuid=?, status=? where id=? and ena_flg=1 and del_flg=0;'
    execSql(sql, uuid, -1, id);

    erb:
  end

  # ビンゴデータをクライアントに渡す
  get '/bingo/play' do
    uuid = session[:uuid]
    # トークンチェック
    if checkUserToken('/kousenuser/logout') == false
      return false
    end

    sql = 'select bingo from kouhou.bingo_users where uuid=? and ena_flg=1 and del_flg=0;'
    res = execSql(sql, uuid);

    data = {
      bingo: res.first[:bingo]
    }
    return data.to_json
  end

  # ビンゴしているか判定し、クライアントにステータスと抽選済みの番号配列を返す
  get '/bingo/numbers' do
    param_hash = params[:hash]
    uuid = session[:uuid]
    # game_idは2021を使用
    game_id = 2021

    # トークンチェック
    unless checkUserToken('/kousenuser/logout')
      return false
    end

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

    status = bingoCheck(bingo, is_open)

    # ユーザのステータスを変更
    sql = 'update kouhou.bingo_users set status=? where uuid=? and ena_flg=1 and del_flg=0;'
    execSql(sql, status, uuid);

    data = {
      bingo_id: game_id,
      status: status,
      is_open: is_open
    }
    return data.to_json
  end

  # 指定されたnumのstarusを1(Opened)にする
  post '/kousenadmin/bingo/lottery' do
    num = params[:num]

    # トークンチェック
    unless checkAdminToken('/kousenuser/logout')
      return false
    end

    sql = 'update kouhou.bingo_nums set status=? where num=? and ena_flg=1 and del_flg=0;'
    execSql(sql, 1, num);

    return true
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

end