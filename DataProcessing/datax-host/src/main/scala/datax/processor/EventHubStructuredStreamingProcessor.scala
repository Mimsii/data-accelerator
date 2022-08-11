// *********************************************************************
// Copyright (c) Microsoft Corporation.  All rights reserved.
// Licensed under the MIT License
// *********************************************************************
package datax.processor

import datax.telemetry.AppInsightLogger
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.streaming.StreamingQuery

class EventHubStructuredStreamingProcessor(processDataFrame: DataFrame=>Map[String, StreamingQuery])
  extends StructuredStreamingProcessor {
  override val process: DataFrame => Map[String, StreamingQuery] = AppInsightLogger.InstrumentedFunction((Unit) => processDataFrame, "UncaughtException")
}
