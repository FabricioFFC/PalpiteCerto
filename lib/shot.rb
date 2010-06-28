class Control < ActiveRecord::Base
end

class Game < ActiveRecord::Base
end

class Shot
  
  def twitter_not_exists?(twitter)
    size = Game.find_by_sql(["select twitter from games where twitter = ?", twitter]).size
    size == 0
  end
  
  def remove_zero_from_scores(scores)
    unless scores.nil? 
      if scores.length == 2 and scores[0..0] == "0" then
        scores = scores[1..1]
      else
        scores
      end
    end
  end

  def discover_scores(shot)
    result = shot[/#bra(.*?)$/, 1].upcase
    position_of_X = result.index('X')
    brazil_scores = remove_zero_from_scores(result[1...position_of_X][/\d{1,2}/])
    adversary_scores = remove_zero_from_scores(result[(position_of_X+1)..result.length][/\d{1,2}/])
    "#{brazil_scores}X#{adversary_scores}"
  end
  
  def discover_result(scores)
    brazil_scores = scores[0..0]
    adversary_scores = scores[2..2]
    if brazil_scores == adversary_scores then
      result = "e"
    else
      if brazil_scores.to_i > adversary_scores.to_i then  
        result = "v"
      else
        result = "d"
      end
    end
    result
  end

  def add_new_shot(shot)
    scores = discover_scores(shot.text)
    result = discover_result(scores)
    match = Control.last(:select => "match").match
    Game.create!(
      :twitter => shot.from_user,
      :url_avatar => shot.profile_image_url,
      :shot => shot.text,
      :scores => scores,
      :result => result,
      :points => 0,
      :shot_time => shot.created_at,
      :match => match
    )
  end
  
  def shot_not_exists?(shot, twitter)
    size = Game.find_by_sql(["select twitter from games where shot = ? and twitter = ?", shot, twitter])
    size == 0
  end
  
  def is_new?(shot)
    twitter_not_exists?(shot.from_user) || shot_not_exists?(shot.text, shot.from_user)      
  end

  def process_control(result)    
    tweet = result.text
    if tweet.include?("finished")
      match = Control.last
      match.finished = true
      match.save
    end
    if tweet.include?("apos a")
      scores = tweet[/por (.*?)$/, 1][0..2]
      result = tweet[/apos a (.*?)$/, 1][0..0]
      match = "braX#{tweet[/contra #(.*?)$/, 1][0..2]}"
      process_shots(scores,result,match)      
    end
    if tweet.include?("já estão")
      adversary = tweet[/contra #(.*?)$/, 1]
      Control.create!(:match => "braX#{adversary}", :finished => false) 
    end
  end
  
  def shots_finished?
    Control.last(:select => "finished").finished
  end

  def admin_shots
    search = Twitter::Search.new.from('palpite_certo')
    search.per_page(1)
    search.each  do |result| 
      process_control(result)
    end
  end
  
  def a_valid_shot?(result)
    result.text.include?("#bra") and !shots_finished? and is_new?(result) and not_included_previous_adversaries?(result)
  end
  
  def not_included_previous_adversaries?(result)
    previous_matches = Control.all(:conditions => {:finished => true})
    previous_matches.each do |match|
      previous_adversary = match.match[/braX(.*?)$/, 1].upcase
      return false if result.text.upcase.include?(previous_adversary)
    end
  end

  def update_shots
    search = Twitter::Search.new.containing('#palpitecerto')
    search.per_page(1000)
    search.reverse_each do |result| 
      if a_valid_shot?(result)
        add_new_shot(result)
      end
    end
  end

  def process_shots(scores,result,match)
    @games = Game.find_all_by_match(match)
    @games.each do |game|
      if game.scores == scores then
          game.points = 15
          game.save
      else
        if game.result == result then
          game.points = 10
          game.save
        end
      end
    end
  end
end
