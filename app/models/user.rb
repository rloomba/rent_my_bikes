class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  :name, :customer_uri

  has_many :owner_rentals, :class_name => 'Rental', :foreign_key => 'owner_id'
  has_many :buyer_rentals, :class_name => 'Rental', :foreign_key => 'buyer_id'

  has_many :listings


  def balanced_customer(marketplace)
    if self.customer_uri
        Balanced::Customer.find(self.customer_uri)
    else
      begin
        customer = marketplace.create_customer(
          :name   => self.name,
          :email  => self.email
          )
        self.customer_uri = customer.uri
        customer
      rescue
        "There was error fetching the Balanced customer"
      end
    end
  end

  def self.create_balanced_customer(marketplace, params = {})
    begin
      marketplace.create_customer(
        :name   => params[:name],
        :email  => params[:email]
        )
    rescue
      "There was an error adding a customer"
    end
  end

end
