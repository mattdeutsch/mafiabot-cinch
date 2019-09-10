require "./player.rb"

class Scenario
	attr_reader :roles
	attr_reader :playerlist

	GAMETYPES = [
		[type: :none, 					 roles: []],
		[type: :trivial, 				 roles: [:vanilla]],
		[type: :mafia_vanilla,	 roles: [:mafia, :vanilla]],
		[type: :mafia_2vanilla,  roles: [:mafia, :vanilla, :vanilla]],
		[type: :mafia_team_test, roles: [:mafia, :mafia, :vanilla, :inspector]],
	]
	
	def initialize(userlist)
		gamesize = userlist.size
		gametype = GAMETYPES[gamesize].sample
		@type = gametype[:type] # used for debugging
		@roles = gametype[:roles]
		ApiSend.game_starting @roles
		@playerlist = assign_roles_randomly(userlist)
	end

	def assign_roles_randomly(list_of_users)
		role_list = @roles.shuffle
		list_of_users.map do |user|
			Player.new(user, role_list.pop)
		end
	end

end