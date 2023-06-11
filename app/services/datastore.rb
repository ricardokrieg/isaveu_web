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

    def save(kind, object, non_indexed_keys=[])
      name = SecureRandom.uuid

      entity = @datastore.entity(kind, name) do |e|
        object.each do |k, v|
          e[k] = v
        end

        non_indexed_keys.each do |key|
          e.exclude_from_indexes! key, true
        end
      end

      Sinatra::Application.settings.logger.info("Saving DataStore entity: #{entity.inspect}")

      @datastore.save(entity)
    end

    def update(entity, attrs)
      Sinatra::Application.settings.logger.info("Updating DataStore entity: #{entity.inspect} (#{attrs.inspect})")

      attrs.each do |k, v|
        entity[k] = v
      end

      @datastore.save(entity)
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
