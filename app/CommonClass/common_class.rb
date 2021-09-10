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

  # 設定保持用
  register Sinatra::ConfigFile
  set :show_exceptions, :after_handler

  # Errorメッセージを表示する
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
    @error_title = "4xx Error"
    @error_desc  = "エラーが発生しました"
    erb :error
  end

  error 500..510 do
    @error_title = "5xx Error"
    @error_desc  = "サーバでエラーが発生しました"
    erb :error
  end
 
  get '/check/sinatra/process' do
    return 'Everything is OK'
  end
end
