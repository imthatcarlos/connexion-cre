class TrendsController < ApplicationController
  def show

  end

  def data
    @quarter = params[:quarter] || "current"

    report = {
      "date" => range.map{ |m| m.beginning_of_month }.uniq,
      "Job Value" => arr("Job Value"),
      "Billed" => arr("Billed"),
      "Remaining Sell" => arr("Remaining Sell")
    }

    render json: report
  end

  def arr(key)
    case key
    when "Job Value"
      if @quarter == "current"
        [500, 1000, 1500, 2000]
      else 
        [500, 1000, 1500, 2000, 500, 1000, 1500, 2000]
      end
    when "Billed"
      if @quarter == "current"
        [200, 300, 1000, 1200]
      else 
        [200, 300, 1000, 1200, 200, 300, 1000, 1200]
      end
    else 
      if @quarter == "current"
        [300, 700, 500, 800]
      else 
        [300, 700, 500, 800, 300, 700, 500, 800]
      end
    end
  end

  private

  def range
    case @quarter
    when "current"
      (Date.today..(Date.today + 3.months)).to_a
    when "past"
      ((Date.today - 3.months)..(Date.today + 3.months)).to_a
    else
      raise "invalid range"
    end
  end
end