class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

    rescue_from StandardError do |exception|
	    # Handle only JSON requests
	    raise unless request.format.json?

	    err = {error: exception.message}

	    err[:backtrace] = exception.backtrace.select do |line|
	      # filter out non-significant lines:
	      %w(/gems/ /rubygems/ /lib/ruby/).all? do |litter|
	         not line.include?(litter)
	      end
	    end if Rails.env.development? and exception.is_a? Exception

	    # duplicate exception output to console:
	    STDERR.puts ['ERROR:', err[:error], '']
	                    .concat(err[:backtrace] || []).join "\n"

	    render :json => err, :status => 500
  	end

  def get_example
  	reference = Reference.find_by(name: params[:ref])
  	example = {"value" => reference.example}  	  	
  	respond_to do |format|
      format.json { render json: example}
    end
  end

end
