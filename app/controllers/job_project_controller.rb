class JobProjectController < ApplicationController 
  def index 
    @projects = JobProject.awarded.take(25)
  end

  def show

  end
end