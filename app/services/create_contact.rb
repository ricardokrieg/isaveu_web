module Services
  class CreateContact
    def initialize(contact)
      @contact = contact
    end

    def run
      if @contact.save
        to = Sinatra::Application.settings.email
        subject = Sinatra::Application.settings.email_new_contact_subject

        # TODO delay
        Services::SendEmail.new(to, subject, body).run

        return true
      end

      false
    rescue => e
      Rollbar.error(e) rescue nil

      false
    end

    private

    def body
      template = File.read(template_file)
      ERB.new(template).result(binding)
    end

    def template_file
      File.join(Sinatra::Application.settings.root, 'views', 'mailer', 'new_contact.erb')
    end
  end
end
