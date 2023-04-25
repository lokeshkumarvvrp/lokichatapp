class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :sent_messages, class_name: "Message", foreign_key: "sender_id"
  has_many :received_messages, class_name: "Message", foreign_key: "receiver_id"
  has_one_attached :avatar
  after_create :send_mail


  scope :search_by_email, ->(query, current_user_id) {
    where("email LIKE ?", "#{query}%")
      .where.not(id: current_user_id)
      .order(:email)
  }


  def messages_with(other_user)
    sent_messages.where(receiver: other_user)
                 .or(received_messages.where(sender: other_user))
                 .includes(:sender)
                 .order(created_at: :asc)
  end


  def user_name
    email.split('@')[0].capitalize
  end


  def send_mail
    SendSignUpEmailJob.perform_now(self)
  end
end