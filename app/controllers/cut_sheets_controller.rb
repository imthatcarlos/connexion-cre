class CutSheetsController < ApplicationController
  def index
    @cut_sheets = CutSheet.all

    respond_to do |format|
      format.html
    end
  end

  def create
  end
end
