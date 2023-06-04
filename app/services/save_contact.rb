require_relative 'datastore'

module Services
  class SaveContact
    class << self
      def save(params)
        # TODO improve logging
        p params
        Rollbar.info('SaveContact', params: params)

        datastore_service = Services::Datastore.instance

        params_datastore_mapping = {
          'contact-service' => 'Tipo de Serviço',
          'contact-name' => 'Nome',
          'contact-whatsapp' => 'Whatsapp',
          'contact-phone' => 'Telefone',
          'contact-email' => 'Email',
          'contact-comment' => 'Comentário',
        }

        contact = {}
        params_datastore_mapping.each do |k, v|
          contact[v] = params[k]
        end

        datastore_service.save('Contact', contact)

        true
      rescue => e
        # TODO also log this
        Rollbar.error(e) rescue nil

        false
      end
    end
  end
end
