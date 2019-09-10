module Priority
	def priority_calc(action)
		case action
		when :vanilla
			0
		when :inspector
			10
		when :mafia
			100
		when :bodyguard
			110
		when :hooker
			200
		else
			raise ArgumentError
		end
	end
end