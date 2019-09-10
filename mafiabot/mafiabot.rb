require "cinch"
require "./scenario.rb"
require "./cycles_night_and_day.rb"
require "./signups_module.rb"

class MafiaBot
	# The base class of the plugin.
	include Cinch::Plugin
	include SignupsModule
	
	match(/mafia\Z/i,  method: :mafia_message)
	match(/join\Z/i,   method: :join_message)
	match(/mafia(stop|end)\Z/i, method: :stop_message)
	match(/debug\Z/i, method: :debug_message)
	match(/(kill) (.+)/i, method: :target_message, use_prefix: false)
	match(/vote (.+)/i, method: :vote_message)
	match(/idle\Z/i, method: :idle_message)

	def initialize(*)
		super
		@state = :nogame
	end

	def mafia_message(m)
		# Checking whether the message was sent from a user or a channel should be
		# determined here.
		return if m.channel.nil?
		unless @state == :nogame
			ApiSend.game_in_progress(m.channel)
			return nil
		end
		ApiSend.channel = m.channel
		@state = :newgame
		@users = get_signups(m.channel, m.user, 10)
		@state = :ingame
		if @users.nil?
			@state = :nogame
			return
		end
		@cycler = CyclesNightAndDay.new(@users)
		@cycler.night
		@state = :nogame
	end

	def join_message(m)
		return unless @state == :newgame
		add m.user
	end

	def stop_message(m, _)
		# return unless better_than_voice(m) -- doesn't work right now
		return if @state == :nogame
		reset_signups! if @state == :newgame
		@cycler.reset! unless @cycler.nil?
		@state = :nogame
		ApiSend.tell m.channel, "Game aborted."
	end

	def debug_message(m)
		#return unless m.channel.opped? m.user
		ApiSend.tell m.channel, "Debug message:"
		ApiSend.tell m.channel, @signups.inspect unless @signups.nil?
		ApiSend.tell m.channel, @users.inspect unless @users.nil?
		ApiSend.tell m.channel, "Players: #{@cycler.players.inspect}" unless @cycler.nil?
		ApiSend.tell m.channel, @cycler.time.inspect unless @cycler.nil?
		ApiSend.tell m.channel, "must_receive_list: #{@cycler.must_receive_list}" unless @cycler.nil?
	end

	def target_message(m, action_name, target_name)
		# Could do this with regex, cba:
		return unless (m.message.chr == "!" || m.channel.nil?)
		# TODO?: Take action name to action here? Probably not.
		return if @cycler.nil?
		return unless @cycler.night?
		@cycler.action_submission(m.user, action_name, target_name)
	end

	def idle_message(m)
		return if @cycler.nil?
		return unless @cycler.night?
		@cycler.idle_submission(m.user)
	end

	def vote_message(m, target_name)
		return unless (m.message.chr == "!" || m.channel.nil? )
		puts "vote message received"
		return if @cycler.nil?
		puts "cycler is not nil"
		return unless @cycler.voting_time?
		puts "cycler is at voting time"
		@cycler.vote_message(m.user, target_name)
	end

	private
	def better_than_voice(m)
		# TODO: fix this.
		(m.channel.opped?(m.user) ||
		m.channel.half_opped?(m.user) ||
		m.channel.voiced?(m.user))
	end
end