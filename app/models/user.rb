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

end
