require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid
  end

  def generate_grid(grid_size = 10)
    grid = []
    grid_size.times { grid << ('A'..'Z').to_a.sample }
    grid
  end

  def score
    @end_time = Time.now
    attempt = params[:word]
    @letters = params[:letters]
    # @start_time = Time.new(params[:start_time])
    # total_time = (@end_time - @start_time) / 1000
    total_time = params[:time].to_i
    url = "https://wagon-dictionary.herokuapp.com/#{attempt.downcase}"
    attempt_serialized = open(url).read
    the_attempt = JSON.parse(attempt_serialized)
    @result = validation(the_attempt, total_time)
  end

  def validation(atempt, total_time)
    cont = 0
    if atempt['found']
      atempt['word'].chars.each { |l| cont += 1 unless @letters.include?(l.upcase) }
      cont.zero? ? overuse(atempt, total_time) : { message: 'not in the grid', score: 0, time: total_time }
    else
      { message: 'not an english word', score: 0, time: total_time }
    end
  end

  def overuse(attempt, total_time)
    w_aray = attempt['word'].chars
    grid = @letters
    grid.split.each { |l| w_aray.delete_at(w_aray.index(l.downcase)) if w_aray.include?(l.downcase) }
    w_aray == [] ? score_calc(attempt, total_time) : { message: 'not in the grid', score: 0, time: total_time }
  end

  def score_calc(attempt, total_time)
    the_score = 0
    the_score += attempt['length'] * 10
    the_score += 10 - total_time
    { message: 'well done', score: the_score, time: total_time }
  end
end
