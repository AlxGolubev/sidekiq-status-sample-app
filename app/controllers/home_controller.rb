class HomeController < ApplicationController
  before_action :add_session_identifier
  def index
  end

  private

  def add_session_identifier
    return if session[:id].present?
    session[:id] = SecureRandom.hex(10)
  end
end
