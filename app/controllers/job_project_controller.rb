class JobProjectController < ApplicationController 
  def index 
    @projects = JobProject.first(25)
  end

  def show

  end
end