require 'sinatra'
require_relative '../config/settings'
require_relative 'helpers/menu'

before(%r{/(.+)/}) { |path| redirect(path, 301) }

before do
  @isaveu_phone = settings.phone
  @isaveu_email = settings.email
end

get '/' do
  erb :home
end

get '/servicos' do
  erb :services
end

get '/contato' do
  erb :contact
end
