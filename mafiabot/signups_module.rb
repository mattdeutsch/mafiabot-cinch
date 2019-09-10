module SignupsModule
	MINSIZE = 1
	def get_signups(channel, user, join_length=10)
		reset_signups!
		@signups_state = :yes
		channel.send "A game has been started in #{channel.name}. Type \"!join\" to join! You have #{join_length} seconds to join."
		add user
		sleep join_length
		return if @signups_state == :no
		unless @signups_users.size >= MINSIZE
			ApiSend.not_enough_players
			reset_signups!
			return nil
		end
		ApiSend.signups_over
		@signups_state = :no
		return @signups_users
	end

	def add(user)
		return if @signups_users.include? user
		return if @signups_state == :no
		@signups_users << user
		ApiSend.user_has_joined(user)
	end

	def reset_signups!
		@signups_users = []
		@signups_state = :no
	end
end