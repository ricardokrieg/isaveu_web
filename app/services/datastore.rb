require 'singleton'
require 'securerandom'
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
      name = SecureRandom.uuid

      object = @datastore.entity(kind, name) do |o|
        object.each do |k, v|
          o[k] = v
        end

        o['Timestamp'] = Time.now
      end

      Sinatra::Application.settings.logger.info("Saving DataStore object: #{object.inspect}")

      @datastore.save(object)
    end

    def query(kind)
      query = Google::Cloud::Datastore::Query.new
      query.kind(kind)

      @datastore.run(query)
    end

    def find(kind, name)
      query = Google::Cloud::Datastore::Key.new(kind, name)
      entities = @datastore.lookup(query)

      entities.first
    end

    private

    def project_id
      Sinatra::Application.settings.gcloud_project_id
    end

    def config_file
      File.join(Sinatra::Application.settings.root, '..', 'config', 'gcloud_credentials.json')
    end
  end
end
