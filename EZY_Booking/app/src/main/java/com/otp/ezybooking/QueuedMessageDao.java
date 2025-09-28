package com.otp.ezybooking;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import java.util.List;

@Dao
public interface QueuedMessageDao {
    @Insert
    void insert(QueuedMessage message);

    @Query("SELECT * FROM queued_messages WHERE isPending = 1 ORDER BY timestamp ASC")
    List<QueuedMessage> getPendingMessages();

    @Update
    void update(QueuedMessage message);

    @Query("DELETE FROM queued_messages WHERE id = :id")
    void delete(int id);

    @Query("DELETE FROM queued_messages WHERE isPending = 0 AND timestamp < :cutoffTime")
    void deleteOldProcessedMessages(long cutoffTime);
}