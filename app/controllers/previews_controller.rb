class PreviewsController < ApplicationController
  # respond_to :js
  before_filter :prepare_args

  def capture
    @renderer = ImageProcessing::Renderers::Html.new 
    p ">>>>>> #{@element_id_to_capture}"
    temp_path = @renderer.render_element @url_to_capture, element_id: @element_id_to_capture
    send_data open(temp_path, "rb").read
    FileUtils::rm_rf(temp_path)
  end 

  def prepare_args
    @url_to_capture = params[:target_url]   
    @element_id_to_capture = params[:element_id]   
  end 
end
