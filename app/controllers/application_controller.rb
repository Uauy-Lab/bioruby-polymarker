class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format != 'application/json' }
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def get_example
  	reference = Reference.find_by(name: params[:ref])
  	example = {"value" => reference.example}  	  	
  	respond_to do |format|
      format.json { render json: example}
    end
  end

end
