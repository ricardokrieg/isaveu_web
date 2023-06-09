require 'sinatra'

require_relative 'datastore'
require_relative '../../config/constants'

module Services
  class GetBudget
    class << self
      def all
        datastore_service = Services::Datastore.instance
        budgets = datastore_service.query(BUDGET)

        Sinatra::Application.settings.logger.info("GetBudget loaded #{budgets.size} budgets")

        budgets
      rescue => e
        Sinatra::Application.settings.logger.error("GetBudget error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil

        raise e
      end

      def find(token)
        Sinatra::Application.settings.logger.info("GetBudget loading #{token}")

        datastore_service = Services::Datastore.instance
        budget = datastore_service.find(BUDGET, token)

        if budget
          Sinatra::Application.settings.logger.info("GetBudget loaded #{budget.inspect}")
        end

        budget
      rescue => e
        Sinatra::Application.settings.logger.error("GetBudget error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil

        raise e
      end
    end
  end
end
