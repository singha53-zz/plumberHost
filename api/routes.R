# Libs
library(tidyverse)
library(jsonlite)
library(caret)

#' Default GET route.
#' @get /
function() {
  list(status = "OK")
}

#* @filter cors
cors <- function(req, res) {

  res$setHeader("Access-Control-Allow-Origin", "*")

  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods","*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }

}

#' Return the sum of two numbers
#' @param data expression data
#' @param outcome response variable
#' @param key API key
#' @post /enet
function(data, outcome, key){
  print(as.matrix(data)[1:5,1:5])
  print(factor(outcome))
  #print(fromJSON(outcome))
  print(class(key))
  if(key == "pwd"){
    ctrl <- trainControl(method = "repeatedcv",
      number = 5,
      repeats = 5,
      summaryFunction = twoClassSummary,
      classProbs = TRUE,
      savePredictions = TRUE)

  # Build a standard classifier using an elastic net
  set.seed(2)
  Xtrain <- apply(data, 2, as.numeric)
  print(Xtrain[1:5,1:5])
  trainClasses <- factor(outcome)
  orig_fit <- train(Xtrain, trainClasses,
    preProc=c("center", "scale"),
    method = "glmnet",
    intercept=TRUE,
    metric = "ROC",
    trControl = ctrl)
  # Cross valiation results
  result <- orig_fit$results %>% 
    filter(alpha == orig_fit$bestTune$alpha,
    lambda == orig_fit$bestTune$lambda)
  # selecte variables
  panels <- names(which(as.matrix(coef(orig_fit$finalModel, orig_fit$bestTune$lambda))[-1, ] != 0))

  ## compute pcs on selected data
  pr <- prcomp(t(Xtrain), center = TRUE, scale. = TRUE)
  scatterData = list(
  list(id = unbox(levels(trainClasses)[1]), 
    data = unbox(as.data.frame(pr$rotation)[trainClasses == levels(trainClasses)[1], 1:2])),
  list(id = unbox(levels(trainClasses)[2]), 
    data = unbox(as.data.frame(pr$rotation)[trainClasses == levels(trainClasses)[2], 1:2])))
  # scatterData = list(
  # list(id = unbox(levels(trainClasses)[1]), 
  #   data = toJSON(as.data.frame(pr$rotation)[trainClasses == levels(trainClasses)[1], 1:2], auto_unbox = TRUE, pretty = FALSE)),
  # list(id = unbox(levels(trainClasses)[2]), 
  #   data = toJSON(as.data.frame(pr$rotation)[trainClasses == levels(trainClasses)[2], 1:2], auto_unbox = TRUE, pretty = FALSE)))
  

  # send result back to user
  list(n=nrow(Xtrain), 
       p=ncol(Xtrain), 
       p_selected = length(panels), 
       auc=paste0(round(result$ROC*100, 1), "%"), 
       perf=paste(paste0(round(result$Sens*100, 1), "%"), paste0(round(result$Spec*100, 1), "%"), sep="/"), 
       panels=panels, 
       scatterData=scatterData)

  } else {
    "Wrong API key used!"
  }
}