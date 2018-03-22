% You should put all your code for recognizing unknown actions in this file.
% Describe the method you used in YourMethod.txt.
% Don't forget to call SavePrediction() at the end with your predicted labels to save them for submission, then submit using submit.m
clear
load PA9Data;
predicted_labels = RecognizeUnknownActions_(datasetTrain3, datasetTest3, G, 10);
SavePredictions(predicted_labels)