connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "duckdb", 
  server = "data/database-1M_filtered.duckdb"
)

covariateSettings <- FeatureExtraction::createCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useConditionGroupEraLongTerm = TRUE,
  useDrugGroupEraLongTerm = TRUE,
  longTermStartDays = -730,
  endDays = -1
)

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  cdmDatabaseName = "Synthea",
  cdmDatabaseId = "synthea",
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = "main",
  cohortDatabaseSchema = "main",
  cohortTable = "cohort",
  targetId = 1782815,
  outcomeDatabaseSchema = "main",
  outcomeTable = "cohort",
  outcomeIds = 1782813
)

restrictPlpDataSettings <- PatientLevelPrediction::createRestrictPlpDataSettings()

populationSettings <- PatientLevelPrediction::createStudyPopulationSettings(
  washoutPeriod = 729,
  removeSubjectsWithPriorOutcome = TRUE,
  priorOutcomeLookback = 9999,
  riskWindowStart = 1,
  riskWindowEnd = 60, 
  minTimeAtRisk = 59,
  startAnchor = 'cohort start',
  endAnchor = 'cohort start',
  requireTimeAtRisk = TRUE,
  includeAllOutcomes = TRUE
)

splitSettings <- PatientLevelPrediction::createDefaultSplitSetting(
  trainFraction = 0.75,
  testFraction = 0.25,
  type = 'stratified',
  nfold = 3, 
  splitSeed = 1234
)

sampleSettings <- PatientLevelPrediction::createSampleSettings()

featureEngineeringSettings <- PatientLevelPrediction::createFeatureEngineeringSettings()

preprocessSettings <- PatientLevelPrediction::createPreprocessSettings(
  minFraction = .01,
  normalize = TRUE,
  removeRedundancy = TRUE
)


lrModel <- PatientLevelPrediction::setLassoLogisticRegression()

plpData <- PatientLevelPrediction::getPlpData(
  databaseDetails = databaseDetails,
  covariateSettings = covariateSettings,
  restrictPlpDataSettings = restrictPlpDataSettings
)
# 
# PatientLevelPrediction::savePlpData(
#   plpData = plpData,
#   file = "data/plpData"
# )

# plpData <- PatientLevelPrediction::loadPlpData("data/plpData")

lrResults <- PatientLevelPrediction::runPlp(
  plpData = plpData,
  outcomeId = 1782813, 
  analysisId = "single_model",
  analysisName = "Demonstration of runPlp for training single PLP models",
  populationSettings = populationSettings, 
  splitSettings = splitSettings,
  sampleSettings = sampleSettings, 
  featureEngineeringSettings = featureEngineeringSettings, 
  preprocessSettings = preprocessSettings,
  modelSettings = lrModel,
  logSettings = PatientLevelPrediction::createLogSettings(), 
  executeSettings = PatientLevelPrediction::createExecuteSettings(
    runSplitData = TRUE, 
    runSampleData = TRUE, 
    runfeatureEngineering = TRUE, 
    runPreprocessData = TRUE, 
    runModelDevelopment = TRUE, 
    runCovariateSummary = TRUE
  ), 
  saveDirectory = file.path(getwd(), "results")
)

# PatientLevelPrediction::viewPlp(lrResults)

lrResults <- PatientLevelPrediction::loadPlpResult(
  dirPath = "results/single_model/plpResult/"
)

PatientLevelPrediction::viewPlp(lrResults)
