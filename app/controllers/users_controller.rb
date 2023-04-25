class UsersController < ApplicationController
  def index
    @users = if params[:search].present?
               User.search_by_email(params[:search], current_user.id).includes(:avatar_attachment => [:blob])
             else
               User.where.not(id: current_user.id).order(:email).includes(:avatar_attachment => [:blob])
             end
    @users = @users.paginate(page: params[:page], per_page: 5)
  end
  def chat
    @user = User.find(params[:id])
    @messages = current_user.messages_with(@user)
    @message = Message.new
  end
end
