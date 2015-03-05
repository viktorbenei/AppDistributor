module DeviceProfilesHelper
    module Enroll 
        class MobileConfig
         attr_accessor :next_url

          def initialize request
            self.next_url = request.protocol+request.host_with_port+"/deviceprofile/register"
          end

          def outfile_path
            Rails.root.join('tmp', 'Profile.mobileconfig').to_s
          end

          def mime_type
            "application/x-apple-aspen-config; charset=utf-8"
          end

          def write_mobileconfig
            File.open(self.outfile_path, "w") do |out|
              # File.open(template_path, "r") do |tmpl|
              #   out.write tmpl.read.gsub('[NextURL]', self.next_url)
              # end
              out.write mobileconfig_template.gsub('[NextURL]', self.next_url)
            end
          end

          private
          def template_path
              Rails.root.join('public','template', 'Profile.mobileconfig').to_s
          end

          def mobileconfig_template
            return %Q{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <dict>
    <key>URL</key>
    <string>[NextURL]</string>
    <key>DeviceAttributes</key>
    <array>
      <string>UDID</string>
      <string>IMEI</string>
      <string>ICCID</string>
      <string>VERSION</string>
      <string>PRODUCT</string>
    </array>
  </dict>
  <key>PayloadOrganization</key>
  <string>App Distributor</string>
  <key>PayloadDisplayName</key>
  <string>Profile Service</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>PayloadUUID</key>
  <string>356B2FB8-ACB8-49BC-845E-141B51139BE9</string>
  <key>PayloadIdentifier</key>
  <string>com.apple_manifest_rails.get_udid</string>
  <key>PayloadDescription</key>
  <string>This temporary profile will be used to get your device UDID.</string>
  <key>PayloadType</key>
  <string>Profile Service</string>
</dict>
</plist>
            }
          end
        end
        
        class ResponseParser
          attr_accessor :plist_content_hash

          def initialize request
            request_body = request.body.read
            plist_cont = scrape_plist_content(request_body)
            self.plist_content_hash = Plist::parse_xml(plist_cont)
          end

          def get(key)
            self.plist_content_hash[key]
          end

          private
          def scrape_plist_content(input)
            printables = input.gsub(/[^[:print:]]/, '')
            return printables.match(/<plist version=\"1.0\">.*<\/plist>/)[0]
          end
      end
    end
end
