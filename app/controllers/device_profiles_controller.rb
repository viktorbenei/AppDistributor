class DeviceProfilesController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def mobileconfig
      enroll = DeviceProfilesHelper::Enroll::MobileConfig.new(request)
      enroll.write_mobileconfig
      send_file enroll.outfile_path, type: enroll.mime_type
    end
    
    def register
      parser = DeviceProfilesHelper::Enroll::ResponseParser.new(request)
      puts " (debug) parser.plist_content_hash: #{parser.plist_content_hash}"
      udid = parser.get 'UDID'
      puts " (debug) udid: #{udid}"
      version = parser.get 'VERSION'
      puts " (debug) version: #{version}"
      product = parser.get 'PRODUCT'
      puts " (debug) product: #{product}"
      mobile_device = MobileDevice.find_by udid:udid
      if !mobile_device
         mobile_device =  MobileDevice.new
      end
      mobile_device.udid = udid
      mobile_device.version = version
      mobile_device.product = product
      mobile_device.save!
        
      # TODO log this stuff
      request_full_host = "#{request.host}"
      if request.port
        request_full_host += ":#{request.port}"
      end
      puts " (debug) request_full_host: #{request_full_host}"
      redirect_to "http://#{request_full_host}/mobileapplications?udid=#{udid}", status: 301
    end
end
