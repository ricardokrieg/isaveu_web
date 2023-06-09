require 'sinatra'

require_relative 'datastore'
require_relative '../../config/constants'

module Services
  class SaveBudget
    class << self
      def save(params)
        Sinatra::Application.settings.logger.info("SaveBudget params=#{params.inspect}")
        Rollbar.info('SaveBudget', params: params)

        datastore_service = Services::Datastore.instance

        params_datastore_mapping = {
          'contact-service' => 'Tipo de Serviço',
          'contact-name' => 'Nome',
          'contact-whatsapp' => 'Whatsapp',
          'contact-phone' => 'Telefone',
          'contact-email' => 'Email',
          'contact-comment' => 'Comentário',
        }

        budget = {
          'Status' => 'Novo'
        }
        params_datastore_mapping.each do |k, v|
          budget[v] = params[k]
        end

        datastore_service.save(BUDGET, budget)

        true
      rescue => e
        Sinatra::Application.settings.logger.error("SaveBudget error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil

        false
      end
    end
  end
end
