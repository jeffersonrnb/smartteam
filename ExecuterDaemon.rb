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
        `espeak -vpt -g 4 \"Escolha uma linha para pedir seu ponto através dos botões acessíveis\"`

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
                if CittaMobiRequester.new.getRouteHasVehicles(key)
                    @@requestsBus[key] = key
                    `espeak -vpt -g 4 \"Seu pedido foi feito, o próximo ônibus irá parar para você\"`
                else
                    `espeak -vpt -g 4 \"Não foi possível achar um ônibus próximo deste ponto para essa linha\"`
                end
                choice = true

                break
              end
          end
          sleep 0.3
        end

        display = DisplayDaemon.new
        display.update(@@requestsBus)
        puts display.generate_html()
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
