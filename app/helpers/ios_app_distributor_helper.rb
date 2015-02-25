
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
    
    module IPA
        require 'rubygems'
        require 'zip'
        require 'plist'
        require 'tempfile'
        require 'zip'
        require 'zip/filesystem'
        require 'cfpropertylist'
        
        class ExtractIPA 
            attr_accessor :mobile_provision_entry, :info_plist_entry
            def initialize ipa_name  
                ipa_file_path = Rails.root.join('public', 'ipa', ipa_name+'.ipa').to_s
                zip_ipa_path = Rails.root.join('public', 'ipa', ipa_name+'.zip').to_s
                zip_app_path = Rails.root.join('public', 'ipa', ipa_name+'app.zip').to_s
                app_path = Rails.root.join('public', 'ipa', ipa_name+'app.app').to_s
                payload_path = Rails.root.join('public', 'ipa').to_s
                #File.rename(ipa_file_path, zip_ipa_path)
                
                Zip::File.open(ipa_file_path) do |ipa_file|
                    appDirecoty = ipa_file.glob('Payload/*.app').first
                    if appDirecoty
                        ipa_file.dir.entries("Payload").each do |dir_entry|
                            if dir_entry =~ /.app$/
                                puts "Using .app: #{dir_entry}"
                                @mobile_provision_entry = ipa_file.find_entry("Payload/#{dir_entry}/embedded.mobileprovision")
                                @info_plist_entry = ipa_file.find_entry("Payload/#{dir_entry}/Info.plist")
                                break
                            end
                        end
                    end
                end
            end
            
            def mobile_provision
                if !@mobile_provision_entry
                    return nil
                else
                    tempfile = Tempfile.new(::File.basename(@mobile_provision_entry.name))
                    mobile_provision_info = Hash.new
                    begin
                        @mobile_provision_entry.extract(tempfile.path){ override = true }
                        #mobile_provision_data = Plist::parse_xml(`security cms -D -i #{tempfile.path}`)
                        mobile_provision_data = Plist::parse_xml(`openssl smime -inform der -verify -in #{tempfile.path}`)
                        #plist = CFPropertyList::List.new(:file => tempfile.path)
                        #plist = CFPropertyList::List.new(:data => `security cms -D -i #{tempfile.path}`)
                        #plist = CFPropertyList::List.new(:data => `openssl smime -inform der -verify -in #{tempfile.path}`)
                        #mobile_provision_data = CFPropertyList.native_types(plist.value)
                        mobile_provision_data.each do |key, value|
                            mobile_provision_info[key] = case value
                                                           when Hash
                                                             value.collect{|k, v| "#{k}: #{v}"}.join("\n")
                                                           when Array
                                                             value.join("\n")
                                                           else
                                                             value.to_s
                                                           end

                        end
                    rescue => e
                        puts e.message
                    ensure 
                        tempfile.close and tempfile.unlink
                    end
                    return mobile_provision_info
                end
            end
            
            def info_plist
                if !@info_plist_entry
                    return nil 
                else
                    tempfile = Tempfile.new(::File.basename(@info_plist_entry.name))
                    begin
                        @info_plist_entry.extract(tempfile.path){ override = true }
                        plist = CFPropertyList::List.new(:file => tempfile.path)
                        info_plist_data = CFPropertyList.native_types(plist.value)
                    rescue => e
                        puts "Error reading Info.plist -- #{e.message}"
                    ensure 
                        tempfile.close and tempfile.unlink
                    end
                    return info_plist_data
                end
            end
            
            private
            def embedded_mobileprovision_path
                Rails.root.join('public', 'ipa', 'embedded_mobileprovision').to_s
            end
            
            def info_plist_path
                Rails.root.join('public', 'ipa', 'info.plist').to_s
            end
        end
    end
end
