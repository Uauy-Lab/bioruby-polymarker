class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def get_example
  	reference = Reference.find_by(name: params[:ref])
  	example = {"value" => reference.example.chomp!}  	  	
  	respond_to do |format|
      format.json { render json: example}
    end
  end

end
