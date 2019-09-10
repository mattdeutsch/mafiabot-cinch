require "cinch"

class Identifier
	include Cinch::Plugin

	match(/identify (.+)$/)

	def execute(m, password)
		return unless m.channel.nil?
		nickServ = User("NickServ")
		nickServ.msg "identify #{password}"
		m.user.msg "Sent password."
	end
end