require 'sinatra'

require_relative 'datastore'

module Services
  class SaveContact
    class << self
      def save(params)
        Sinatra::Application.settings.logger.info("SaveContact params=#{params.inspect}")
        Rollbar.info('SaveContact', params: params)

        datastore_service = Services::Datastore.instance

        params_datastore_mapping = {
          'contact-name' => 'Nome',
          'contact-phone' => 'Telefone',
          'contact-email' => 'Email',
          'contact-subject' => 'Assunto',
          'contact-message' => 'Mensagem',
        }

        contact = {}
        params_datastore_mapping.each do |k, v|
          contact[v] = params[k]
        end

        datastore_service.save('Contact', contact)

        true
      rescue => e
        Sinatra::Application.settings.logger.error("SaveContact error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil

        false
      end
    end
  end
end
