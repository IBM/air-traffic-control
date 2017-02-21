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

import java.io.IOException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Enumeration;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.JsonObject;
import com.ibm.iotf.client.app.ApplicationClient;

public class IotClient {
    private static final String MAC_ADDRESS = computeMacAddress();

    private static final String APP_PROPERTIES_FILE_NAME = "/application.properties";
    private static final Properties APP_PROPERTIES = loadProperties(APP_PROPERTIES_FILE_NAME);

    private final Logger logger = LoggerFactory.getLogger(IotClient.class);
    private final String deviceType;
    private final String deviceId;

    private ApplicationClient applicationClient;

    public IotClient( ) {
        if (logger.isDebugEnabled()) {
            logger.debug(APP_PROPERTIES.toString());
        }

        deviceType = APP_PROPERTIES.getProperty("Device-Type");
        deviceId = APP_PROPERTIES.getProperty("Device-ID");

        // Specify unique "id" so that multiple instances of this app can concurrently publish MQTT
        // messages on behalf of the same IoT device without requiring a hardcoded entry in the
        // properties file.
        APP_PROPERTIES.setProperty("id", MAC_ADDRESS +
                                         "-" +
                                         String.valueOf(System.currentTimeMillis()));
    }

    public void connect() throws IOException {
        try {
            applicationClient = new ApplicationClient(APP_PROPERTIES);
            applicationClient.connect();

            if (logger.isDebugEnabled()) {
                logger.debug("Connected to Watson Iot Platform: " + applicationClient.isConnected());
            }
        } catch (Exception e) {
            logger.error("Failed to connect to Watson IoT Platform", e.getMessage());
            throw new IOException("Failed to connect to Watson Iot Platform", e);
        }
    }

    public void disconnect() {
        applicationClient.disconnect();
        applicationClient = null;
    }

    public boolean isConnected() {
        return (applicationClient != null) ? applicationClient.isConnected() : false;
    }

    public void publishEvent(Flight flight) throws IOException {
        if ((flight == null) || !flight.isReadyForTracking()) {
            return;
        }

        if ((applicationClient == null) || !applicationClient.isConnected()) {
            logger.info("Reconnecting to IBM Bluemix...");
            connect();
            logger.info("Reconnected successfully to IBM Bluemix...");
        }

        if (logger.isDebugEnabled()) {
            logger.debug(flight.toString());
        }

        JsonObject jsonObject = flight.getJsonObject();
        logger.info("Publishing MQTT message");
        applicationClient.publishEvent(deviceType, deviceId, "flight", jsonObject);
        logger.info("Published MQTT message");
    }

    public static String getMacAddress() {
        return MAC_ADDRESS;
    }
    private static Properties loadProperties(String propertiesFileName) {
        Properties props = new Properties();
        try {
            props.load(IotClient.class.getResourceAsStream(propertiesFileName));
        } catch (IOException ex) {
            System.out.println("Not able to read the properties file!");
            ex.printStackTrace();
            throw new RuntimeException(ex);
        }

        return props;
    }

    private static String computeMacAddress() {
        StringBuilder sb = new StringBuilder();

        try {
            InetAddress ip = InetAddress.getLocalHost();
            System.out.println("IP address : " + ip.getHostAddress());

            Enumeration<NetworkInterface> networks = NetworkInterface.getNetworkInterfaces();
            while (networks.hasMoreElements()) {
                NetworkInterface network = networks.nextElement();
                byte[] mac = network.getHardwareAddress();

                if (mac != null) {
                    System.out.print("MAC address : ");
                    for (int i = 0; i < mac.length; i++) {
                        sb.append(String.format("%02X", mac[i]));
                    }
                    System.out.println(sb.toString());
                    return sb.toString();
                }
            }
        } catch (UnknownHostException | SocketException e) {
            e.printStackTrace();
        }
        return sb.toString();
    }

}
