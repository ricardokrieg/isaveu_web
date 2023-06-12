require_relative 'base'

class Budget < Base
  STATUSES = [
    STATUS_NEW,
    STATUS_ACCEPTED,
    STATUS_REJECTED,
  ].freeze

  attr_accessor :service, :name, :whatsapp, :phone, :email, :comment, :status, :budget_text, :reject_text
  attr_accessor :token, :created_at, :updated_at
  attr_accessor :entity

  def initialize(attrs)
    super(attrs)

    @status ||= STATUS_NEW
  end

  def to_entity
    {
      service: @service,
      name: @name,
      whatsapp: @whatsapp,
      phone: @phone,
      email: @email,
      comment: @comment,
      status: @status,
      budget_text: @budget_text,
      reject_text: @reject_text,
      created_at: @created_at,
      updated_at: @updated_at,
    }
  end

  def self.from_entity(entity)
    Budget.new(entity.properties.to_hash).tap do |b|
      b.token = entity.key.name
      b.entity = entity
    end
  end

  def self.all
    entities = datastore_service.query(BUDGET)

    logger.info("Budget loaded #{entities.size} budgets")

    entities.map {|e| from_entity(e)}
  rescue => e
    log_exception('Budget.all', e)

    raise e
  end

  def self.find(token)
    logger.info("Budget find #{token}")

    entity = datastore_service.find(BUDGET, token)

    if entity
      logger.info("Budget found #{entity.inspect}")
    end

    from_entity(entity)
  rescue => e
    log_exception('Budget.find', e)

    raise e
  end

  def save
    @created_at = Time.now

    Budget.logger.info("Budget save #{to_entity.inspect}")
    Rollbar.info('New Budget', attrs: to_entity)

    Budget.datastore_service.save(BUDGET, to_entity, ['comment', 'budget_text'])

    true
  rescue => e
    Budget.log_exception('Budget#save', e)

    false
  end

  def update(attrs)
    @updated_at = Time.now

    Budget.logger.info("Budget update #{@entity.key.name} #{attrs.inspect}")

    attrs.each do |k, v|
      method = "#{k}="
      send(method, v) if respond_to?(method)
    end

    Budget.datastore_service.update(@entity, to_entity)

    true
  rescue => e
    Budget.log_exception('Budget#update', e)

    false
  end

  def status_new?
    @status == STATUS_NEW
  end

  def status_accepted?
    @status == STATUS_ACCEPTED
  end

  def status_rejected?
    @status == STATUS_REJECTED
  end

  def accept!
    update(status: STATUS_ACCEPTED)
  end

  def reject!(reject_text)
    update(status: STATUS_REJECTED, reject_text: reject_text)
  end
end
