class StatusController < ApplicationController
  

  def summary
  	summ = ReferenceHelper.summary_by_month

  	@plots = Hash.new

  	@plots["requests"] = df_to_plot(summ, :count_requests)




  end

  def load
  end

  private
  def df_to_plot(df, column)
  	groups = df.group_by([:reference])
  	ret = Hash.new
  	groups.each_group do |dfg|
  		ref = dfg[:reference].first
  		months = Hash.new
  		dfg.each_row do |row|
  			months[row[:month]] = row[column]
  		end
  		ret[ref] = months
  	end
  	ret
  end
end
