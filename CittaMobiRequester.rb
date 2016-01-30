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
            stringArray.push("#{service['routeCode']}\ #{service['routeMnemonic'].upcase}")
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
                if bestTime < 5000
                    result[service["routeCode"]] =
                    {
                        "routeMnemonic" => service["routeMnemonic"],
                        "wheelchairNeeds" => false,
                        "time" => bestTime
                    }
                end
            end
        end
        result
    end

    def getPredictionsByTimeWheelchair
        servicesObject = self.getPredictionsArrayByStop
        result = {}
        servicesObject.each do |service|
            if !service["vehicles"].empty?
                bestTime = 1000000
                service["vehicles"].each do |vehicle|
                    if vehicle["wheelchair"]
                        timeToArrival = vehicle["prediction"] - vehicle["age"]
                        if timeToArrival < bestTime
                            bestTime = timeToArrival
                        end
                    end
                end
                if bestTime < 5000
                    result[service["routeCode"]] =
                    {
                        "routeMnemonic" => service["routeMnemonic"],
                        "wheelchairNeeds" => true,
                        "time" => bestTime
                    }
                end
            end
        end
        result
    end

    def getRouteHasVehicles(routeCode, wheelchairNeeds)
        hasVehicles = false
        servicesObject = self.getPredictionsArrayByStop
        servicesObject.each do |service|
            if service["routeCode"] == routeCode && !service["vehicles"].empty? && !wheelchairNeeds
                hasVehicles = true
            elsif service["routeCode"] == routeCode && !service["vehicles"].empty? && wheelchairNeeds
                service["vehicles"].each do |vehicle|
                    if vehicle["wheelchair"]
                        hasVehicles = true
                    end
                end
            end
        end
        hasVehicles
    end
end
