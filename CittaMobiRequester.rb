require 'net/http'
require 'json'

class CittaMobiRequester
    @@apiUri = "http://campusparty.cittamobi.com.br";

    def getServicesArrayByStop (stopId = '1000017306')
        uri = URI(@@apiUri + "/bus/stop/" + stopId)
        stop = Net::HTTP.get(uri).force_encoding("utf-8")
        jsonObject = JSON.parse stop
        services = jsonObject['services']
    end

    def getPredictionsArrayByStop (stopId = '1000017306')
        uri = URI(@@apiUri + "/bus/prediction/stop/" + stopId)
        stop = Net::HTTP.get(uri).force_encoding("utf-8")
        jsonObject = JSON.parse stop
        services = jsonObject['services']
    end

    def getServicesNames
        servicesString = self.getServicesArrayByStop
        stringArray = Array.new
        servicesString.each do |service|
            stringArray.push("#{service['routeCode']}\ #{service['routeMnemonic']}")
        end
        stringArray
    end

    def getPredictionsByTime
        servicesObject = self.getPredictionsArrayByStop
        result = {}
        servicesObject.each do |service|
            if !service["vehicles"].empty?
                bestTime = service["vehicles"][0]["age"] > service["vehicles"][0]["prediction"] ? 1000000 :
                    service["vehicles"][0]["prediction"] - service["vehicles"][0]["age"]
                service["vehicles"].each do |vehicle|
                    timeToArrival = vehicle["prediction"] - vehicle["age"]
                    if timeToArrival < bestTime
                        bestTime = timeToArrival
                    end
                end
                if bestTime < 300
                    result[service["routeCode"]] = service["routeMnemonic"]
                end
            end
        end
        result
    end

    def getRouteHasVehicles(routeCode)
        hasVehicles = false
        servicesObject = self.getPredictionsArrayByStop
        servicesObject.each do |service|
            if service["routeCode"] == routeCode && !service["vehicles"].empty?
                hasVehicles = true
            end
        end
        hasVehicles
    end
end

puts CittaMobiRequester.new.getPredictionsByTime
