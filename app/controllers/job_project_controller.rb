class JobProjectController < ApplicationController 
  def index 
    @jobs = JobProject.first(25)
  end

  def show

  end
end