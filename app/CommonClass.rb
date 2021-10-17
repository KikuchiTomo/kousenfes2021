# coding: utf-8
require "rubygems"
require "sinatra/base"

#
# 共通クラス
# 共通の処理を行う
#
class CommonClass < Sinatra::Base
  use Rack::Session::Cookie,
      :key            => 'XKXOXSXEXNX', 
      :secret => 'G9j5LtEbxK0SeNyc',
      :expire_after => 3600 * 24 * 30

  # 本番環境ではコメントアウト
  set :environment, :production

    # Errorメッセージを表示する
  class CommonErrorView < StandardError; end
  error CommonErrorView do
    @error_title = env['sinatra.error'].message.split('-')[0]
    @error_desc  = env['sinatra.error'].message.split('-')[1]
    erb :error
  end

  error 400 do
    @error_title = "400 Error"
    @error_desc  = "Bad Request<br>リクエストが不正です"

    erb :error
  end

  error 403 do
    @error_title = "403 Error"
    @error_desc  = "Forbidden<br>アクセス権がありません"
    erb :error
  end

  error 404 do
    @error_title = "404 Error"
    @error_desc  = "Not Found<br>リソースが見つかりません"
    erb :error
  end

  error 408 do
    @error_title = "408 Error"
    @error_desc  = "Request Timeout<br>リクエストがタイムアウトしました"
    erb :error
  end

  error 409..451 do
    @error_title = "4XX Error"
    @error_desc  = "エラーが発生しました"
    erb :error
  end

  error 500..510 do
    @error_title = "5XX Error"
    @error_desc  = "サーバでエラーが発生しました"
    erb :error
  end

  def isNilParams(*args)
    args.each do |param|
      return true if param==nil || param=='' || param=='\n' || param=='\n\r'
    end
    return false
  end
  
  get '/check/sinatra/process' do
    return 'Everything is OK'
  end

  get '/check/sinatra/error' do
    raise CommonErrorView, 'ErrorCheck-LocalExceptionIsOK!'
  end
end
