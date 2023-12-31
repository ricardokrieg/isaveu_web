require 'sinatra'
require 'sinatra/json'
require 'sinatra/content_for'
require 'rack/turnout'
require 'rollbar'
require 'rollbar/middleware/sinatra'
require 'logger'
require 'pony'

require_relative '../config/settings'
require_relative 'helpers/menu'
require_relative 'models/budget'
require_relative 'models/contact'
require_relative 'services/list_services'
require_relative 'services/create_budget'
require_relative 'services/create_contact'

use Rack::Turnout, maintenance_pages_path: 'app/public'
use Rack::Logger

configure do
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

  Pony.options = {
    via: :smtp,
    via_options: {
      address: settings.email_smtp_address,
      port: settings.email_smtp_port,
      enable_starttls_auto: true,
      user_name: settings.email_smtp_user,
      password: settings.email_smtp_password,
      authentication: :plain,
      domain: settings.email_smtp_domain,
    }
  }
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

  def contact_params
    params.reject {|k, v| !['name', 'phone', 'email', 'subject', 'message'].include?(k) }
  end

  def budget_params
    params.reject {|k, v| !['service', 'name', 'whatsapp', 'phone', 'email', 'comment'].include?(k) }
  end

  def admin_budget_params
    keys = ['service', 'name', 'whatsapp', 'phone', 'email', 'comment', 'status',
            'budget_text', 'reject_text', 'paid_at', 'review_rating', 'review_comment',
            'reviewed_at', 'worker_name']
    params.reject {|k, v| !keys.include?(k) }
  end
end

before(%r{/(.+)/}) { |path| redirect(path, 301) }

before do
  @isaveu_phone = settings.phone
  @isaveu_email = settings.email
end

not_found do
  status 404
  erb :not_found
end

error [] do
  erb :error
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
    @image = service['image']

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
  contact = Contact.new(contact_params)

  if Services::CreateContact.new(contact).run
    json success: 'Mensagem enviada com sucesso!'
  else
    json error: 'Erro ao enviar mensagem. Por favor, tente novamente mais tarde'
  end
end

post '/solicitar-orcamento' do
  budget = Budget.new(budget_params)

  if Services::CreateBudget.new(budget).run
    json success: 'Solicitação enviada com sucesso!'
  else
    json error: 'Erro ao enviar solicitação. Por favor, tente novamente mais tarde'
  end
end

get '/orcamento/:token' do
  @budget = Budget.find(params[:token])

  if @budget.nil? || @budget.status_new? && @budget.budget_text == ''
    halt 404, 'Este orçamento não está disponível'
  end

  if @budget.status_canceled?
    return erb :'budget/canceled'
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

  if @budget.accept!
    redirect(url("/orcamento/#{@budget.token}"))
  else
    @error_message = 'Ocorreu um erro. Não foi possível aceitar o Orçamento.'
    erb :budget
  end
end

post '/orcamento/:token/recusar' do
  @budget = Budget.find(params[:token])

  if @budget.budget_text == ''
    halt 404, 'Este orçamento não está disponível'
  end

  if @budget.reject!(params[:reject_text])
    redirect(url("/orcamento/#{@budget.token}"))
  else
    @error_message = 'Ocorreu um erro. Não foi possível recusar o Orçamento.'
    erb :budget
  end
end

post '/orcamento/:token/avaliar' do
  @budget = Budget.find(params[:token])

  if @budget.review!(params[:rating], params[:comment])
    redirect(url("/orcamento/#{@budget.token}"))
  else
    @error_message = 'Ocorreu um erro. Não foi possível salvar a Avaliação.'
    erb :budget
  end
end

#=== Admin
#===============================================================================

get '/admin' do
  protected!

  @budgets = Budget.all.select {|b| !b.status_done? && !b.status_canceled?}
  @contacts = Contact.all
  @closed_budgets = Budget.all.select {|b| b.status_done? || b.status_canceled?}

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

  if @budget.update(admin_budget_params)
    redirect(url("/admin/#{@budget.token}"))
  else
    @error_message = 'Ocorreu um erro. Não foi possível salvar o Orçamento.'
    erb :'admin/edit'
  end
end

post '/admin/:token/pago' do
  protected!

  @budget = Budget.find(params[:token])
  if @budget.pay!
    redirect(url("/admin/#{@budget.token}"))
  else
    @error_message = 'Ocorreu um erro. Não foi possível marcar o Orçamento como pago.'
    erb :'admin/details'
  end
end

get '/admin/contato/:token' do
  protected!

  @contact = Contact.find(params[:token])

  erb :'admin/contact_details'
end
