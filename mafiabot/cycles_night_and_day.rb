require "./adjudicator.rb"

class CyclesNightAndDay
	NIGHTLENGTH = 20
	DELIBERATION = 10
	DAYLENGTH = 10

	attr_reader :players, :time, :must_receive_list # For debugging

	def initialize(userlist)
		@scenario = Scenario.new(userlist)
		puts @scenario.inspect
		@players = @scenario.playerlist
		ApiSend.players_receive_roles @players
	end

	def reset!
		@scenario = nil
		@players = nil
		@time = nil
	end

	def night?
		@time == :night
	end

	def voting_time?
		@time == :voting
	end

	def mustlist
		@players.clone.delete_if { |p| p.priority == 0 }
	end

	def night
		return if game_over
		@players.each(&:clean)
		@time = :night
		@must_receive_list = mustlist
		ApiSend.night_begins(NIGHTLENGTH)
		sleep NIGHTLENGTH
		# return if aborted
		return if @time.nil?
		day if night?
	end

	def kill(player)
		ApiSend.user_died player
		@players.delete player
	end

	def determine_deaths_and_results
		puts "determining deaths and results for night actions"
		judge = Adjudicator.new(@players)

		ApiSend.give_results(judge.results)
		judge.deaths.each { |x| kill(x) }
		ApiSend.nobody_died if judge.deaths == []
	end

	def determine_majority
		(@players.count + @players.count { |p| p.action == :mayor }) / 2
	end

	def day
		puts "starting day function"
		puts "@time = :day"
		@time = :day

		determine_deaths_and_results
		puts "return if game_over"
		return if game_over
		ApiSend.day_begins @players
		ApiSend.deliberation DELIBERATION
		puts "sleep DELIBERATION"
		sleep DELIBERATION
		puts "return if @time.nil?"
		return if @time.nil?

		puts "@players.each(&:clean)"
		@players.each(&:clean)

		puts "@time = :voting"
		@time = :voting
		ApiSend.voting_starts DAYLENGTH

		puts "sleep DAYLENGTH"
		sleep DAYLENGTH
		return if @time.nil?
		puts "time is not nil"
		return if night?
		puts "it is not night"
		puts "most_votes = @players.max_by(&:votes_for).votes_for"
		most_votes = @players.max_by(&:votes_for).votes_for
		puts "most_votes = #{most_votes}"
		most_voted_for = @players.select{|p| p.votes_for == most_votes}
		puts "most_voted_for = #{most_voted_for}"
		puts "#{most_voted_for.count}"
		if most_voted_for.count > 1
			ApiSend.tie_in_vote most_voted_for 
		else
			kill most_voted_for.first
		end
		night
	end

	def action_submission(user, action_name, target_name)
		player = determine_player(user.name)
		return unless player
		unless player.action.does(action_name)
			ApiSend.sent_wrong_action(user)
			return
		end
		target = determine_player(target_name)
		unless target
			ApiSend.target_not_in_game
			return
		end
		if player.action.eql? :mafia
			@players.select{ |p| p.action.eql? :mafia }.each do |mafiaman|
				mafiaman.target = target
				@must_receive_list.delete mafiaman
			end
		else
			player.target = target
		end
		@must_receive_list.delete player
		
		day if all_actions_received?
	end

	def vote_message(user, target_name)
		puts "processing vote message"
		player = determine_player(user.name)
		return unless player
		target = determine_player(target_name)
		return unless target
		puts "Both player and target are in the game"
		player.voting_for = target
		if player.mayor? then target.votes_for += 2 else target.votes_for += 1 end
		ApiSend.vote_sent player, target
		# Check if there's a majority. Array#select does not modify the original array (thank god)
		votes_on_target = @players.select{ |p| p.voting_for == target}.inject(0) do |tally, voter|
			if voter.mayor? then tally + 2 else tally + 1 end
		end
		if votes_on_target > determine_majority
			kill target
			night
		end
	end

	def idle_submission(user)
		@must_receive_list.delete(determine_player(user.name))
		day if all_actions_received?
	end

	def all_actions_received?
		@must_receive_list.size == 0
	end

	def determine_player(username)
		puts "Determine the player attached to the username #{username}"
		puts @players.detect { |p| p.user.name.downcase == username.downcase }
		@players.detect { |p| p.user.name.downcase == username.downcase }
	end

	def game_over
		if @players.length == @players.count { |p| p.mafia? }
			ApiSend.mafia_wins @players
			reset!
			return true
		elsif @players.length == @players.count { |p| p.village? }
			ApiSend.village_wins @players
			reset!
			return true
		end
		false
	end
end