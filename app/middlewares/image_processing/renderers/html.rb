require 'selenium-webdriver'
require 'headless'

module ImageProcessing
  module Renderers
    class Html

      def initialize
        @img_processing_tmp_dir = File.join("#{Rails.root}", "tmp", "previews")
        FileUtils::mkdir_p(@img_processing_tmp_dir) # Creates the dir only if doesn't exist already          
      end

      def render_element(url, options = {})
        start_time = DateTime.now
        temp_path = File.join(@img_processing_tmp_dir, "remote_html_#{start_time.to_i}.png")
        puts "---- START: #{start_time} ----"
        puts ">>>>>>>>>>>>>>>>>>> #TMP PTH: #{temp_path}"

        Headless.ly do
          driver = Selenium::WebDriver.for :firefox

          begin
            url = CGI.parse(url).keys.first
            element = driver.get url
            sleep 0.5.seconds # Wait for javascript load to complete
            element_id = options[:element_id]

            unless element_id.blank?
              requested_element = driver.find_element(:id => element_id)

              driver.manage.window.resize_to(requested_element.size.width, requested_element.size.height)
              requested_element.location_once_scrolled_into_view

              driver.save_screenshot(temp_path)
              sleep 0.5.seconds # Make sure screenshot is properly saved 

              # For some reason, the firefox webdriver's screen shot size is higher than the actual window size - Crop it to its real size
              cmd = "convert #{temp_path} -crop #{requested_element.size.width}x#{requested_element.size.height}+0+20 +repage #{temp_path}"  
              puts ">>>>>>>>>>>>>> Crop: \n#{cmd}" 
              system(cmd)
            else
              driver.manage.window.maximize
              driver.save_screenshot(temp_path)
            end
          ensure
            driver.quit
          end  
        end 

        end_time = Time.now
        puts "---- END: #{end_time} ----"
        puts "---- Rendering took: #{(end_time - start_time).to_f} seconds ----"

        temp_path     
      end
    end
  end
end
