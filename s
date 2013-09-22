require './world'
require './server'

server = Server.new
world = World.new

world.output = server.input
server.output = world.input

world.start

begin
  server.start(8134)
rescue Interrupt => e
  puts
  puts 'Server stopped.'
end
