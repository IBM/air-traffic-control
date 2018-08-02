*Read this in other languages: [日本](README-ja.md).*

# ARFlightTracker
ARFlightTracker is an iOS based app which tracks flight pushed by SDR/ADSB message receiver through MQTT server. The app will display all the flights travelling point to point within the range of the receiver. AR Flight tracker app is connected to IBM MQTT server to a topic which receives new/updated flight information based on which is rendered into the map view. The data is fed to the topic by SDR/ADSB message receiver. The map also shows animated view of flights heading in a particular direction towards its destination. The callout view on the flight contains flight details with weather in current location of the flight.

## Map View
Map View displays all the flights on a default map provided in the iOS device. The flight orientation is adjusted based on the current heading information in the payload. As the app receives MQTT messages, the flight will be seen moving in the direction towards its destination. A flight can be tapped to see more details such as such as flight number, altitude, distance etc. Figure below shows the rendering of the Map View with flights in the Swift-based app on an iOS device:

![alt tag](https://github.com/IBM/air-traffic-control/blob/master/assets/mapview-weather.png)

## Augmented Reality View
The user can tap the  AR View  tab in the app to switch to the AR-based View. In this mode, the app opens up a camera view where the user can point to a flight to be able to see the flight data on a callout that overlays on top of the flight in the real world. As the flight is moving in the real world, the callout with the information moves along with the flight in the camera view. The AR view also displays a compass based on the device heading and a radar view displaying all the flights within the viewing angle. Figure 5 below shows the rendering of the Augmented Reality View with flights in the Swift-based app on an iOS device.

![alt tag](https://github.com/IBM/air-traffic-control/blob/master/assets/arview-weather.png)

# Pre-requisites
 - Swift 3
 - Xcode 8.0+
 - CocoaPod - https://cocoapods.org/
 - iOS 10+


# Dependencies
 - CocoaMQTT -  Note: moving to aphid client by IBM
 - SwiftyJSON
 - ios-arkit for iphone - (part of the code base)

# Steps:
 1. cd ARFlightTracker-iOS-Swift && open ARFlightTracker-iOS-Swift.xcworkspace using Xcode.
 2. Run `pod install` from the project directory. This will install the dependencies define in `Podfile`
 3. Update `util/MQTTConnection.swift` using Xcode editor. You have to create Internet of Things service in IBM Bluemix console to get the credentials. The credentials looks like as shown below:
 ```
     API_KEY = "<api-key>"
     API_TOKEN = "<token>"
     IOT_CLIENT = "a:<ORG_ID>:Flights"
     IOT_HOST = "<ORG_ID>.messaging.internetofthings.ibmcloud.com"
     IOT_PORT = 1883 (DEFAULT)
     IOT_TOPIC = "iot-2/type/<DEVICE_TYPE>/id/<DEVICE_ID>/evt/flight/fmt/json"
 ```
 4. Update `util/RestCall.swift` to with credentials for IBM Weather API. Create Weather API service using IBM Bluemix console:
 ```
    private static let WEATHER_API_USERNAME : String = "<username>"
    private static let WEATHER_API_PASSWORD : String = "<password>"
 ```
 5. Build and Run

# Test Mode:
You can run the app in test mode to be independant of IBM Bluemix MQTT server. In ViewController you can set the flag
 `flightTestMode = true`
