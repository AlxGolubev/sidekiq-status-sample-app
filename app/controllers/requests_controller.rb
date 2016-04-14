class RequestsController < ApplicationController
  respond_to :js

  def create
    @response = Bot.new(params[:command]).call
    respond_with @reponse
  end
end
