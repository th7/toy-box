#displays game, passes commands

require 'thread'
require 'gosu'
require 'uuid'
require './resource'
require './deep_merge'

class Window < Gosu::Window
  attr_reader :input
  attr_writer :output

  def width
    1280
  end

  def height
    960
  end

  def initialize
    super(width, height, false)
    self.caption = 'Toy Box'

    @input = Queue.new
    @id = UUID.new.generate
    player = {
      :id => @id,
      :type => 2,
      :img => 1,
      :x => 0,
      :y => 0
    }
    @objects = {@id => player}
    @images = {}
    @last_sync = Time.now
  end

  def start
    raise 'Must assign output before starting' unless @output
    @output << @objects

    Thread.start do
      loop do
        updated = @input.shift
        updated.delete(@id)
        @objects = @objects.deep_merge(updated)
      end
    end

    self.show

  end

  def update
    player = @objects[@id]

    if button_down? Gosu::KbLeft then
      changes = true
      player[:x] -= 10
    end
    if button_down? Gosu::KbRight then
      changes = true
      player[:x] += 10
    end
    if button_down? Gosu::KbUp then
      changes = true
      player[:y] -= 10
    end
    if button_down? Gosu::KbDown then
      changes = true
      player[:y] += 10
    end

    if changes && Time.now - @last_sync > 0.1
      @last_sync = Time.now
      @output << {@id => player}
    end
  end

  def draw
    @objects.each do |k, o|
      i = @images[o[:id]]
      if i
        i.draw(o[:x], o[:y], 0)
      elsif o[:img]
        @images[o[:id]] = Gosu::Image.new(self, RES[o[:img]], false)
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end
