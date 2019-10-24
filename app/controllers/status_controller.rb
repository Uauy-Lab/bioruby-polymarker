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

  def getColor(index)
    colors = ["#a6cee3" ,
              "#1f78b4" ,
              "#b2df8a" ,
              "#33a02c" ,
              "#fb9a99" ,
              "#e31a1c" ,
              "#fdbf6f" ,
              "#ff7f00" ,
              "#cab2d6" ,
              "#6a3d9a" ,
              "#ffff99" ,
              "#b15928" ]
    colors[index % colors.size ]
  end

  def df_to_plot(df, column)
  	groups = df.group_by([:reference])
  	ret = Hash.new
  	all_months = df[:month].uniq.sort.to_a
  	dataset = []
    i = 0
  	groups.each_group do |dfg|
  		ref = dfg[:reference].first
  		data = Hash.new
  		data[:label] = ref 
  		months = Hash.new{|h,k| h[k] = 0}

  		dfg.each_row do |row|
  			months[row[:month]] = row[column]
  		end
      values = all_months.map { |e|  months[e] }
  		data[:data] = values
      data[:fill] = false
      data[:backgroundColor] = getColor(i)
      data[:borderColor] = getColor(i)
  		dataset << data
      i+=1
  	end
  	ret[:all_months] = all_months
  	ret[:datasets]    = dataset
  	ret
  end
end
