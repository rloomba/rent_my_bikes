class ListingsController < ApplicationController
  def index
    @listings = Listing.all
  end

  def show
    @listing = Listing.find(params[:id])
  end

  def create
    # generate marketplace object
    marketplace = Balanced::Marketplace.my_marketplace
    user, owner = nil, nil
    bank_account_uri = params[:bank_account_uri]

    # logic to handle guest/not signed in users
    if user_signed_in?
      user = current_user
      unless user.customer_uri
        # add user to Balanced marketplace unless user already exists in marketplace
        begin
          owner = marketplace.create_customer(
            :name   => user.name,
            :email  => user.email
            )
        rescue
          "There was an error adding customer to marketplace"
        end
      end
      user.customer_uri = owner.uri
    else
      begin
          owner = marketplace.create_customer(
          :name   => params[:"guest-name"],
          :email  => params[:"guest-email_address"]
          )
      rescue
        "There was an error adding a customer to marketplace"
      end
    end

    # add bank account uri passed back from balanced.js

    owner.add_bank_account(bank_account_uri)
    if user
      listing = Listing.create(:title => 'new listing!', :user_id => user.id, :owner_uri => owner.uri)
    else
      listing = Listing.create(:title => 'new listing!', :owner_uri => owner.uri)
    end
    render :confirmation
  end

  def new
  end

end

