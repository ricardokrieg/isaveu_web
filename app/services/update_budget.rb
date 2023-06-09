require 'sinatra'

require_relative 'datastore'
require_relative '../../config/constants'

module Services
  class UpdateBudget
    class << self
      def update(budget, attrs)
        Sinatra::Application.settings.logger.info("UpdateBudget for #{budget.key.name} (#{attrs.inspect})")

        params_datastore_mapping = {
          'contact-service' => 'Tipo de Serviço',
          'contact-name' => 'Nome',
          'contact-whatsapp' => 'Whatsapp',
          'contact-phone' => 'Telefone',
          'contact-email' => 'Email',
          'contact-comment' => 'Comentário',
          'contact-status' => 'Status',
          'contact-budget-text' => 'Texto do Orçamento',
        }
        datastore_attrs = {}
        params_datastore_mapping.each do |k, v|
          datastore_attrs[v] = attrs[k] if attrs[k]
        end

        datastore_service = Services::Datastore.instance
        datastore_service.update(budget, datastore_attrs)
      rescue => e
        Sinatra::Application.settings.logger.error("UpdateBudget error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil
      end
    end
  end
end
