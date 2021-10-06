# coding: utf-8
require 'sinatra/base'
require './CommonClass.rb'

class KousenFestivalRootApplication  < CommonClass
  get '/' do
    erb :index
  end
end
