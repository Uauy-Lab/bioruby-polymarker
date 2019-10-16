class StatusController < ApplicationController
  PlotDesc = Struct.new(:div_id, :column, :description)

  def summary
  	@plot_ids = [
  		PlotDesc.new("requests",:count_requests, "Total requests"),
  		PlotDesc.new("markers",:count_markers, "Total requested markers")
  	]
  	summ = ReferenceHelper.summary_by_month
  	@plots = Hash.new
  	@plot_ids.each do |p|
  		@plots[p.div_id] = df_to_plot(summ, p.column)
  	end
  end

  def load
  end

  private
  def df_to_plot(df, column)
  	groups = df.group_by([:reference])
  	ret = Hash.new
  	all_months = df[:month].uniq.sort
  	dataset = []
  	groups.each_group do |dfg|
  		ref = dfg[:reference].first
  		data = Hash.new
  		data[:label] = ref 
  		months = Hash.new

  		all_months.each { |e| months[e] = 0  }
  		dfg.each_row do |row|
  			months[row[:month]] = row[column]
  		end
  		data[:data] = months.values
  		dataset << data
  	end
  	ret[:all_months] = all_months
  	ret[:datasets]    = dataset
  	ret
  end
end
