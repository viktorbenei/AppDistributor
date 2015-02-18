class IosAppDistributorController < ApplicationController
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
end
