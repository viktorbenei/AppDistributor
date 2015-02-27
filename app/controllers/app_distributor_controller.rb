class AppDistributorController < ApplicationController
    def index
        @ios_device = "Mobile.Safari" #request.user_agent =~ /(Mobile\/.+Safari)/
        @profile_config_path = "/deviceprofile/mobileconfig"
    end
end
