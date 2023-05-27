require 'singleton'
require 'yaml'

module Services
  class ListServices
    include Singleton

    def initialize
      @service_list = YAML.load(File.open(file_path))
    end

    def each
      @service_list['services'].each do |service|
        yield service
      end
    end

    private

    def file_path
      File.join(Sinatra::Application.settings.root, '..', 'config', 'services.yml')
    end
  end
end
