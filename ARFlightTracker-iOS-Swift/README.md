# IBMFlightTracker
IBMFlightTracker is an iOS based app which tracks flight pushed by SDR/ADSB message receiver through MQTT server. The app will display all the flights travelling point to point within the range of the receiver. IBM Flight tracker app is connected to IBM MQTT server to a topic which receives new/updated flight information based on which is rendered into the map view. The data is fed to the topic by SDR/ADSB message receiver. The map also shows animated view of flights heading in a particular direction towards its destination.

# Pre-requisites
 - Swift 3
 - Xcode 8.0+
 - CocoaPod - https://cocoapods.org/

 
# Dependencies
 - CocoaMQTT -  Note: moving to aphid client by IBM
 - SwiftyJSON
 - ARKit - (part of the code base)
 
# Steps:
 1. git clone git@github.ibm.com:rogue-one/IBMFlightTracker.git
 2. cd IBMFlightTracker && open IBMFlightTracker.xcworkspace using xcode
 3. Run `pod install` from the project directory. This will install the dependencies define in `Podfile`
 4. Change MQTT credentials in class  util/MQTTConnection.swift using Xcode editor . You have to create a IoT app in IBM           bluemix to get the MQTT server credentials. The credentials looks like in the follwing format
 ```
     API_KEY = "<api-key>"
     API_TOKEN = "<token>"
     IOT_CLIENT = "a:<ORG_ID>:Flights"
     IOT_HOST = "<ORG_ID>.messaging.internetofthings.ibmcloud.com"
     IOT_PORT = 1883 (DEFAULT)
     IOT_TOPIC = "iot-2/type/<DEVICE_TYPE>/id/<DEVICE_ID>/evt/flight/fmt/json"
 ```
 5. Change weather api credentials in class util/RestCall to have access to IBM weather API. You have to go the IBM weather in    bluemix and create an app to get the credentials.
 ```
    private static let WEATHER_API_USERNAME : String = "<username>"
    private static let WEATHER_API_PASSWORD : String = "<password>"
 ```
 6. Build and Run
 
# Test Mode:
You can run the app in test mode to be independant of IBM Bluemix MQTT server. In ViewController you can set the flag 
 `testMode = true`
 
