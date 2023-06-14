module Services
  class CreateContact
    def initialize(contact)
      @contact = contact
    end

    def run
      if @contact.save
        # TODO send email
        true
      else
        false
      end
    end
  end
end
