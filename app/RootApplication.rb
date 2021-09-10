# coding: utf-8
require 'sinatra/base'

class KousenFestivalRootApplication  < Sinatra::Base
  get '/' do
    "Hello this is Sinatra and Unicorn , Nginx!"
  end
end
