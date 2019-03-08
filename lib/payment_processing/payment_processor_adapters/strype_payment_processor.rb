class StrypePaymentProcessor < BasePaymentProcessor
  # here we can place the constants specific for strype payments
  DEFAULT_CURRENCY = 'GBP'.freeze

  def process_payment
    # our strype payment processing logic here
    # here we can for instance call our specific payment processor api or load specific configuration
    # of course the whole logic will not be only within this function
  end
end
