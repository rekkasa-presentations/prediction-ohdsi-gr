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
  firstExposureOnly = FALSE,
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

modelDesignLasso <- PatientLevelPrediction::createModelDesign(
  targetId = 1782815, 
  outcomeId = 1782813, 
  restrictPlpDataSettings = restrictPlpDataSettings, 
  populationSettings = populationSettings, 
  covariateSettings = covariateSettings, 
  featureEngineeringSettings = featureEngineeringSettings,
  sampleSettings = sampleSettings, 
  splitSettings = splitSettings, 
  preprocessSettings = preprocessSettings, 
  modelSettings = PatientLevelPrediction::setLassoLogisticRegression()
)

modelDesignGradientBoosting <- PatientLevelPrediction::createModelDesign(
  targetId = 1782815, 
  outcomeId = 1782813, 
  restrictPlpDataSettings = restrictPlpDataSettings, 
  populationSettings = populationSettings, 
  covariateSettings = covariateSettings, 
  featureEngineeringSettings = featureEngineeringSettings,
  sampleSettings = sampleSettings, 
  splitSettings = splitSettings, 
  preprocessSettings = preprocessSettings, 
  modelSettings = PatientLevelPrediction::setGradientBoostingMachine()
)

results <- PatientLevelPrediction::runMultiplePlp(
  databaseDetails = databaseDetails, 
  modelDesignList = list(
    modelDesignLasso, 
    modelDesignGradientBoosting
  ), 
  onlyFetchData = FALSE,
  logSettings = PatientLevelPrediction::createLogSettings(),
  saveDirectory =  file.path(getwd(), "results/multiple_models")
)

PatientLevelPrediction::viewMultiplePlp("results/multiple_models")
