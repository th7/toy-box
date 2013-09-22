#moves randomly

require 'uuid'
require './deep_merge'

class Entity
  attr_reader :input
  attr_writer :output

  def initialize
    @input = []
    @id = UUID.new.generate
    entity = {
      :id => @id,
      :type => 3,
      :img => 1,
      :x => 0,
      :y => 0
    }
    @objects = {@id => entity}
    @last_sync = Time.now
    @player_id = nil
  end

  def start
    raise 'Must assign output before starting' unless @output
    @output << @objects
    think
  end

  private

  def think
    Thread.start do
      dt = 0.0
      loop do
        start = Time.now

        update(dt)

        dt = Time.now - start
        to_sleep = 0.017 - dt
        sleep to_sleep if to_sleep > 0
      end
    end
  end

  def update(dt)
    until input.empty?
      @objects = @objects.deep_merge(@input.shift)
    end

    entity = @objects[@id]
    unless @player_id
      player = nil
      @objects.each do |k, o|
        player = o if o[:type] == 2
      end
      @player_id = player[:id] if player
    end

    if @player_id
      chase(entity, @player_id)
    else
      move_random(entity)
    end

    if Time.now - @last_sync > 0.1
      @last_sync = Time.now
      @output << {@id => entity}
    end
  end

  def chase(entity, target_id)
    player = @objects[target_id]
    if player[:x] > entity[:x]
      entity[:x] += 10
    else
      entity[:x] -= 10
    end

    if player[:y] > entity[:y]
      entity[:y] += 10
    else
      entity[:y] -= 10
    end
  end

  def move_random(entity)
    new_x = entity[:x] + (rand(3) - 1) * 10
    entity[:x] = new_x if new_x > 0

    new_y = entity[:y] + (rand(3) - 1) * 10
    entity[:y] = new_y if new_y > 0
  end

  def new_id
    @last_id += 1
  end
end
