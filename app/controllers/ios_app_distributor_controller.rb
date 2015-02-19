class IosAppDistributorController < ApplicationController
    skip_before_action :verify_authenticity_token
  def index
  end
  
  def enroll
      @ios_device = "Mobile.Safari" #request.user_agent =~ /(Mobile\/.+Safari)/
  end
    
  def mobileconfig
      enroll = IosAppDistributorHelper::Enroll::MobileConfig.new(request)
      enroll.write_mobileconfig
      send_file enroll.outfile_path, type: enroll.mime_type
  end
    
    def extract_udid
      parser = IosAppDistributorHelper::Enroll::ResponseParser.new(request)
      udid = parser.get 'UDID'
      version = parser.get 'VERSION'
      product = parser.get 'PRODUCT'
      # TODO log this stuff
      redirect_to "http://#{request.host}/enroll/device_info?udid=#{udid}&version=#{version}&product=#{product}", status: 301
    end
    
    def device_info
        @udid = params[:udid]
        @version = prams[:version]
        @product = prams[:product]
    end
end
