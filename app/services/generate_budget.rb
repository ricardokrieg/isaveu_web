require 'sinatra'

require_relative 'datastore'
require_relative '../../config/constants'

module Services
  class GenerateBudget
    class << self
      def for(budget)
        Sinatra::Application.settings.logger.info("GenerateBudget for #{budget.key.name}")

        datastore_service = Services::Datastore.instance
        datastore_service.update(budget, {'Status' => 'Aguardando Aprovação'})
      rescue => e
        Sinatra::Application.settings.logger.error("GenerateBudget error=#{e.message}")
        Sinatra::Application.settings.logger.error(e.backtrace.join("\n"))
        Rollbar.error(e) rescue nil
      end
    end
  end
end
