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

ServiceListService.instance.each do |service|
  get service['url'] do
    @body_class = 'page-services'
    @title = service['name']

    erb :'servicos/layout', layout: :layout do
      erb service['template'].to_sym
    end
  end
end

get '/contato' do
  @body_class = 'page-contactus'
  @main_wrapper_class = 'pages'

  erb :contact
end
