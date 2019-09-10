require "cinch"

class ApiSend
	@channel = nil
	class << self
		attr_accessor :channel

		def give_results(resultlist)
			resultlist.each do |result|
				tell result[:user], result[:message]
			end
		end

		def action_sent(target, user)
			tell user.user, "You are now targeting #{target.user.name}"
		end

		def vote_sent(sender, target)
			tell @channel, "#{bold(sender.user.name)} has voted for #{bold(target.user.name)}"
		end

		def tie_in_vote(list_of_tiees)
			tell @channel, "There has been a tie in the vote between #{display list_of_tiees}. Nobody will be lynched."
		end

		def voting_starts(votingtime)
			tell @channel, "It is time to vote! Vote for who you believe to be mafia. The player with the most votes will be lynched."
			tell @channel, "You have #{votingtime} seconds to vote."
		end

		def deliberation(d_time)
			tell @channel, "There will be #{d_time} seconds of deliberation. Use this time to talk amongst yourselves."
		end

		def day_begins(playerlist)
			tell @channel, "The day begins. Players still alive are: #{display playerlist}"
		end

		def game_in_progress(channel)
			tell channel, "There is already a game in progress in #{@channel.name}"
		end

		def nobody_died
			tell @channel, "Nobody died."
		end

		def user_died(player)
			tell @channel, "#{bold(player.user.name)} (#{player.action.name}) has been killed. Sucks to be #{player.user.name}!"
		end

		def give_results(result_list)
			return if result_list.nil?
			# TODO
		end

		def sent_wrong_action(user)
			tell user, "That's not your action. (Was it a typo?)"
		end

		def night_begins(nightlength)
			tell @channel, "The night begins! The night will last #{nightlength} seconds."
		end

		def village_wins(playerlist)
			tell @channel, "The village (#{display playerlist}) wins! gg etc"
		end

		def mafia_wins(playerlist)
			tell @channel, "The mafia (#{display playerlist}) wins! gg etc"
		end

		def game_starting(roles)
			# display roles
			tell @channel, "The roles are: #{display_roles(roles)}"
		end

		def players_receive_roles(playerlist)
			playerlist.each do |player|
				tell player.user, "You are a #{player.action.name}."
			end
			playerlist.select{ |p| p.mafia? }.each do |mafiaman|
				tell mafiaman.user, "You are part of the mafia. Your team is: #{display playerlist.select{ |p| p.mafia? }}"
			end
		end

		def signups_over
			tell @channel, "Signups over."
		end

		def mafia_game_started(join_length)
			tell @channel, "A mafia game has been started in #{@channel.name}. Type \"!join\" to join! You have #{join_length} seconds to join."
		end

		def user_has_joined(user)
			tell user, "You have joined the game."
			tell @channel, "#{bold(user.name)} has joined the game!"
		end

		def not_enough_players
			tell @channel, "Game ended. Not enough players."
		end

		def signups_over
			tell @channel, "Signups completed."
		end


		def tell(target, message)
			message = colored message if target.instance_of? Cinch::Channel
			# "Cute" way to only send notices to users...
			target.send message, target.instance_of?(Cinch::User)
		end

		def colored(message)
			Cinch::Formatting.format(:blue, message)
		end

		def bold(message)
			Cinch::Formatting.format(:bold, message)
		end

		def display(playerlist)
			playerlist.map { |p| p.user.name }.join(", ")
		end

		def display_roles(roles)
			roles.map { |r| bold(r.to_s) }.join(", ")
		end
	end
end