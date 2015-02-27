class MobileApplicationsController < ApplicationController
    def index
        @udid = params[:udid]
        @applications = nil
    end
end
