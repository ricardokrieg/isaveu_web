require_relative 'base'

class Budget < Base
  STATUSES = [
    STATUS_NEW,
    STATUS_ACCEPTED,
    STATUS_REJECTED,
    STATUS_PAID,
    STATUS_DONE,
    STATUS_CANCELED,
  ].freeze

  attr_accessor :service, :name, :whatsapp, :phone, :email, :comment
  attr_accessor :status, :budget_text, :reject_text, :paid_at, :review_rating,
                :review_comment, :reviewed_at, :worker_name
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
      paid_at: @paid_at,
      review_rating: @review_rating,
      review_comment: @review_comment,
      reviewed_at: @reviewed_at,
      worker_name: @worker_name,
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
    else
      return nil
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

    @token = Budget.datastore_service.save(BUDGET, to_entity, ['comment', 'budget_text', 'reject_text'])

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

  def status_paid?
    @status == STATUS_PAID
  end

  def status_done?
    @status == STATUS_DONE
  end

  def status_canceled?
    @status == STATUS_CANCELED
  end

  def accept!
    update(status: STATUS_ACCEPTED)
  end

  def reject!(reject_text)
    update(status: STATUS_REJECTED, reject_text: reject_text)
  end

  def pay!
    update(status: STATUS_PAID, paid_at: Time.now)
  end

  def review!(rating, comment)
    update(review_rating: rating, review_comment: comment, reviewed_at: Time.now)
  end

  def has_reject_text?
    @reject_text != nil && @reject_text != ''
  end
end
