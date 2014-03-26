# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base

  EMAIL_REGEX = /\A[\w+\-.]+@andover\.edu\z/i
  password_length = 8..128

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable

  validates_presence_of :email, :if => :email_required?
  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?
  validates_format_of :email, :with => EMAIL_REGEX, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :password, :within => password_length, :allow_blank => true

  def email=(address)
    if new_record?
      write_attribute(:email, address)
    else
      raise 'email is immutable!'
    end
  end 

  private
  
    def email_required?
      true
    end

    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

end
