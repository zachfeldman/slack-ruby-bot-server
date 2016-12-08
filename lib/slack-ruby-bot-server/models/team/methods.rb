module Methods
  extend ActiveSupport::Concern

  included do

    attr_accessor :server # server at runtime

    SORT_ORDERS = ['created_at', '-created_at', 'updated_at', '-updated_at'].freeze

    scope :active, -> { where(active: true) }

    validates_uniqueness_of :bot_token, message: 'has already been used'
    validates_presence_of :bot_token
    validates_presence_of :team_id

    def deactivate!
      update_attributes!(active: false)
    end

    def activate!(bot_token)
      update_attributes!(active: true, bot_token: bot_token)
    end

    def to_s
      {
        name: name,
        domain: domain,
        id: team_id
      }.map do |k, v|
        "#{k}=#{v}" if v
      end.compact.join(', ')
    end

    def ping!
      client = Slack::Web::Client.new(token: bot_token)
      auth = client.auth_test
      {
        auth: auth,
        presence: client.users_getPresence(user: auth['user_id'])
      }
    end

    def self.find_or_create_from_env!
      token = ENV['SLACK_API_TOKEN']
      return unless token
      team = Team.where(bot_token: token).first
      team ||= Team.new(bot_token: token)
      info = Slack::Web::Client.new(token: token).team_info
      team.team_id = info['team']['id']
      team.name = info['team']['name']
      team.domain = info['team']['domain']
      team.save!
      team
    end
  end
end
