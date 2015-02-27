class DeviceProfilesController < ApplicationController
    
    def mobileconfig
      enroll = DeviceProfilesHelper::Enroll::MobileConfig.new(request)
      enroll.write_mobileconfig
      send_file enroll.outfile_path, type: enroll.mime_type
    end
    
    def register
      parser = DeviceProfilesHelper::Enroll::ResponseParser.new(request)
      udid = parser.get 'UDID'
      version = parser.get 'VERSION'
      product = parser.get 'PRODUCT'
      mobile_device = MobileDevice.find_by udid:udid
        if !mobile_device
           mobile_device =  MobileDevice.new
        end
        mobile_device.udid = udid
        mobile_device.version = version
        mobile_device.product = product
        mobile_device.save
        
      # TODO log this stuff
      redirect_to "http://#{request.host}/mobileapplications?udid=#{udid}, status: 301
    end
end
