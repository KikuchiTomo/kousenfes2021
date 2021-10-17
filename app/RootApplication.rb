# coding: utf-8
require 'sinatra/base'
require './CommonClass.rb'
require './DBControllClass.rb'
require './UserControllClass.rb'

class KousenFestivalRootApplication  < UserControllClass
  get '/' do
    erb :index
  end
end
