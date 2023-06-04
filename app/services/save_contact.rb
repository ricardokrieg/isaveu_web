require_relative 'datastore'

module Services
  class SaveContact
    class << self
      def save(params)
        p params

        datastore_service = Services::Datastore.instance

        params_datastore_mapping = {
          'contact-name' => 'Nome',
          'contact-option' => 'Forma de contato',
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
        # TODO Rollbar
        p e
        false
      end
    end
  end
end
