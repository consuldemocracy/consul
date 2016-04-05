class WelcomeController < ApplicationController
  skip_authorization_check

  layout "devise", only: [:welcome, :verification]

  def index
    if current_user
      redirect_to welcome_spending_proposals_path
    end
  end

  def welcome
  end

  def verification
    redirect_to verification_path if signed_in?
  end


end
