class PaymentsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
        # Retrieve the customer from your database or replace with your own logic
        customer = User.find(1)
    
        # Create an instance of the StripeService class
        stripe_service = Stripe::StripeService.new
    
        # Find or create the customer in Stripe
        stripe_customer = stripe_service.find_or_create_customer(customer)
    
        # Create a payment intent using the Stripe API
        payment_intent = Stripe::PaymentIntent.create(
            amount: 1000,
            currency: 'usd',
            customer: stripe_customer.id,
            payment_method: 'pm_card_visa', # Payment method object or ID
            confirm: true,
            description: 'Payment for order XYZ'
        )

        payment_intent_confirm=Stripe::PaymentIntent.confirm(
            payment_intent.id,
            {payment_method: 'pm_card_visa'},
        )
        p '11111111111111111111111111111111111111111111'
        p payment_intent_confirm
        # Return the client secret to the frontend
        render json: { client_secret: payment_intent.client_secret }
    rescue Stripe::StripeError => e
        # Handle any Stripe API errors
        render json: { error: e.message }, status: :unprocessable_entity
    end
end