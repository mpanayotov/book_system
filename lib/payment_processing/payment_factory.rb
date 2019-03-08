# PaymentFactory is our go-to gateway to process payment of each type we have adapter for
#
# Examples:
#         PaymentFactory.new(paypal_payment_params, :paypal).process
#         PaymentFactory.new(strype_payment_params, :strype).process
#         PaymentFactory.new(other_payment_params, :other).process

class PaymentFactory
  def initilize(payment_params, adapter)
    @adapter = validate_adapter(adapter)
    @payment_params = validate_payment_params(payment_params)
  end

  def process
    processor = "#{adapter.to_s.capitalize}PaymentProcessor".constantize.new(payment_params)
    processor.process_payment
  end

  private

  attr_reader :payment_params, :adapter

  def validate_payment_params(params)
    # each payment type needs different parameters in order to complete the payment
    # so we have custom validators per each type to make sure we can proceed with the payment
    "#{adapter.to_s.capitalize}ParamsValidator".constantize.valid?(payment_params)
  end

  def validate_adapter(adapter)
    # here we do our adapter validation logic
    # for example checking if payment processor is enabled/active
    # or if it resides among the ones our platform maintains
  end
end
