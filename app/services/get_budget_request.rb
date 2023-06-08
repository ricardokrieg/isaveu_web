require 'sinatra'

require_relative 'datastore'
require_relative '../../config/constants'

module Services
  class GetBudgetRequest
    class << self
      def all
        datastore_service = Services::Datastore.instance
        budget_requests = datastore_service.load(BUDGET_REQUEST)

        Sinatra::Application.settings.logger.info("GetBudgetRequest loaded #{budget_requests.size} budget requests")

        budget_requests
      rescue => e
        Sinatra::Application.settings.logger.error("GetBudgetRequest error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil

        raise e
      end
    end
  end
end
