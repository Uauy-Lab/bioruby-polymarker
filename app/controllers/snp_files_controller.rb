class SnpFilesController < ApplicationController
  def index
  end

  def new
    @snp_file = SnpFile.new
    puts @snp_file.inspect
    @snp_file
  end

  def create
     @snp_file = SnpFile.new
     @snp_file[:email] = params[:email]
     puts @snp_file
    if @snp_file.save
      redirect_to snp_file_path, notice: "The snp_file has been created!" and return
    end
    render 'new'
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def show
  end

  def person_params
    params.require(:snp_file).permit(:email)
  end
end
