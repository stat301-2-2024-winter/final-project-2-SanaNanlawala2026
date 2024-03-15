## Basic repo setup for final project

This project focuses on doing regression modeling to predict the score of anime series' on a collection of data on animes and their score, ranking, # of episodes, etc. 

Directory: 

Folders:
- data : consists of the original dataset ('anime-filtered.csv') and the cleaned dataset ('clean.csv')

- exploration_results : contains autoplots of all the different parameter ranges that were used for the different models to find the best parameter to tune to. It also contains graphs used for the EDA of the dataset on the outcome variable, missingness, and more to inform the creation of the recipes. It also contains the saved out best parameters for each tuned model. 

- memos : contains qmd and corresponding html files on Progress Memo 1 and 2. 

- results: contains the split data as well as the folded data. Also contains the 4 different recipes, all of the fits and tuned models on the folds, the final fitting of the winning model, the predicted values when fitting the winning model on the testing data, and tables that contain the RMSE values of all models (meant to be compared)

- R_Scripts: Contains R scripts for every fitting (for each model), the initial exploration of the dataset, the data cleaning, the recipe creation, the setup of splitting data, the model analysis, training the best model, and for assessing the best model. 

Other Files:

Contains the final report combining all of the work, both in qmd and html format! 
