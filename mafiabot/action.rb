class Action
	attr_accessor :owners
	attr_accessor :symbol

	def initialize(symbol, player)
		@owners = [player]
		@symbol = symbol
	end

	def does(string)
		case string
		when "kill"
			true if @symbol == :mafia || @symbol == :werewolf
		end
	end

	def eql?(action)
		if action.respond_to? :symbol then @symbol == action.symbol else @symbol == action end
	end

	def name
		@symbol.to_s
	end
end