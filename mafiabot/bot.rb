require "cinch"
require "./mafiabot.rb"
require "./identifier.rb"

bot = Cinch::Bot.new do
	configure do |c|
		c.nick = "askarobot"
		c.server = "irc.synirc.net"
		c.channels = ['#circus']
		c.plugins.plugins = [MafiaBot, Identifier]
		c.messages_per_second = 2
	end

	on :message, /want some weed?/ do |m|
		m.reply "CHOOSE TO REFUSE!" 
	end

	on :message, /simple/ do |m|
		m.reply "i'm no simpleton"
	end

	on :message, /terrible/ do |m|
		m.reply "i am: NOT terrible"
	end
end

bot.start