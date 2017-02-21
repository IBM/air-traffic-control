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

import org.opensky.libadsb.PositionDecoder;

import com.google.gson.JsonObject;

public class Flight {
    public static enum State {
        CACHED, NEW
    }

    private static final String SCHEMA_TYPE = "ar_flights_schema";
    private static final String PROPERTY_ICAO = "icao";
    private static final String PROPERTY_ALTITUDE = "altitudeInMeters";
    private static final String PROPERTY_CALLSIGN = "callSign";
    private static final String PROPERTY_HEADING = "headingInDegrees";
    private static final String PROPERTY_LATITUDE = "latitude";
    private static final String PROPERTY_LONGITUDE = "longitude";
    private static final String PROPERTY_SCHEMA_TYPE = "type";
    private static final String PROPERTY_VELOCITY = "velocityInMetersPerSecond";
    private static final String PROPERTY_CREATE_TIMESTAMP = "createdInMillis";
    private static final String PROPERTY_LAST_UPDATED_TIMESTAMP = "lastUpdatedInMillis";
    private static final String PROPERTY_GROUND_STATION_ID = "groundStationId";

    private static final String JSON_MESSAGE_FORMAT =
                                         "{ " +
                                              "\"icao\" : " + "\"%s\", " +
                                              "\"altitudeInMeters\" : " + "%f, " +
                                              "\"callSign\" : " + "\"%s\", " +
                                              "\"headingInDegrees\" : " + "%f, " +
                                              "\"latitude\" : " + "%f, " +
                                              "\"longitude\" : " + "%f, " +
                                              "\"groundStationId\" : " + "\"%s\", " +
                                              "\"type\" : " + "\"%s\", " +
                                              "\"velocityInMetersPerSecond\" : " + "%f, " +
                                              "\"createdInMillis\" : " + "%d, " +
                                              "\"lastUpdatedInMillis\" : " + "%d" +
                                         "}";

    private final String icao;
    private final long createdInMillis;
    private final PositionDecoder positionDecoder;

    private String callSign;
    private double altitudeInMeters;
    private double headingInDegrees;
    private double latitude;
    private double longitude;
    private double velocityInMetersPerSecond;
    private long lastUpdatedInMillis;
    private State state;

    public Flight(String icao) {
        if ((icao == null) || (icao.length() == 0)) {
            throw new NullPointerException(format("Invalid icao passed in: '%s'", icao));
        }
        this.icao = icao;
        this.createdInMillis = System.currentTimeMillis();
        this.positionDecoder = new PositionDecoder();
        this.latitude = 100;  // Invalid latitude initialization
        this.longitude = 200; // Invalid longitude initialization
    }

    public String getIcao() {
        return icao;
    }

    public long getCreatedInMillis() {
        return createdInMillis;
    }

    public PositionDecoder getPositionDecoder() {
        return positionDecoder;
    }

    public String getType() {
        return SCHEMA_TYPE;
    }

    public String getCallSign() {
        return callSign;
    }

    public void setCallSign(String callSign) {
        this.callSign = callSign;
    }

    public double getAltitudeInMeters() {
        return altitudeInMeters;
    }

    public void setAltitudeInMeters(double altitudeInMeters) {
        this.altitudeInMeters = altitudeInMeters;
    }

    public double getHeadingInDegrees() {
        return headingInDegrees;
    }

    public void setHeadingInDegrees(double headingInDegrees) {
        this.headingInDegrees = headingInDegrees;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getVelocityInMetersPerSecond() {
        return velocityInMetersPerSecond;
    }

    public void setVelocityInMetersPerSecond(double velocityInMetersPerSecond) {
        this.velocityInMetersPerSecond = velocityInMetersPerSecond;
    }

    public long getLastUpdatedInMillis() {
        return lastUpdatedInMillis;
    }

    public void setLastUpdatedInMillis(long lastUpdatedInMillis) {
        this.lastUpdatedInMillis = lastUpdatedInMillis;
    }

    public boolean isReadyForTracking() {
        return ((latitude != 100) && (longitude != 200)) ? true : false;
    }

    public JsonObject getJsonObject() {
        assert isReadyForTracking();

        JsonObject jsonObject = new JsonObject();
        String cs = (callSign != null) ? callSign : icao;

        jsonObject.addProperty(PROPERTY_ICAO, icao);
        jsonObject.addProperty(PROPERTY_ALTITUDE, altitudeInMeters);
        jsonObject.addProperty(PROPERTY_CALLSIGN, cs);
        jsonObject.addProperty(PROPERTY_HEADING, headingInDegrees);
        jsonObject.addProperty(PROPERTY_LATITUDE, latitude);
        jsonObject.addProperty(PROPERTY_LONGITUDE, longitude);
        jsonObject.addProperty(PROPERTY_GROUND_STATION_ID, IotClient.getMacAddress());
        jsonObject.addProperty(PROPERTY_SCHEMA_TYPE, SCHEMA_TYPE);
        jsonObject.addProperty(PROPERTY_VELOCITY, velocityInMetersPerSecond);
        jsonObject.addProperty(PROPERTY_CREATE_TIMESTAMP, createdInMillis);
        jsonObject.addProperty(PROPERTY_LAST_UPDATED_TIMESTAMP, lastUpdatedInMillis);

        return jsonObject;
    }

    public String toJSON() {
        assert isReadyForTracking();

        String cs = (callSign != null) ? callSign : icao;
        String json = format(JSON_MESSAGE_FORMAT,
                             icao, 
                             altitudeInMeters,
                             cs,
                             headingInDegrees, 
                             latitude,
                             longitude,
                             IotClient.getMacAddress(),
                             SCHEMA_TYPE,
                             velocityInMetersPerSecond,
                             createdInMillis,
                             lastUpdatedInMillis
                            );
        return json;
    }

    public String toString() {
        return toJSON();
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }
}
