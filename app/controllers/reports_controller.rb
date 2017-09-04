class ReportsController < ApplicationController

  def qreport
      quarter = "q2"
      year    = "2017"
      campaign_pick = "1"
      filename = pledge_report(quarter,year,campaign_pick)
      download_csv(filename)
    end

end
