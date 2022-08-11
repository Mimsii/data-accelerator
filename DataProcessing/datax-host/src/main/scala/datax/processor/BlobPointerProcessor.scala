// *********************************************************************
// Copyright (c) Microsoft Corporation.  All rights reserved.
// Licensed under the MIT License
// *********************************************************************
package datax.processor

import java.sql.Timestamp
import com.microsoft.azure.eventhubs.EventData
import datax.input.BlobPointerInput
import datax.telemetry.AppInsightLogger
import datax.utility.DateTimeUtil
import org.apache.spark.rdd.RDD

import scala.concurrent.duration.Duration

class BlobPointerProcessor(processPaths: (RDD[String], Timestamp, Duration, Timestamp, String) => Map[String, Double])
  extends StreamingProcessor[EventData]{

  val processPathsRDD = processPaths

  override val process = (rdd: RDD[EventData], batchTime: Timestamp, batchInterval: Duration) => {
    val currentTime = DateTimeUtil.getCurrentTime()
    AppInsightLogger.InstrumentedFunction((Unit) =>processPaths(rdd.map(BlobPointerInput.parseBlobPath), batchTime, batchInterval, currentTime, ""), "UncaughtException")
  }
}
