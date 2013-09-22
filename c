require './window'
require './client'

client = Client.new
window = Window.new

window.output = client.input
client.output = window.input

Thread.start do
  begin
    client.start('localhost', 8134)
  rescue Interrupt => e
    puts
    puts 'Client stopped.'
  end
end

window.start
