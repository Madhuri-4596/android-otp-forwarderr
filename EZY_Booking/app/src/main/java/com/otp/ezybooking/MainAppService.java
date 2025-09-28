package com.otp.ezybooking;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.json.MappingJacksonHttpMessageConverter;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainAppService extends Service implements SmsListener, NetworkMonitor.NetworkCallback {

    private static final String CHANNEL_ID = "OTP_SERVICE_CHANNEL";
    private static final int NOTIFICATION_ID = 1;

    private final String userOTPPostAPI = "https://www.ezybooking.in/OTP/apiotpauth/";
    private SharedPreferences sp;
    private AppDatabase database;
    private QueuedMessageDao messageDao;
    private NetworkMonitor networkMonitor;
    private ExecutorService executorService;
    private Handler mainHandler;

    private final String userEmailValue = "userEmailValue";
    private final String simNumber1Value = "simNumber1Value";
    private final String simNumber2Value = "simNumber2Value";

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i("MainAppService", "onStartCommand");
        createNotificationChannel();
        startForeground(NOTIFICATION_ID, createNotification());
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i("MainAppService", "onCreate - Starting foreground service");

        sp = getSharedPreferences("ezybookinglogin", MODE_PRIVATE);
        database = AppDatabase.getDatabase(this);
        messageDao = database.queuedMessageDao();
        executorService = Executors.newFixedThreadPool(3);
        mainHandler = new Handler(Looper.getMainLooper());

        networkMonitor = new NetworkMonitor(this);
        networkMonitor.startMonitoring(this);

        SmsReceiver.bindListener(this);

        // Process any pending messages when service starts
        processQueuedMessages();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "OTP Forwarding Service",
                    NotificationManager.IMPORTANCE_LOW
            );
            serviceChannel.setDescription("Monitors SMS for OTP codes and forwards them to server");
            serviceChannel.setShowBadge(false);
            serviceChannel.setSound(null, null);

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }
        }
    }

    private Notification createNotification() {
        Intent notificationIntent = new Intent(this, MainAppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent,
                PendingIntent.FLAG_IMMUTABLE);

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("OTP Forwarding Active")
                .setContentText("Monitoring SMS for OTP codes")
                .setSmallIcon(R.drawable.ezybooking)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .setSilent(true)
                .build();
    }

    @Override
    public void messageReceived(String slot, String messageText) {
        Log.i("MainAppService", "Slot number received : "+ slot + " Message : "+ messageText);

        String userEmail = sp.getString(userEmailValue, null);
        String inputMobileNumber1 = sp.getString(simNumber1Value, null);
        String inputMobileNumber2 = sp.getString(simNumber2Value, null);
        String validMobileNumber = null;

        if ((inputMobileNumber1 == null || inputMobileNumber1.isEmpty()) &&
            (inputMobileNumber2 == null || inputMobileNumber2.isEmpty())) {
            Log.i("MainAppService", "Mobile number not entered in the text boxes above");
            return;
        }

        if (slot.equalsIgnoreCase("0") || slot.equalsIgnoreCase("3")) {
            if (inputMobileNumber1 != null && !inputMobileNumber1.isEmpty()) {
                validMobileNumber = inputMobileNumber1;
            } else {
                Log.w("MainAppService", "Message received on SIM 1, but mobile number 1 not configured");
                return;
            }
        } else {
            if (inputMobileNumber2 != null && !inputMobileNumber2.isEmpty()) {
                validMobileNumber = inputMobileNumber2;
            } else {
                Log.w("MainAppService", "Message received on SIM 2, but mobile number 2 not configured");
                return;
            }
        }

        if (validMobileNumber != null && userEmail != null) {
            processOtpCode(userEmail, validMobileNumber, messageText);
        }
    }

    private void processOtpCode(String validUserEmail, String validMobileNumber, String messageText) {
        String otpCode = null;
        boolean isSimOTP = false;

        // Parse different OTP message formats
        if (messageText.contains("Your One Time Password is ") && messageText.contains(" for SSMMS Login")) {
            isSimOTP = true;
            int endIndex = messageText.indexOf(" for SSMMS Login");
            otpCode = messageText.substring(26, endIndex).trim();
        } else if (messageText.contains("Use OTP ") && messageText.contains(" for SSMMS Login")) {
            isSimOTP = true;
            int endIndex = messageText.indexOf(" for SSMMS Login");
            otpCode = messageText.substring(8, endIndex).trim();
        } else if (messageText.contains(" is your One Time Password for SSMMS Login")) {
            isSimOTP = true;
            int endIndex = messageText.indexOf(" is your One Time Password for SSMMS Login");
            otpCode = messageText.substring(0, endIndex).trim();
        } else if (messageText.contains("Your SSMMS Login OTP")) {
            isSimOTP = true;
            int endIndex = messageText.indexOf(" -");
            if (endIndex > 21) {
                otpCode = messageText.substring(21, endIndex).trim();
            }
        }

        String vehicleNumber = null;
        boolean isVehicleOTP = false;
        if (messageText.contains("OTP for SSMMS Booking with Vehicle No : ")) {
            isVehicleOTP = true;
            String tempText = messageText.substring(40);
            int endIndex = tempText.indexOf(" is ");
            if (endIndex > 0) {
                vehicleNumber = tempText.substring(0, endIndex).trim();
                int endIndex1 = tempText.indexOf(" -");
                if (endIndex1 > endIndex + 6) {
                    otpCode = tempText.substring(endIndex + 6, endIndex1).trim();
                }
            }
        }

        // Queue the message for processing
        if (isSimOTP && validMobileNumber != null && otpCode != null) {
            queueMessage(validUserEmail, validMobileNumber, otpCode);
        }
        if (isVehicleOTP && vehicleNumber != null && otpCode != null) {
            queueMessage(validUserEmail, vehicleNumber, otpCode);
        }

        Log.i("MainAppService", "OTP processed and queued: " + new Date());
    }

    private void queueMessage(String userEmail, String referenceKey, String otpCode) {
        executorService.execute(() -> {
            try {
                QueuedMessage message = new QueuedMessage(userEmail, referenceKey, otpCode);
                messageDao.insert(message);
                Log.i("MainAppService", "Message queued for: " + referenceKey);

                // Try to send immediately if network is available
                if (networkMonitor.isNetworkAvailable()) {
                    sendQueuedMessage(message);
                }
            } catch (Exception e) {
                Log.e("MainAppService", "Error queuing message: " + e.getMessage());
            }
        });
    }

    private void sendQueuedMessage(QueuedMessage message) {
        executorService.execute(() -> {
            try {
                OTPRequest otpRequest = new OTPRequest(message.userEmail, message.referenceKey, message.otpCode);
                RestTemplate restTemplate = new RestTemplate();

                restTemplate.getMessageConverters().add(new MappingJacksonHttpMessageConverter());
                HttpHeaders requestHeaders = new HttpHeaders();
                requestHeaders.setContentType(MediaType.APPLICATION_JSON);
                List<MediaType> acceptableMediaTypes = new ArrayList<>();
                acceptableMediaTypes.add(MediaType.APPLICATION_JSON);
                acceptableMediaTypes.add(MediaType.TEXT_PLAIN);
                requestHeaders.setAccept(acceptableMediaTypes);

                HttpEntity<OTPRequest> requestEntity = new HttpEntity<>(otpRequest, requestHeaders);
                ResponseEntity<OTPResponse> responseEntity = restTemplate.postForEntity(
                        userOTPPostAPI, requestEntity, OTPResponse.class);

                if (responseEntity.getStatusCode() == HttpStatus.CREATED ||
                    responseEntity.getStatusCode() == HttpStatus.OK) {

                    // Mark message as sent
                    message.isPending = false;
                    messageDao.update(message);

                    Log.i("MainAppService", "OTP sent successfully for: " + message.referenceKey);

                    String response = responseEntity.getBody().getResponse();
                    if (response.equalsIgnoreCase("Subscription not found for user")) {
                        mainHandler.post(() ->
                            Toast.makeText(MainAppService.this, "Subscription not found", Toast.LENGTH_SHORT).show());
                    }
                } else {
                    handleSendFailure(message);
                }

            } catch (Exception e) {
                Log.e("MainAppService", "Failed to send OTP for: " + message.referenceKey + " - " + e.getMessage());
                handleSendFailure(message);
            }
        });
    }

    private void handleSendFailure(QueuedMessage message) {
        message.retryCount++;
        if (message.retryCount < 5) { // Max 5 retries
            messageDao.update(message);
            Log.i("MainAppService", "Message retry count: " + message.retryCount + " for: " + message.referenceKey);
        } else {
            // Mark as failed after max retries
            message.isPending = false;
            messageDao.update(message);
            Log.w("MainAppService", "Message failed after max retries: " + message.referenceKey);
        }
    }

    private void processQueuedMessages() {
        if (!networkMonitor.isNetworkAvailable()) {
            Log.i("MainAppService", "Network not available, skipping queue processing");
            return;
        }

        executorService.execute(() -> {
            try {
                List<QueuedMessage> pendingMessages = messageDao.getPendingMessages();
                Log.i("MainAppService", "Processing " + pendingMessages.size() + " queued messages");

                for (QueuedMessage message : pendingMessages) {
                    sendQueuedMessage(message);
                    // Small delay between sends to avoid overwhelming server
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }

                // Clean up old processed messages (older than 24 hours)
                long cutoffTime = System.currentTimeMillis() - (24 * 60 * 60 * 1000);
                messageDao.deleteOldProcessedMessages(cutoffTime);

            } catch (Exception e) {
                Log.e("MainAppService", "Error processing queued messages: " + e.getMessage());
            }
        });
    }

    @Override
    public void onNetworkAvailable() {
        Log.i("MainAppService", "Network available - processing queued messages");
        processQueuedMessages();
    }

    @Override
    public void onNetworkLost() {
        Log.i("MainAppService", "Network lost - messages will be queued");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i("MainAppService", "Service destroyed");
        SmsReceiver.unBindListener();
        if (executorService != null) {
            executorService.shutdown();
        }
    }
}
