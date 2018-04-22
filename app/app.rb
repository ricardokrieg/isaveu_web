require 'sinatra'
require_relative 'helpers/menu'

before(%r{/(.+)/}) { |path| redirect(path, 301) }

get '/' do
  erb :home
end

get '/servicos' do
  erb :services
end

get '/contato' do
  erb :contact
end
