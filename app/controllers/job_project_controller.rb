class JobProjectController < ApplicationController 
  def index 
    @projects = JobProject.awarded.sample(25)
  end

  def show

  end
end