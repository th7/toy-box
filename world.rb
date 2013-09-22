#adds/removes objects, holds canonical state

# require 'drb/drb'
require './deep_merge'

class World
  attr_reader :input
  attr_writer :output

  def initialize
    @input = []
    @objects = {}
    @last_sync = Time.now
  end

  def start
    raise 'Must assign output before starting' unless @output
    genesis
  end

  private

  def genesis
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

    if Time.now - @last_sync > 0.1
      @last_sync = Time.now
      @output << @objects
    end
  end

  def new_id
    @last_id += 1
  end
end
