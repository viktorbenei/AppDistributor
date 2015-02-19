module IosAppDistributorHelper
    module Enroll
        class MobileConfig
         attr_accessor :next_url

          def initialize request
            self.next_url = "http://#{request.host}/enroll/extract_udid"
          end

          def outfile_path
            Rails.root.join('tmp', 'Profile.mobileconfig').to_s
          end

          def mime_type
            "application/x-apple-aspen-config; charset=utf-8"
          end

          def write_mobileconfig
            File.open(self.outfile_path, "w") do |out|
              File.open(template_path, "r") do |tmpl|
                out.write tmpl.read.gsub('[NextURL]', self.next_url)
              end
            end
          end

          private
          def template_path
              Rails.root.join('public','template', 'Profile.mobileconfig').to_s
          end
        end
        
        class ResponseParser
          attr_accessor :body

          def initialize request
            self.body = deobfuscate(request.body.read)
          end

          def get key
            self.body.match(/<key>#{key}<key><string>([a-zA-Z0-9]+)<string>/)[1]
          end

          private
          def deobfuscate(input)
            regex = /[A-Za-z0-9]|\>|\<|\?|\!|\"/
            input.chars.select{|i| i.match(regex) }.join
          end
      end
    end
end
