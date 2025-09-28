package com.otp.ezybooking;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "queued_messages")
public class QueuedMessage {
    @PrimaryKey(autoGenerate = true)
    public int id;

    public String userEmail;
    public String referenceKey;
    public String otpCode;
    public long timestamp;
    public int retryCount;
    public boolean isPending;

    public QueuedMessage(String userEmail, String referenceKey, String otpCode) {
        this.userEmail = userEmail;
        this.referenceKey = referenceKey;
        this.otpCode = otpCode;
        this.timestamp = System.currentTimeMillis();
        this.retryCount = 0;
        this.isPending = true;
    }
}