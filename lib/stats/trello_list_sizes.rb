require 'trello'

class Stats::TrelloListSizes
  include Trello
  include Trello::Authorization

  BEGINNING_OF_TIME = 0
  ONE_DAY_IN_SECONDS = 60 * 60 * 24

  def initialize(oauth_public_key, oauth_secret, oauth_key, board_id)
    Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
    OAuthPolicy.consumer_credential = OAuthCredential.new oauth_public_key, oauth_secret
    OAuthPolicy.token = OAuthCredential.new oauth_key, nil

    @board = Board.find board_id
  end

  def measurements(last_run)
    last_run_time = Time.at(last_run.recall(@board.id) || BEGINNING_OF_TIME).utc
    time = Time.now.utc

    return [] if time - last_run_time < ONE_DAY_IN_SECONDS

    last_run.remember(@board.id, time.to_f)
    @board.lists.map do |list|
      Stats::Stat.new('trello_list_size', list.id, list.name, time, list.cards.size)
    end
  end
end
