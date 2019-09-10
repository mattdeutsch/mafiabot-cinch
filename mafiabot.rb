require "cinch"
require_relative "./game_controller.rb"

# This class is in charge of input and output alone.
# The logic is all in the controller.
# It is named MafiaBot so that the Cinch plugin is called such.
class MafiaBot
	include Cinch::Plugin

	match(/mafia\Z/i, method: :mafia_message)
	match(/join\Z/i, method: :join_message)
	match(/mafia(stop|end)\Z/i, method: :stop_message)
	match(/debug\Z/i, method: :debug)
	match(/runtests\Z/i, method: :run_tests)

	def initialize(*)
		super
		@control = GameController.new(self)
		@commands_received = []
	end

	# An important loop of the application. Sends commands to the
	# controller to be processed.
	timer 1, method: :every_second
	def every_second
		# The copy is made to minimize missed commands. Missed commands due to timing should be unlikely, but possible.
		copy = @commands_received.clone
		@commands_received = []
		@control.process_second(copy)
	end

	def mafia_message(m)
		escape_if_query(m)
		@commands_received << {message: :mafia, user: m.user, channel: m.channel}
	end

	def join_message(m)
		escape_if_query(m)
		@commands_received << {message: :join, user: m.user, channel: m.channel}
	end

	def debug(m)
		messages = [
			"Debug message: "
		]
		messages += @control.debug
		our_target = if m.channel.nil? then m.user else m.channel end
		messages.each {|s| tell(our_target, s)}
	end

	def run_tests(m)
		if m.channel.nil?
			tell m.user, "This was sent in a notice. This message is not colored."
		else
			tell m.channel, "This was sent in a channel. Also this message is colored."
		end
	end

  # There are certain things we will always want to do to messages before
  # sending them. This method applies these things. It should be the only way
  # we communicate to the rest of the world.
	def tell(target, message)
		if target.instance_of?(String)
			target = Target(target)
		end
		notice = true
		if target.instance_of?(Cinch::Channel)
			message = colored message
			notice = false
		end
		target.send(message, notice)
	end

	def tell_bold(target, message)
		tell target, bold(message)
	end

	private
	def escape_if_query(m)
		if m.channel.nil?
			tell m.user, "Send that message in a channel, fool."
		end
	end

	def colored(message)
		Cinch::Formatting.format(:blue, message)
	end

	def bold(message)
		Cinch::Formatting.format(:bold, message)
	end
end
