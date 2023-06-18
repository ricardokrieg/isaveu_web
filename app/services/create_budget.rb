require 'erb'

require_relative 'send_email'

module Services
  class CreateBudget
    def initialize(budget)
      @budget = budget
    end

    def run
      if @budget.save
        to = Sinatra::Application.settings.email
        subject = Sinatra::Application.settings.email_new_budget_subject

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
      File.join(Sinatra::Application.settings.root, 'views', 'mailer', 'new_budget.erb')
    end
  end
end
