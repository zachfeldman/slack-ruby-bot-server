require_relative 'methods.rb'
require 'active_record'
require './app/models/team.rb'

class Team < ActiveRecord::Base

  include Methods
  include TeamAppMethods

  def self.total_count
    self.count
  end

  def token
    bot_token
  end

  def self.purge!
    # destroy teams inactive for two weeks
    Team.where(active: false).where('updated_at <= ?', 2.weeks.ago).each do |team|
      puts "Destroying #{team}, inactive since #{team.updated_at}, over two weeks ago."
      team.destroy
    end
  end
end
