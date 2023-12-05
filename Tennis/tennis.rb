module Tennis
  class Player
    attr_reader :name, :score
    
    def initialize(name, score=Score.new)
      @name, @score = name, score
    end
    
    def score!
      @score += 1
    end
  end
  
  class Score < SimpleDelegator
    WORDS = ["Love", "Fifteen", "Thirty", "Forty"].freeze

    def initialize(value=0)
      super value.to_i
    end
    
    def +(other)
      self.class.new super(other)
    end
    
    def to_s
      WORDS[self]
    end
  end
  
  class Game
    TEXT = {
      win: "Win for %s",
      adv: "Advantage %s",
      deu: "Deuce",
      all: "All",
      sco: "%s-%s",
    }
    
    def initialize(name1, name2)
      @player1 = Player.new(name1)
      @player2 = Player.new(name2)
      @players = [@player1, @player2]
    end
    
    def won_point(name)
      player_by_name(name).score!
    end
    
    def score
      return TEXT[:deu] if deuce?
      return TEXT[:adv] % leader.name if advantage?
      return TEXT[:win] % leader.name if won?
      return TEXT[:sco] % player_scores.push(TEXT[:all]).uniq[0,2]
    end

    private

    def deuce?
      score_distance == 0 && all_players_three_points?
    end
  
    def advantage?
      score_distance == 1 && any_player_four_points?
    end
  
    def won?
      score_distance >= 2 && any_player_four_points?
    end

    def score_distance
      player_scores.reduce(:-).abs
    end
    
    def any_player_four_points?
      player_scores.any? { |x| x >= 4 }
    end

    def all_players_three_points?
      player_scores.all? { |x| x >= 3 }
    end
    
    def player_scores
      @players.map(&:score)
    end

    def player_by_name(name)
      @players.detect { |p| p.name == name }
    end

    def leader
      @players.max_by(&:score)
    end
  end
end
