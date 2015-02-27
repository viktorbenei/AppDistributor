class MobileDevicesController < ApplicationController
    def extract_udid
      parser = IosAppDistributorHelper::Enroll::ResponseParser.new(request)
      udid = parser.get 'UDID'
      version = parser.get 'VERSION'
      product = parser.get 'PRODUCT'
      # TODO log this stuff
      redirect_to request.protocol+request.host_with_port+"/enroll/device_info?udid=#{udid}&version=#{version}&product=#{product}", status: 301
    end
end
