require 'singleton'
require 'google/cloud/datastore'

module Services
  class Datastore
    include Singleton

    attr_accessor :datastore

    def initialize
      @datastore = Google::Cloud::Datastore.new(
        project_id: project_id,
        credentials: config_file
      )
    end

    def save(kind, object)
      name = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L %Z %a')
      object = @datastore.entity(kind, name) do |o|
        object.each do |k, v|
          o[k] = v
        end
      end

      @datastore.save(object)
    end

    private

    def project_id
      'isaveu-205121'
    end

    def config_file
      File.join(Sinatra::Application.settings.root, '..', 'config', 'iSaveU-f0d658fd90b8.json')
    end
  end
end
