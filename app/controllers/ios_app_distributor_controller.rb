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
        @version = params[:version]
        @product = params[:product]
    end
    
    def upload
        uploaded_io = params[:mobileapp]
        randomfilename = SecureRandom.urlsafe_base64
        ipa_directory = Rails.root.join('public', 'ipa')
        if !Dir.exist?(ipa_directory)
            Dir.mkdir(ipa_directory)
        end
        File.open(Rails.root.join('public', 'ipa', randomfilename+".ipa"), 'wb') do |file|
            file.write(uploaded_io.read)
        end
        app_name = File.basename(uploaded_io.original_filename, ".ipa")
        app_extension = File.extname (uploaded_io.original_filename)
        if app_extension == ".ipa" 
            redirect_to request.protocol+request.host_with_port+"/appinfo?app_name=#{app_name}&file_name=#{randomfilename}", status:301
        else
            redirect_to request.referer, status:301
        end
    end
    
    def app_info
        @app_name = params[:app_name]
        file_name = params[:file_name]
        ipa = IosAppDistributorHelper::IPA::ExtractIPA.new(file_name)
        @mobile_provision = ipa.mobile_provision
        @info_plist = ipa.info_plist
    end
    
    def upload_application_form
    
    end
    
end
