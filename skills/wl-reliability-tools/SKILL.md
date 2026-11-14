---
name: wl-reliability-tools
description: Use AntonAntonov/ReliabilityTools in Wolfram Language for Weibull reliability modeling, anomaly detection, failure forecasting, and supported data ingestion. Apply when the task specifically needs this paclet rather than general built-in WL statistics or plotting.
---

# WL-ReliabilityTools

Use this skill for Wolfram Language tasks involving the `AntonAntonov/ReliabilityTools` paclet. Load the public context before calling its functions:

```wl
Needs["AntonAntonov`ReliabilityTools`"]
```

Do not add `PacletInstall` to ordinary code unless installation is explicitly requested or the user has authorized changing the local paclet environment. Treat the two documents identified below as workflows, not function documentation. Read the relevant supplied reference before writing code that calls a paclet function; signatures, string-valued options, and property names are case-sensitive.

## Choose the workflow

- For a Weibull model of failure times or production measurements, start with `WeibullReliabilityModel`, inspect the returned `ReliabilityModel` object when the user needs fitted values or breakpoints, and use `WeibullReliabilityPlot` for the probability plot. Read [WeibullReliabilityModel](references/WeibullReliabilityModel.md), [ReliabilityModel](references/ReliabilityModel.md), and [WeibullReliabilityPlot](references/WeibullReliabilityPlot.md).
- For point anomalies, use `AnomalyFinder` as the general entry point. It can return anomalies, count, Boolean flags, positions, or non-anomalies. Use the simple method for one-dimensional outlier identification; use the GNNMon workflow when a windowed nearest-neighbor detector is intended. Read [AnomalyFinder](references/AnomalyFinder.md) first, then [SimpleAnomalyDetection](references/SimpleAnomalyDetection.md) or [GNNMonAnomalyDetection](references/GNNMonAnomalyDetection.md) and [GNNMonAnomalyDetector](references/GNNMonAnomalyDetector.md).
- Use `AnomalyDetectionInterface` only when an interactive `Manipulate` interface is desired, not in a noninteractive or batch workflow. See [AnomalyDetectionInterface](references/AnomalyDetectionInterface.md).
- For fault-arrival forecasting, use `CrowAMSAAForecast`; for the corresponding growth visualization, use `GrowthTrackingPlot`. Read [CrowAMSAAForecast](references/CrowAMSAAForecast.md) and [GrowthTrackingPlot](references/GrowthTrackingPlot.md).
- For source-specific import, use `IngestSeeqData` for Seeq XLSX files and request a documented form such as `"Dataset"`, `"TimeSeries"`, `Automatic`, or `All`. The available XML reference only establishes that `IngestXMLData` is for XML-to-dataset ingestion; inspect it before relying on an unlisted calling form. See [IngestSeeqData](references/IngestSeeqData.md) and [IngestXMLData](references/IngestXMLData.md).

## Weibull modeling

`WeibullReliabilityModel[data]` accepts a numeric list of failure times or production values and returns a `ReliabilityModel`. Prefer this two-step form when the model will be reused:

```wl
model = WeibullReliabilityModel[data];
WeibullReliabilityPlot[model, PlotTheme -> "Failure"]
```

For production data, `PlotTheme -> "Production"` is the documented default. Query only documented object properties—`"Properties"`, `"Association"`, `"OriginalData"`, `"Data"`, `"WeibullParameters"`, `"Breaks"`, and `"MaxBreakPoint"`—and inspect `model["Properties"]` if the requested property is uncertain.

Structural-break behavior is data-sensitive. Explain and expose tuning when it matters: `"Breaks"`, `"Knots"`, `"NearestWithOutliers"`, `"NumberOfProximityPoints"`, `Probabilities`, `InterpolationOrder`, and `Method`. Select a displayed breakpoint with the plot option **`"BreakPoint"`** (capital `P`), whose documented values include `Automatic`, `Max`, `First`, `Last`, and a positive integer. Do not silently discard observations to force an expected break; present removal of low values as a modeling choice and preserve the original data.

For a complete production-line example, including model refinement and tracking breakpoints across yearly data, read the tech note [Weibull Reliability Modeling for Plant Production](references/Weibull-Reliability-Modeling-for-Plant-Production.md).

## Anomaly detection

Use the least specialized supported method that answers the request:

- For scalar sequences, `Method -> "Simple"` uses one-dimensional outlier identification.
- For neighborhood/window structure, `Method -> "GNNMon"` uses geometric nearest neighbors. Its detector supports `WindowSize`, `DistanceFunction`, `"AggregationFunction"`, and `"NumberOfNearestNeighbors"` as well as `"OutlierIdentifier"`.
- The documented outlier identifiers are `Automatic`, `"Hampel"`, `"SPLUSQuartile"`, and `"Quartile"`. Preserve the user's intended method and thresholding choice rather than changing defaults without saying so.

When overlaying anomalies on a time-series plot, keep timestamps and values aligned. The financial-series tech note demonstrates splitting a `TimeSeries` into training and testing data, requesting `"AnomalyPositions"`, and indexing the testing segment for the overlay. Read [Outlier detection for financial time series](references/Outlier-detection-for-financial-time-series.md) for that workflow.

## Reference boundaries

The following are **tech notes** and should be used for their end-to-end domain workflows:

- [Outlier detection for financial time series](references/Outlier-detection-for-financial-time-series.md)
- [Weibull Reliability Modeling for Plant Production](references/Weibull-Reliability-Modeling-for-Plant-Production.md)

All other Markdown files in `references/` are function pages. Do not infer undocumented options or forms from a neighboring function page. The function pages mention underlying paclets for GNNMon and quantile-regression internals; do not load or install those underlying paclets merely to use the public ReliabilityTools functions. Use them directly only if the user explicitly asks to work with those lower-level APIs.
