class RentalsController < ApplicationController

  def create
    # initialize marketplace

    marketplace = Balanced::Marketplace.my_marketplace

    # user represents a user in our database who wants to rent a bicycle
    # buyer is a Balanced::Customer object that knows about payment information for user
    # or guest who wants to rent a bicycle

    buyer, user = nil, nil

    # logic to handle guest/not signed in users

    if user_signed_in?
      user = current_user
      if user.customer_uri
        Balanced::Customer.find(user.customer_uri)
      else
        buyer = marketplace.create_customer(
          :name   => user.name,
          :email  => user.email
          )
        user.customer_uri = buyer.uri
      end
    else
      begin
        buyer = marketplace.create_customer(
          :name   => params[:"guest-name"],
          :email  => params[:"guest-email_address"]
          )
      rescue
        "There was an error adding a customer"
      end
    end
      listing = Listing.find(params[:listing_id])

      buyer.add_card(params[:card_uri])

      owner_uri = listing.owner_uri
      owner = Balanced::Customer.find(owner_uri)

      debit = buyer.debit(
        :amount       => listing.price,
        :description  => listing.description
        )

      credit = owner.credit(
        :amount =>      listing.price,
        :description => listing.description
        )

      rental = Rental.new(
        :debit_uri  => debit.uri,
        :credit_uri => credit.uri,
        :listing_id => listing.id,
        :buyer_uri  => buyer.uri,
        :owner_uri  => owner_uri
        )

      rental.owner_id = listing.user_id if listing.user_id
      rental.buyer_id = user.id if user
      rental.save

    render :confirmation
  end
end
