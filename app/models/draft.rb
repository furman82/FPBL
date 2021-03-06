# Describes a selection in the rookie draft
class Draft < ActiveRecord::Base
  self.primary_keys = :year, :round, :selection

  attr_accessible :year, :round, :selection, :franchise_id_current,
                  :franchise_id_original, :player_id

  belongs_to :player,  foreign_key: [:year, :player_id]
  belongs_to :team,  foreign_key: [:year, :franchise_id_current]

  def self.rounds(year)
    where(year: year).uniq.pluck(:round)
  end

  def self.selections_by_round(year, round)
    where(year: year, round: round).uniq.pluck(:selection)
  end

  def self.draft_selection(year, round, selection)
    where(year: year, round: round, selection: selection).first
  end

  def self.draft_selection_by_original_owner(year, round, franchise_id_original)
    where(year: year, round: round, franchise_id_original: franchise_id_original).first
  end

  def self.draft_day
    # Find the third saturday of January
    if Date.today.month < 12
      draft = Date.new(Date.today.year, 1, 1) + 2.weeks
    else
      draft = Date.new(Date.today.year.next, 1, 1) + 2.weeks
    end

    until draft.saturday? do draft = draft.next end

    draft
  end

  def self.find(player_id)
    where(player_id: player_id).first
  end
end
