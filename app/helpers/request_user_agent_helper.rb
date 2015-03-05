module RequestUserAgentHelper
	def request_from_ios_device?(request)
		usr_agent = request.user_agent
		if usr_agent.match(/iPad|iPhone|iPod/i)
			return true
		end
		return false
	end

	def request_from_mobile_safari?(request)
		usr_agent = request.user_agent
		if usr_agent.match(/Mobile\/.*Safari\//i)
			if usr_agent.include? 'CriOS/'
				# Chrome tries to fool us!
				return false
			end
			return true
		end
		return false
	end
end