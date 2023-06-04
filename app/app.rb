require 'sinatra'
require 'sinatra/json'
require 'sinatra/content_for'
require 'rack/turnout'

require_relative '../config/rollbar_setup'

require_relative '../config/settings'
require_relative 'helpers/menu'
require_relative 'services/list_services'
require_relative 'services/save_contact'

use Rack::Turnout, maintenance_pages_path: 'app/public'

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

Services::ListServices.instance.each do |service|
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

post '/orcamento' do
  if Services::SaveContact.save(params)
    json success: 'Orçamento enviado com sucesso!'
  else
    json error: 'Erro ao enviar orçamento. Por favor, tente novamente mais tarde'
  end
end
