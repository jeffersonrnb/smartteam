require_relative 'CittaMobiRequester'
require_relative 'DictionaryHelper'
require 'net/sftp'

class DisplayDaemon
    @@arrivalArray = {}

    def run

    end

    def update (requestArray)
        requestArray.each do |key, request|
            if request["wheelchairNeeds"]
                predictions = CittaMobiRequester.new.getPredictionsByTimeWheelchair
            else
                predictions = CittaMobiRequester.new.getPredictionsByTime
            end

            if(predictions.has_key?(key))
                @@arrivalArray[key] = predictions[key]
            end
        end
        if !@@arrivalArray.empty?
            self.display_html
        end
    end

    def generate_html()
        string = "<html><head><title>Alerta ao motorista e cobrador</title></head><body>"
        @@arrivalArray.each do |key, service|
            string+= "<div>"
            string+= "<img style=\"width: 180px; height: 140px; position: relative; margin-top: 40px;\" src=\"#{service['wheelchairNeeds']}.jpeg\">"
            string+= "<h1 style=\"font-size: 120px; position: relative; margin-left: 200px; margin-top: -140px;"
            if service["wheelchairNeeds"]
               string+=  "color: #4E6CE6;"
            end
            string+= "\">#{service['routeMnemonic']}:</h1>"
            string+= "</div>"
        end
	   string += "</body></html>"
	   string
    end

    def generate_file()
        File.open("index.html", 'w') do |f|
            f.write(generate_html())
        end
    end

    def send()
        #Net::SFTP.start('host', 'username', :password => 'password') do |sftp|
        Net::SFTP.start('192.168.0.105', 'otimauser1', :password => 'lyx082') do |sftp|
            # upload a file or directory to the remote host
            sftp.upload!("index.html", "public_html/index.html")
        end
    end

    def read_active_requests
        @@arrivalArray.each do |key, service|
            string = "Linha #{key} #{service["routeMnemonic"].upcase}"
            string = DictionaryHelper.new.byExtense(string)
            `espeak -vpt -g 4 \"#{string}\"`
            `espeak -vpt -g 4 \"previsão para chegada #{(service["time"] / 60).ceil} minutos\"`

        end
    end

    def display_html
        self.generate_file
<<<<<<< HEAD
        self.send
=======
        #self.send
>>>>>>> 331e23ebcc6b107204c04366d634fbe57c36f63c
    end
end
