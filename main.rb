require "cinch"
require_relative "./identifier.rb"
require_relative "./mafiabot.rb"
# The oauth token in a .gitignore file :)
require_relative "./password.rb"

bot = Cinch::Bot.new do
	configure do |c|
		c.nick = "alsomatthewd"
		c.server = "irc.twitch.tv"
		c.port = 6667
		c.password = $PASSWORD
		c.channels = ["#matthewdhs"]
		c.plugins.plugins = [Identifier, MafiaBot]
		c.messages_per_second = 4
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