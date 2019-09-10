class Adjudicator
	attr_reader :deaths

	def initialize(playerlist)
		@playerlist = playerlist.clone
		@deaths = []
		@results = []
		perform_all_night_actions
	end

	def perform_all_night_actions
		@playerlist.sort_by!(&:priority)
		@playerlist.each do |player|
			next if player.target.nil?
			perform(player)
		end
	end

	def perform(player)
		if player.action.eql? :mafia
			@deaths << player.target
			player.target.target = nil
		elsif player.action.eql? :inspector
			@results << {user: player, message: "#{player.target.user.name} is a #{player.target.action}"}
		end
	end

	def results
	end

end