require 'sinatra'
require 'sinatra/json'
require 'sinatra/content_for'
require 'rack/turnout'
require 'rollbar'
require 'rollbar/middleware/sinatra'
require 'logger'

require_relative '../config/settings'
require_relative 'helpers/menu'
require_relative 'models/budget'
require_relative 'models/contact'
require_relative 'services/list_services'

use Rack::Turnout, maintenance_pages_path: 'app/public'
use Rack::Logger

configure do
  # TODO how will this behave when running on server? Will it log to file?
  logger = Logger.new STDOUT
  logger.level = Logger::INFO
  logger.datetime_format = '%a %d-%m-%Y %H%M '
  set :logger, logger

  Rollbar.configure do |config|
    config.access_token = settings.rollbar_token
    config.environment = Sinatra::Base.environment
    config.framework = "Sinatra: #{Sinatra::VERSION}"
    config.enabled = Sinatra::Base.environment == :production
  end
end

use Rollbar::Middleware::Sinatra

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'iSaveU$123']
  end
end

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

post '/contato' do
  contact = Contact.new(params)

  if contact.save
    json success: 'Mensagem enviada com sucesso!'
  else
    json error: 'Erro ao enviar mensagem. Por favor, tente novamente mais tarde'
  end
end

post '/solicitar-orcamento' do
  budget = Budget.new(params)

  if budget.save
    json success: 'Solicitação enviada com sucesso!'
  else
    json error: 'Erro ao enviar solicitação. Por favor, tente novamente mais tarde'
  end
end

get '/orcamento/:token' do
  @budget = Budget.find(params[:token])

  if @budget.budget_text == ''
    halt 404, 'Este orçamento não está disponível'
  end

  @bank_transfer_bank = settings.bank_transfer_bank
  @bank_transfer_agency = settings.bank_transfer_agency
  @bank_transfer_account = settings.bank_transfer_account
  @bank_transfer_whatsapp = settings.bank_transfer_whatsapp
  @bank_transfer_email = settings.bank_transfer_email
  @bank_transfer_phone = settings.bank_transfer_phone

  erb :budget
end

post '/orcamento/:token/aceitar' do
  @budget = Budget.find(params[:token])

  if @budget.budget_text == ''
    halt 404, 'Este orçamento não está disponível'
  end

  @budget.accept!

  redirect(url("/orcamento/#{@budget.token}"))
end

post '/orcamento/:token/recusar' do
  @budget = Budget.find(params[:token])

  if @budget.budget_text == ''
    halt 404, 'Este orçamento não está disponível'
  end

  @budget.reject!(params[:reject_text])

  redirect(url("/orcamento/#{@budget.token}"))
end

get '/admin' do
  protected!

  @budgets = Budget.all
  @contacts = Contact.all

  erb :admin
end

get '/admin/:token' do
  protected!

  @budget = Budget.find(params[:token])

  erb :'admin/details'
end

get '/admin/:token/editar' do
  protected!

  @budget = Budget.find(params[:token])

  erb :'admin/edit'
end

patch '/admin/:token' do
  protected!

  @budget = Budget.find(params[:token])
  # TODO if else
  @budget.update(params)

  redirect(url("/admin/#{@budget.token}"))
end

post '/admin/:token/pago' do
  protected!

  @budget = Budget.find(params[:token])
  @budget.pay!

  redirect(url("/admin/#{@budget.token}"))
end

get '/admin/contato/:token' do
  protected!

  @contact = Contact.find(params[:token])

  erb :'admin/contact_details'
end
