require "./api_send.rb"

class Signups

	MINSIZE = 1

	attr_reader :users

	def initialize(join_length=10)
		reset!
		@join_length = join_length
		get_signups
	end

	def reset!
		@users = []
		@state = :nogame
	end

	def get_signups(channel, user)
		return unless start_signups(channel)

		channel.reply "A mafia game has been started in #{@channel.name}. Type \"!join\" to join! You have #{join_length} seconds to join."
		add user
		sleep join_length

		#return if aborted
		return if @state == :nogame

		unless @users.size >= MINSIZE
			ApiSend.not_enough_players
			reset!
			return nil
		end
		ApiSend.signups_over

		return @users
	end

	def start_signups(channel)
		unless @state == :nogame
			ApiSend.game_in_progress(channel)
			return false
		end
		ApiSend.channel = channel
		@state = :newgame
	end

	def add(user)
		return if @users.include? user
		if @state == :newgame
			@users << user
			ApiSend.user_has_joined(user)
		end
	end

	def newgame?
		return @state == :newgame
	end
end