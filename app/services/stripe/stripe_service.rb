require 'stripe'

module Stripe
    class StripeService
        def initialize()
            Stripe.api_key = ENV['STRIPE_SECRET_KEY']
        end

        def find_or_create_customer(customer)
            if customer.stripe_customer_id.present?
                stripe_customer = Stripe::Customer.retrieve(customer.stripe_customer_id)
            else
                stripe_customer = Stripe::Customer.create({
                    name: customer.first_name,
                    email: customer.email,
                    phone: customer.full_phone_number
                })
                customer.update(stripe_customer_id: stripe_customer.id)
            end
            stripe_customer
        end
    end
end