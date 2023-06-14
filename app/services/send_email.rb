require 'pony'

module Services
  class SendEmail
    def initialize(to, subject, body)
      @to = to
      @subject = subject
      @body = body
    end

    def run
      Pony.mail(to: @to, from: Sinatra::Application.settings.email, subject: @subject, body: @body)
    end
  end
end
