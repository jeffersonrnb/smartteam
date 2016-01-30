#!/home/pi/.rvm/rubies/ruby-2.3.0/bin
puts "Content-type: text/html"

require 'cgi'
require 'rubygems'
require_relative 'CittaMobiRequester'
require_relative 'DisplayDaemon'
require_relative 'DictionaryHelper'
require 'rpi_gpio'

RPi::GPIO.set_numbering :board

class ExecuterDaemon
    @@buttons = {"9717-10" => 13, "9701-10" => 15}
    @@startButton = 16
    @@cancelButton = 18
    @@wheelchairButton = 22
    @@requestsBus = {}

    def run
        while true
            start = false
            while !start
                result = `python ButtonCheck.py #{@@startButton}`
                resultWheelchair = `python ButtonCheck.py #{@@wheelchairButton}`
                if result.to_i == 1
                    self.start(false)
                    start = true
                    break
                elsif resultWheelchair.to_i == 1
                    self.start(true)
                    start = true
                    break
                end

                sleep 0.3
            end
        end
    end

    def start (wheelchairNeeds)
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
                    if self.confirm(key)
                        if CittaMobiRequester.new.getRouteHasVehicles(key, wheelchairNeeds)
                            @@requestsBus[key] = {"key" => key, "wheelchairNeeds" => wheelchairNeeds}
                            `espeak -vpt -g 4 \"Seu pedido foi feito, o próximo ônibus irá parar para você\"`
                        elsif wheelchairNeeds
                            `espeak -vpt -g 4 \"Não foi possível achar um ônibus adaptado próximo deste ponto para essa linha\"`
                        else
                            `espeak -vpt -g 4 \"Não foi possível achar um ônibus próximo deste ponto para essa linha\"`
                        end
                    else
                       `espeak -vpt -g 4 \"Requisição cancelada com sucesso\"`
                    end
                    choice = true

                    break
                end
            end

            sleep 0.3
        end

        display = DisplayDaemon.new
        display.update(@@requestsBus)
        display.read_active_requests
    end

    def confirm(key)
        key = DictionaryHelper.new.byExtense(key)
        `espeak -vpt -g 4 \"Confirme o pedido do ônibus da linha #{key}\"`
        `espeak -vpt -g 4 \"ou cancele caso necessário\"`
        confirmacao = ''
        while true
            resultConfirm = `python ButtonCheck.py #{@@startButton}`
            resultCancel = `python ButtonCheck.py #{@@cancelButton}`

            if resultCancel.to_i == 1
                confirmacao = false
                break
            elsif resultConfirm.to_i == 1
                confirmacao = true
                break
            end
            sleep 0.3
        end
        confirmacao
    end

    def readServices
        servicesString = CittaMobiRequester.new.getServicesNames
        executeString = "Olá, listarei para você as linhas disponíveis nesse ponto: "
        `espeak -vpt -g 4 \"#{executeString}\"`
        servicesString.each do |string|
            string = DictionaryHelper.new.byExtense(string)
            `espeak -vpt -g 4 \"#{string}\"`
            sleep 0.3
        end
    end
end

ExecuterDaemon.new.run
