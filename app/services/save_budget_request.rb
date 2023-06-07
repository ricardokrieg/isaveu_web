require 'sinatra'

require_relative 'datastore'

module Services
  class SaveBudgetRequest
    class << self
      def save(params)
        Sinatra::Application.settings.logger.info("SaveBudgetRequest params=#{params.inspect}")
        Rollbar.info('SaveBudgetRequest', params: params)

        datastore_service = Services::Datastore.instance

        params_datastore_mapping = {
          'contact-service' => 'Tipo de Serviço',
          'contact-name' => 'Nome',
          'contact-whatsapp' => 'Whatsapp',
          'contact-phone' => 'Telefone',
          'contact-email' => 'Email',
          'contact-comment' => 'Comentário',
        }

        budget = {}
        params_datastore_mapping.each do |k, v|
          budget[v] = params[k]
        end

        datastore_service.save('BudgetRequest', budget)

        true
      rescue => e
        Sinatra::Application.settings.logger.error("SaveBudgetRequest error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil

        false
      end
    end
  end
end
