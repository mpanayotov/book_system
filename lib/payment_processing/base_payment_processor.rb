class BasePaymentProcessor
  def initialize(payment_params)
    @payment_params = payment_params
  end

  # each processor(adaptor) needs to implement process_payment method
  # as it will serve as the public API that each processor will call to process a payment
  def process_payment
    raise NotImplementedError, "#{self.class.to_s} must implement process_payment method"
  end

  private

  attr_reader :payment_params
end
