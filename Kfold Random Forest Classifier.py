# -*- coding: utf-8 -*-
"""
Created on Thu Sep 10 13:26:05 2020

@author: 3043340
"""


import pandas as pd 
import numpy as np
from numpy import where
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.ensemble import RandomForestClassifier
from matplotlib import pyplot

from nested_cv import NestedCV

from sklearn.model_selection import train_test_split
import seaborn as sns
#Need tim port my files in chunks because it is a large data set
csv_file = "Z:\\DATA\\Dissertation\\Python\\MLR Testing2.csv"
c_size = 50000

data_set = pd.DataFrame()
#This loop imports data at 50K at a time until full file is read in. Keeps headers
for gm_chunk in pd.read_csv(csv_file, chunksize=c_size, header= 0, low_memory=False):
    data_set = data_set.append(gm_chunk)
    print(gm_chunk.shape)
   

#view what my data looks like
view = data_set.describe()    

#I can label my target names
target_names = ['No_bad', 'event']


#These are variables that I do not need in the data set. 
X = data_set.drop(columns =['ZIP_CD','event', 'ffs', 'missing', 'count', 'M0100_ASSMT_REASON', 'hha_count', 'density_zip', 'fips', 
                            'BENE_ID', 'fips_state', 'total_medicare_expenditure', 'density_zip_codes_2',  'index', 'other', 'part_dual'])

    #Desscribe my X list of vars                       
varlist = X.describe()
    #Define the features in my feature importance set
feature_names= list(X.columns.values)

# example of random undersampling to balance the class distribution
from collections import Counter
y = data_set[['event']]

print(Counter(y['event']))

y.describe()
id_y = y['event'].value_counts() 

# Split the data set into test and training'''
X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.3, shuffle=True)



print(Counter(y_under['event']))

#Define the features in my feature importance set
feature_names= list(X.columns.values)
feature_meaures = []

from sklearn.model_selection import cross_validate

parameter_grid = [
   { #1st need to identify my N EStimators
    'n_estimators':[10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 13, 140 , 150 ],
    'max_features': ['auto', 'sqrt', 'log2' ],
    'min_samples_split' : [ 2, 3, 4],
    'min_samples_leaf': [0.1, 0.01, 0.0001, 0.00003],
    'criterion': ['gini', 'entropy'],
    'max_depth': [20, 22, 24, 30, 40],
    'bootstrap': [True, False],
    }
   ]

models_to_run = [RandomForestClassifier()]

for i, model in enumerate(models_to_run):
    nested_CV_search = NestedCV(model=model, params_grid = parameter_grid[i],
                                outer_kfolds=5, inner_kfolds=5, 
                                cv_options={'sqrt_of_score': True, 'randomized_search_iter' :30})
    
    nested_CV_search.fit(X= X_under,y= y_under)
    model_param_grid = nested_CV_search.best_params
    
    print(np.mean(nested_CV_search.outer_scores))
    print(nested_CV_search.best_inner_params_list)
    
  

        
        clf.fit(X_under, y_under)                            
        train_pred= clf.predict(X_under)
        y_pred= clf.predict(X_test)
        acc = accuracy_score(y_test, y_pred)
        print("Accuracy of %s is %s"%(clf, acc))
        cm = confusion_matrix(y_test, y_pred)
        print("Confusion Matrix of %s is %s"%(clf, cm))
        
        
        
                    
        feature_imp = pd.Series(clf.feature_importances_ , index= feature_names).sort_values(ascending=False)
        feature_meaures.append(feature_imp)
        import matplotlib.pyplot as plt
        
        
        #create a bar plot of features
        
        feature_plot = sns.barplot(x=feature_imp, y=feature_imp.index)
        #add labels
        
        plt.xlabel('Feature Importance Score')
        plt.ylabel('Features')
        plt.tick_params(axis= 'y', which= 'major', pad = 10)
        plt.title("Visualizing Important Features")
        plt.legend
        plt.tight_layout()
        plt.show(feature_plot)
        plt.figure(figsize = (12, 12))
        plt.rcParams["ytick.labelsize"] = 3
        feature_plot.figure.savefig('Z:\\DATA\\Dissertation\\Python\\feature_importance.png', dpi = 300)
        
        
        
        
        #Now I am going to attempt Cross Validations
        
        cv = cross_validate(clf, X_under, y_under, cv = 10, scoring='precision')
        
        print(cv['test_score'])
        print(cv['test_score'].mean())
