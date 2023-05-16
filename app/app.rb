require 'sinatra'
require_relative '../config/settings'
require_relative 'helpers/menu'
require_relative 'services/service_list_service'

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

get '/servicos/bombeiro-hidraulico' do
  @body_class = 'page-services'

  erb :'servicos/bombeiro_hidraulico'
end

get '/servicos/eletricista' do
  @body_class = 'page-services'

  erb :'servicos/eletricista'
end

get '/servicos/pedreiro' do
  @body_class = 'page-services'

  erb :'servicos/pedreiro'
end

get '/servicos/pintor' do
  @body_class = 'page-services'

  erb :'servicos/pintor'
end

get '/servicos/seguranca' do
  @body_class = 'page-services'

  erb :'servicos/seguranca'
end

get '/contato' do
  @body_class = 'page-contactus'
  @main_wrapper_class = 'pages'

  erb :contact
end
