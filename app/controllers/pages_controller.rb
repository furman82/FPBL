# Controller to pass values to the view
class PagesController < ApplicationController
  def index
    @year = Team.last.year

    if Time.now.hour < 18
      @date = Date.today - 1.day
    else
      @date = Date.today
    end
    @games = Schedule.all_games_for_day(@date)

    @leagues = Standing.leagues(@year).sort
    @divisions = @leagues.each_with_object({}) do |league, hash|
      hash[league] = Standing.divisions_by_league(@year, league).sort
    end
    @records = Standing.divisions(@year).each_with_object({}) do |division, hash|
      hash[division] = Standing.records_by_divisions(@year, division).sort_by do
        |record| - record.wins
      end
    end

    @franchise_id = nil
    @transaction_type = nil
    @from_date = DateTime.now - 1.week
    @to_date = DateTime.now
  end

  helper StandingsHelper
  def standings
    @year = params[:year].nil? ? Team.last.year.to_s : params[:year]
    @years = Team.all.map { |season| season.year }.uniq.reverse

    @leagues = Standing.leagues(@year).sort
    @divisions = @leagues.each_with_object({}) do |league, hash|
      hash[league] = Standing.divisions_by_league(@year, league).sort
    end
    @records = Standing.divisions(@year).each_with_object({}) do |division, hash|
      hash[division] = Standing.records_by_divisions(@year, division).sort_by do
        |record| - record.wins
      end
    end
  end

  def calendar
    month = params[:month].nil? ? Date.today.month : params[:month].to_i
    year = params[:year].nil? ? Date.today.year : params[:year].to_i

    @date = Date.new(year, month, 1)
    @games = Schedule.all_games_for_month(@date)
  end

  def transaction
    unless params[:search].nil?
      @franchise_id = params[:search][:franchise_id] unless
        params[:search][:franchise_id].to_s.strip.length == 0
      @transaction_type = params[:search][:transaction_type] unless
        params[:search][:transaction_type].to_s.strip.length == 0
      @from_date = params[:search][:from_date] unless
        params[:search][:from_date].to_s.strip.length == 0
      @to_date = params[:search][:to_date] unless
        params[:search][:to_date].to_s.strip.length == 0
    end

    @franchise_id ||= nil
    @transaction_type ||= nil
    @from_date ||= Transaction.maximum(:processed_at).prev_month.beginning_of_month
      .to_date.to_formatted_s(:long)
    @to_date ||= Transaction.maximum(:processed_at).to_date.to_formatted_s(:long)
  end

  def rules
    @draft = Draft.draft_day
  end

  def rookies
    @rookies = Player.rookies(Team.last.year)
  end

  def freeagents
    @players = Player.free_agents(Team.last.year)
  end
end
