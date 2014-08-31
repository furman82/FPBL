# Model for a player
class Player < ActiveRecord::Base
  self.primary_keys = :year, :player_id

  attr_accessible :player_id, :year, :dmb_name, :first_name, :last_name,
                  :position, :active

  has_many :contracts, primary_key: :player_id
  has_many :teams,  foreign_key: [:year, :franchise_id], through: :contracts

  def self.player_id_by_dmb_name(year, dmb_name)
    Player.where(year: year, dmb_name: dmb_name).pluck(:player_id).first
  end

  # ['SP', 'MR', 'CL', 'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF', 'DH']
  def self.position_name(position)
    case position.upcase
    when 'SP'
      'Starting Pitcher'
    when 'MR'
      'Relief Pitcher'
    when 'CL'
      'Closer'
    when 'C'
      'Catcher'
    when '1B'
      'First Baseman'
    when '2B'
      'Second Baseman'
    when 'SS'
      'Shortstop'
    when '3B'
      'Third Baseman'
    when 'LF'
      'Left Fielder'
    when 'CF'
      'Center Fielder'
    when 'RF'
      'Right Fielder'
    when 'DH'
      'Designated Hitter'
    else
      'Unknown Position'
    end
  end

  def name
    first_name + ' ' + last_name
  end

  def pitcher?
    pitchers = %w(SP MR CL)

    pitchers.include?(position.upcase)
  end

  def current_contract(year, franchise_id)
    contracts.where("year >= #{year} and franchise_id = #{franchise_id}")
  end
end
