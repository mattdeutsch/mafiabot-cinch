require "./priority.rb"
require "./action.rb"
require "./api_send.rb"

class Player
	include Priority

	MAFIAROLES = [:mafia]
	VILLAGEROLES = [:vanilla, :bodyguard, :hooker, :inspector, :mayor]

	attr_accessor :priority
	attr_accessor :action
	attr_accessor :user
	attr_accessor :target
	attr_accessor :voting_for
	attr_accessor :votes_for

	def initialize(user, action)
		# Expects a symbol for action and a Cinch::User for user.
		@user = user
		@action = Action.new(action, self)
		@priority = priority_calc(action) # should be in Action?
		@team = if MAFIAROLES.include?(action) then :mafia else :village end
		@target = nil # should be in Action?
		@voting_for = nil
		@votes_for = 0
		@conditions = []
	end

	def target=(new_player)
		@target = new_player
		return nil if new_player.nil?
		ApiSend.action_sent(new_player, self)
	end

	def clean
		@target = nil
		@voting_for = nil
		@votes_for = 0
		@conditions = []
	end

	def mafia?
		@team == :mafia
	end

	def village?
		@team == :village
	end

	def mayor?
		@action == :mayor
	end

end