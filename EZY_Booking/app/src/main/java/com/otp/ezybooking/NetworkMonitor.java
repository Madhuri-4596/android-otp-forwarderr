package com.otp.ezybooking;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.os.Build;

public class NetworkMonitor {
    private ConnectivityManager connectivityManager;
    private NetworkCallback networkCallback;
    private boolean isConnected = false;

    public interface NetworkCallback {
        void onNetworkAvailable();
        void onNetworkLost();
    }

    public NetworkMonitor(Context context) {
        connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        checkInitialConnection();
    }

    private void checkInitialConnection() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Network network = connectivityManager.getActiveNetwork();
            if (network != null) {
                NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
                isConnected = capabilities != null &&
                    (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                     capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR));
            }
        } else {
            android.net.NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
            isConnected = networkInfo != null && networkInfo.isConnected();
        }
    }

    public void startMonitoring(NetworkCallback callback) {
        this.networkCallback = callback;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            ConnectivityManager.NetworkCallback systemCallback = new ConnectivityManager.NetworkCallback() {
                @Override
                public void onAvailable(Network network) {
                    if (!isConnected) {
                        isConnected = true;
                        if (NetworkMonitor.this.networkCallback != null) {
                            NetworkMonitor.this.networkCallback.onNetworkAvailable();
                        }
                    }
                }

                @Override
                public void onLost(Network network) {
                    isConnected = false;
                    if (NetworkMonitor.this.networkCallback != null) {
                        NetworkMonitor.this.networkCallback.onNetworkLost();
                    }
                }
            };

            NetworkRequest.Builder builder = new NetworkRequest.Builder();
            connectivityManager.registerNetworkCallback(builder.build(), systemCallback);
        }
    }

    public boolean isNetworkAvailable() {
        return isConnected;
    }
}