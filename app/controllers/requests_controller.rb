class RequestsController < ApplicationContrller
  respond_to :js
  before_action :set_status

  def create
    @response = Bot.new(session[:id], params[:message]).message

    respond_with @reponse
  end

  private

  def set_status
    case $redis.get(session[:id])
    when '' || nil
      $redis.set(session[:id], 'welcome')
    when 'welcome'
      $redis.set(session[:id], 'requesting')
    when 'requesting'
      $redis.set(session[:id], 'parting')
    when 'parting'
      $redis.set(session[:id], 'requesting')
    end
  end
end
