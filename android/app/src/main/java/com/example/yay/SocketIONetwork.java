package com.example.yay;

import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.logging.Logger;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;


public class SocketIONetwork {
    static final String SOCKET_ADDRESS = "http://129.21.70.100:8000/socket.io";
    Logger logger = Logger.getLogger("socketIOLogger");
    private static Socket socket;

    public SocketIONetwork() throws URISyntaxException {
        logger.info("init socketio client to " + SOCKET_ADDRESS);
        socket = IO.socket(SOCKET_ADDRESS);
        socket.connect();

        logger.severe("socket object");

        socket.on(Socket.EVENT_CONNECT, args -> logger.info("connected to socketio server : " + Arrays.toString(args)));

        logger.severe(String.valueOf(socket.connected()));

    }

    public Socket getSocket() {
        return socket;
    }

}
