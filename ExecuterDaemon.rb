#!/home/pi/.rvm/rubies/ruby-2.3.0/bin
puts "Content-type: text/html"

require 'cgi'
require 'rubygems'
require_relative 'CittaMobiRequester'
require_relative 'DisplayDaemon'
require 'rpi_gpio'

RPi::GPIO.set_numbering :board

class ExecuterDaemon
    @@buttons = {"9717-10" => 13, "9701-10" => 15}
    @@requestsBus = {}

    def run
        self.readServices

        # loop on all the pins, when the button pin has
        # 0 value (button is pressed) the led will turn
        # on.
        choice = false
        while !choice
          @@buttons.each do |key, button|
            puts key
            puts button
            result = `python ButtonCheck.py #{button}`
            puts result
            if result.to_i == 1
                @@requestsBus[key] = key
                `espeak -vpt -g 4 \"Seu pedido foi feito, o próximo ônibus irá parar para você\"`
                choice = true
                break
              end
          end
          sleep 0.3
        end

        display = DisplayDaemon.new
	display.update(@@requestsBus)
	puts display.display_html()
    end

    def readServices
        servicesString = CittaMobiRequester.new.getServicesNames
        executeString = "Olá, listarei para você as linhas disponíveis nesse ponto: "
        `espeak -vpt -g 4 \"#{executeString}\"`
	servicesString.each do |string|
            `espeak -vpt -g 4 \"#{string}\"`
       	    sleep 0.3
	 end
    end
end

ExecuterDaemon.new.run
