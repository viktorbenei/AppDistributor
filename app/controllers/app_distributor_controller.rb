class AppDistributorController < ApplicationController
	include RequestUserAgentHelper
	
    def index
        @is_mobile_safari = request_from_mobile_safari?(request)
        @profile_config_path = "/deviceprofile/mobileconfig"
    end
end
