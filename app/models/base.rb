require 'sinatra'

require_relative '../services/datastore'
require_relative '../../config/constants'

class Base
  def initialize(attrs)
    attrs.each do |k, v|
      method = "#{k}="
      send(method, v) if respond_to?(method)
    end
  end

  def to_entity
    raise 'Not implemented'
  end

  def self.datastore_service
    Services::Datastore.instance
  end

  def self.logger
    Sinatra::Application.settings.logger
  end

  def self.log_exception(klass, exception)
    logger.error("#{klass} error=#{exception.message}")
    logger.error(exception.backtrace.join("\n"))
    Rollbar.error(exception) rescue nil
  end
end
