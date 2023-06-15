require_relative 'base'

class Contact < Base
  attr_accessor :name, :phone, :email, :subject, :message
  attr_accessor :token, :created_at
  attr_accessor :entity

  def to_entity
    {
      name: @name,
      phone: @phone,
      email: @email,
      subject: @subject,
      message: @message,
      created_at: @created_at,
    }
  end

  def self.from_entity(entity)
    Contact.new(entity.properties.to_hash).tap do |b|
      b.token = entity.key.name
      b.entity = entity
    end
  end

  def self.all
    entities = datastore_service.query(CONTACT)

    logger.info("Contact loaded #{entities.size} contacts")

    entities.map {|e| from_entity(e)}
  rescue => e
    log_exception('Contact.all', e)

    raise e
  end

  def self.find(token)
    logger.info("Contact find #{token}")

    entity = datastore_service.find(CONTACT, token)

    if entity
      logger.info("Contact found #{entity.inspect}")
    end

    from_entity(entity)
  rescue => e
    log_exception('Contact.find', e)

    raise e
  end

  def save
    @created_at = Time.now

    Contact.logger.info("Contact save #{to_entity.inspect}")
    Rollbar.info('New Contact', attrs: to_entity)

    @token = Contact.datastore_service.save(CONTACT, to_entity, ['subject', 'message'])

    true
  rescue => e
    Contact.log_exception('Contact#save', e)

    false
  end
end
