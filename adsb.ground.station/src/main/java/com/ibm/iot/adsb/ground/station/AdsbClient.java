/**
 * Copyright 2016, IBM Corporation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.ibm.iot.adsb.ground.station;

import static java.lang.String.format;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.opensky.libadsb.Decoder;
import org.opensky.libadsb.Position;
import org.opensky.libadsb.PositionDecoder;
import org.opensky.libadsb.tools;
import org.opensky.libadsb.exceptions.BadFormatException;
import org.opensky.libadsb.exceptions.UnspecifiedFormatError;
import org.opensky.libadsb.msgs.AirbornePositionMsg;
import org.opensky.libadsb.msgs.AirspeedHeadingMsg;
import org.opensky.libadsb.msgs.EmergencyOrPriorityStatusMsg;
import org.opensky.libadsb.msgs.ExtendedSquitter;
import org.opensky.libadsb.msgs.IdentificationMsg;
import org.opensky.libadsb.msgs.ModeSReply;
import org.opensky.libadsb.msgs.OperationalStatusMsg;
import org.opensky.libadsb.msgs.SurfacePositionMsg;
import org.opensky.libadsb.msgs.TCASResolutionAdvisoryMsg;
import org.opensky.libadsb.msgs.VelocityOverGroundMsg;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.ibm.iot.adsb.ground.station.Flight.State;

public class AdsbClient {
    private static final String CMDLINE_ARG_SIMULATE_SDR = "--simulate-sdr";
    private static final String CMDLINE_ARG_HOST = "--host";
    private static final String CMDLINE_ARG_PORT = "--port";

    private final Logger logger = LoggerFactory.getLogger(AdsbClient.class);
    private final Map<String, Flight> flights;

    public AdsbClient() {
        flights = new HashMap<>();
    }

    public Flight decodeAdsbMessage(long timestampInMillis, String raw) throws Exception {
        ModeSReply msg;
        try {
            msg = Decoder.genericDecoder(raw);
        } catch (BadFormatException e) {
            logger.error("Malformed message! Skipping it. Message: " + e.getMessage());
            throw new RuntimeException(e);
        } catch (UnspecifiedFormatError e) {
            logger.error("Unspecified message! Skipping it...");
            throw new RuntimeException(e);
        }

        if (logger.isDebugEnabled()) {
            logger.debug("\n*************************");
            logger.debug("Number of flights: " + flights.size());
            logger.debug(flights.toString());
        }

        logger.info(format("Raw Message: '%s'", raw));

        double timeStampInSeconds = new Double(System.currentTimeMillis() / 1000).doubleValue();
        String icao24 = tools.toHexString(msg.getIcao24());
        Flight flight = null;

        // check for erroneous messages; some receivers set
        // parity field to the result of the CRC polynomial division
        if (tools.isZero(msg.getParity()) || msg.checkParity()) { // CRC is ok
            // Remove flights that have not been tracked/updated for more than one hour once the
            // size of the map reaches 100.
            if (flights.size() >= 100) {
                List<String> untrackedFlights = new ArrayList<>();
                for (String key : flights.keySet()) {
                    Flight f = flights.get(key);
                    PositionDecoder posDecoder = f.getPositionDecoder();
                    if (posDecoder.getLastUsedTime() < (timeStampInSeconds - 3600)) {
                        untrackedFlights.add(key);
                    }
                }

                for (String key : untrackedFlights) {
                    flights.remove(key);
                }
            }

            switch (msg.getType()) {
            case ADSB_AIRBORN_POSITION:
                AirbornePositionMsg airpos = (AirbornePositionMsg) msg;
                flight = getFlight(icao24);
                logger.info("[" + icao24 + "]");

                // Decode the position if possible.
                if (!isNewFlight(flight)) {
                    PositionDecoder positionDecoder = flight.getPositionDecoder();
                    airpos.setNICSupplementA(positionDecoder.getNICSupplementA());
                    Position current = positionDecoder.decodePosition(timeStampInSeconds, airpos);
                    if (current == null) {
                        logger.info("Cannot decode airborne position yet.");
                    }
                    else {
                        logger.info("Now at position ("+current.getLatitude()+","+current.getLongitude()+")");
                        flight.setLatitude(current.getLatitude());
                        flight.setLongitude(current.getLongitude());
                    }
                }
                else {
                    PositionDecoder positionDecoder = flight.getPositionDecoder();
                    positionDecoder.decodePosition(timeStampInSeconds, airpos);
                    logger.info("First position.");
                }
                logger.info("          Horizontal containment radius is "+airpos.getHorizontalContainmentRadiusLimit()+" m");
                logger.info("          Altitude is "+ (airpos.hasAltitude() ? airpos.getAltitude() : "unknown") +" m");
                if (airpos.hasAltitude()) {
                    flight.setAltitudeInMeters(airpos.getAltitude());
                }

                flight.setLastUpdatedInMillis(timestampInMillis);
                break;

            case ADSB_SURFACE_POSITION:
                SurfacePositionMsg surfpos = (SurfacePositionMsg) msg;
                flight = getFlight(icao24);

                logger.info("[" + icao24 + "]");

                // Decode the position if possible.
                if (!isNewFlight(flight)) {
                    PositionDecoder positionDecoder = flight.getPositionDecoder();
                    Position current = positionDecoder.decodePosition(timeStampInSeconds, surfpos);
                    if (current == null) {
                        logger.info("Cannot decode airborne position yet.");
                    }
                    else {
                        logger.info("Now at position ("+current.getLatitude()+","+current.getLongitude()+")");
                        flight.setLatitude(current.getLatitude());
                        flight.setLongitude(current.getLongitude());
                    }
                }
                else {
                    PositionDecoder positionDecoder = flight.getPositionDecoder();
                    positionDecoder.decodePosition(timeStampInSeconds, surfpos);
                    logger.info("First position.");
                }
                logger.info("          Horizontal containment radius is "+surfpos.getHorizontalContainmentRadiusLimit()+" m");
                if (surfpos.hasValidHeading()) {
                    logger.info("          Heading is "+surfpos.getHeading()+" m");
                }
                logger.info("          Airplane is on the ground.");
                flight.setLastUpdatedInMillis(timestampInMillis);
                break;

            case ADSB_EMERGENCY:
                EmergencyOrPriorityStatusMsg status = (EmergencyOrPriorityStatusMsg) msg;
                logger.info("[" + icao24 + "]: " + status.getEmergencyStateText());
                logger.info("          Mode A code is "+status.getModeACode()[0]+
                        status.getModeACode()[1]+status.getModeACode()[2]+status.getModeACode()[3]);
                break;

            case ADSB_AIRSPEED:
                AirspeedHeadingMsg airspeed = (AirspeedHeadingMsg) msg;
                logger.info("["+icao24+"]: Airspeed is "+
                        (airspeed.hasAirspeedInfo() ? airspeed.getAirspeed()+" m/s" : "unkown"));
                if (airspeed.hasHeadingInfo()) {
                    logger.info("          Heading is "+
                            (airspeed.hasHeadingInfo() ? airspeed.getHeading()+"°" : "unkown"));
                }
                if (airspeed.hasVerticalRateInfo()) {
                    logger.info("          Vertical rate is "+
                            (airspeed.hasVerticalRateInfo() ? airspeed.getVerticalRate()+" m/s" : "unkown"));
                }
                break;

            case ADSB_IDENTIFICATION:
                IdentificationMsg ident = (IdentificationMsg) msg;
                String callSign = new String(ident.getIdentity());
                flight = getFlight(icao24);

                logger.info("["+icao24+"]: Callsign is "+ callSign);
                logger.info("          Category: "+ident.getCategoryDescription());

                flight.setCallSign(callSign.trim());
                flight.setLastUpdatedInMillis(timestampInMillis);
                break;

            case ADSB_STATUS:
                OperationalStatusMsg opstat = (OperationalStatusMsg) msg;
                flight = getFlight(icao24);
                PositionDecoder positionDecoder = flight.getPositionDecoder();
                positionDecoder.setNICSupplementA(opstat.getNICSupplementA());
                if (opstat.getSubtypeCode() == 1) {
                    positionDecoder.setNICSupplementC(opstat.getNICSupplementC());
                }
                logger.info("["+icao24+"]: Using ADS-B version "+opstat.getVersion());
                logger.info("          Has ADS-B IN function: "+opstat.has1090ESIn());
                flight.setLastUpdatedInMillis(timestampInMillis);
                break;

            case ADSB_TCAS:
                TCASResolutionAdvisoryMsg tcas = (TCASResolutionAdvisoryMsg) msg;
                logger.info("["+icao24+"]: TCAS Resolution Advisory completed: "+tcas.hasRATerminated());
                logger.info("          Threat type is "+tcas.getThreatType());
                if (tcas.getThreatType() == 1) // it's a icao24 address
                    logger.info("          Threat identity is 0x"+String.format("%06x", tcas.getThreatIdentity()));
                break;

            case ADSB_VELOCITY:
                VelocityOverGroundMsg veloc = (VelocityOverGroundMsg) msg;
                flight = getFlight(icao24);

                logger.info("["+icao24+"]: Velocity is "+(veloc.hasVelocityInfo() ? veloc.getVelocity() : "unknown")+" m/s");
                logger.info("          Heading is "+(veloc.hasVelocityInfo() ? veloc.getHeading() : "unknown")+" degrees");
                logger.info("          Vertical rate is "+(veloc.hasVerticalRateInfo() ? veloc.getVerticalRate() : "unknown")+" m/s");

                if (veloc.hasVelocityInfo()) {
                    flight.setVelocityInMetersPerSecond(veloc.getVelocity());
                    flight.setHeadingInDegrees(veloc.getHeading());
                    flight.setLastUpdatedInMillis(timestampInMillis);
                }
                break;

            case EXTENDED_SQUITTER:
                logger.info("["+icao24+"]: Unknown extended squitter with type code "+((ExtendedSquitter)msg).getFormatTypeCode()+"!");
                break;

            default:
                if (logger.isTraceEnabled()) {
                    logger.trace("Invalid message type: " + msg.getType());
                }
            }
        }
        else {
            if (logger.isTraceEnabled()) {
                logger.trace("Message with DF != 17");
            }
        }
   
        return flight;
    }

    private Flight getFlight(String icao) {
        Flight flight = null;

        if (flights.containsKey(icao)) {
            flight = flights.get(icao);
            flight.setState(State.CACHED);
        }
        else {
            flight = new Flight(icao);
            flight.setState(State.NEW);
            flights.put(icao, flight);
        }

        return flight;
    }

    private boolean isNewFlight(Flight flight) {
        return flight.getState() == State.NEW;
    }

    private void bootstrap(String[] args) {
        IotClient iotClient = new IotClient();

        // Establish connection to Watson IoT Platform.
        try {
            iotClient.connect();
        } catch (IOException ex) {
            ex.printStackTrace();
            logger.error(ex.getMessage(), ex);
            throw new RuntimeException(ex);
        }

        String host = null;
        int portNumber = 30002;
        int i = 0;
        String arg = null;
        boolean simulateSdr = false;

        if (args.length == 0) {
            host = "localhost";
            portNumber = 30002;
        }
        else {
            while ((i < args.length) && args[i].startsWith("--"))  {
                arg = args[i++];
                
                switch (arg) {
                case CMDLINE_ARG_SIMULATE_SDR:
                    // Ignore hostname and port as we will be using cached SDR data to send
                    // MQTT messages. This option is useful when SDR dongle is not available and
                    // developers want to quickly try things out.
                    simulateSdr = true;
                    logger.info("Simulating SDR 1090 using the flight data from San Jose area");
                    break;
                case CMDLINE_ARG_HOST:
                    host = args[i++];
                    logger.info("Host is " + host);
                    break;
                case CMDLINE_ARG_PORT:
                    String port = args[i++];
                    logger.info("Port Number is " + port);
                    portNumber = Integer.parseInt(port);
                    break;
                default:
                    System.err.println("Usage: java AdsbClient [--simulate-sdr] [--host <192.168.1.1>] [--port <30002>]");
                    System.exit(1);
                }
            }
        }

        Socket socket = null;
        BufferedReader in = null;

        try {
            if (simulateSdr) {
                ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
                InputStream inputStream = classLoader.getResourceAsStream("sdr_1090_data.txt");
                in = new BufferedReader(new InputStreamReader(inputStream));
                String adsbMessage = null;
                List<String> rawMessages = new ArrayList<>();

                while ((adsbMessage = in.readLine()) != null) {
                    String rawMessage = adsbMessage.substring(1, adsbMessage.length() - 1);
                    Flight flight = decodeAdsbMessage(System.currentTimeMillis(), rawMessage);
                    iotClient.publishEvent(flight);

                    // Cache raw ADSB messages that were read from the file to be played again.
                    rawMessages.add(rawMessage);
                }

                // Keep playing the cached ADSB messages forever.
                while (true) {
                    for (String rawMessage : rawMessages) {
                        Flight flight = decodeAdsbMessage(System.currentTimeMillis(), rawMessage);
                        iotClient.publishEvent(flight);
                    }
                }
            }
            else {
                String adsbMessage = null;
                socket = new Socket(host, portNumber);
                in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

                while ((adsbMessage = in.readLine()) != null) {
                    String rawMessage = adsbMessage.substring(1, adsbMessage.length() - 1);
                    Flight flight = decodeAdsbMessage(System.currentTimeMillis(), rawMessage);
                    try {
                        iotClient.publishEvent(flight);
                    }
                    catch (IOException ioe) {
                        ioe.printStackTrace();
                        logger.error(ioe.getMessage(), ioe);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            logger.error(e.getMessage(), e);
            throw new RuntimeException(e);
        }
        finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e) {
                    logger.error(e.getMessage(), e);
                    throw new RuntimeException(e);
                }
            }
            if (socket != null) {
                try {
                    socket.close();
                } catch (IOException e) {
                    logger.error(e.getMessage(), e);
                    throw new RuntimeException(e);
                }
            }
            iotClient.disconnect();
        }
    }

    public static void main(String[] args) {
        AdsbClient adsbClient = new AdsbClient();
        adsbClient.bootstrap(args);
    }
}
