# -*- coding: utf-8 -*-
"""
Created on Fri Jan 24 10:28:01 2020

@author: Robert Schuldt

MLR Model Random Forest
"""


import pandas as pd 

from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.ensemble import RandomForestClassifier

from sklearn.metrics import f1_score
from sklearn.model_selection import train_test_split

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
X = data_set.drop(columns =['ZIP_CD','event', 'ffs', 'missing', 'count', 'M0100_ASSMT_REASON', 'density_zip', 'fips', 
                            'BENE_ID', 'fips_state', 'total_medicare_expenditure', 'density_zip_codes_2',  'index', 'other', 'part_dual'])

    #Desscribe my X list of vars                       
varlist = X.describe()
    #Define the features in my feature importance set
feature_names= list(X.columns.values)

y = data_set[['event']]

y.describe()
id_y = y['event'].value_counts() 


# Split the data set into test and training'''
X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.3, shuffle=True, random_state = 42)

#However now I want to undersample my training sets as to try and create a better model
from imblearn.under_sampling import RandomUnderSampler
from sklearn.model_selection import cross_validate

undersample = RandomUnderSampler(sampling_strategy= 'majority', random_state = 173)
X_under, y_under = undersample.fit_sample(X_train, y_train)

#For making graphics down the line my X value
a_parameter_name = 'N Estimators'
b_parameter_name = 'Splits'
c_parameter_name = 'Leaf'
d_parameter_name = 'Depth'
e_parameter_name = 'Criterion'
f_parameter_name = 'Max_Features'

#create graphics and vars for testing best selection of criteria for hyperparms
n_estimators = [ 40, 60, 80, 100, 120, 140] #120
splits = [2, 3, 4, 5 ] #2
leaves = [  0.1, 0.01, 0.001, 0.0001 ] #0.0003
depth = [ 20, 40, 60, 80, 100 ] #22
criterion = ['gini', 'entropy']
features =  ['auto', 'sqrt', 'log2' ]

#Creating empty data frames to place my scores and images into. 

f1score = []
df = pd.DataFrame(columns=[a_parameter_name, b_parameter_name, c_parameter_name, d_parameter_name, 'F1 Score'])

model_acc = pd.DataFrame(columns = ['acc', 'Estimators', 'Splits', 'Leaves', 'Depth', 'F1', 'Precision', 'Features', 'criterion'])
#Create a collection of feature importanec scores
feature_collection = list(X.columns.values)
feature_collection = pd.DataFrame(feature_collection)
feature_collection = feature_collection.set_index([0])
 
           
for estimators  in n_estimators:
    for x in splits:
        for y in leaves:
            for z in depth:
                for crit in criterion: 
                    for feat in features:
                                 
                
                
                        clf = RandomForestClassifier(n_estimators = estimators, 
                        random_state = 42,
                        verbose = 1,
                        max_features = 'auto',
                        min_samples_split = x ,
                        min_samples_leaf = y,
                        criterion = crit,
                        oob_score = True,
                        n_jobs = 4,
                        max_depth = z,
                        bootstrap=True,)
                                                                 
                                                                 
                                                    
                                                     
                                                     
                                                                                 
                                                     
                        clf.fit(X_under, y_under.values.ravel())
                        train_pred= clf.predict(X_under)
                        y_pred= clf.predict(X_test)
                        feature_imp = pd.Series(clf.feature_importances_ , index= feature_names).sort_values(ascending=False)
                        feature_imp = pd.DataFrame(feature_imp)
                        feature_collection= feature_collection.merge(feature_imp, how ='outer', left_index = True, right_index=True)
                        
                        
                        cv = cross_validate(clf, X_under, y_under.values.ravel(), cv = 10, scoring='precision')
                        print(cv['test_score'])
                        means =cv['test_score'].mean()
                        
                        
        
        
        
                        acc = accuracy_score(y_test, y_pred)
                       
                        print("Accuracy of %s is %s"%(clf, acc))
                        cm = confusion_matrix(y_test, y_pred)
                        print("Confusion Matrix of %s is %s"%(clf, cm))
                        score = f1_score(y_test, y_pred,  average= 'weighted') 
                        print("This is the F1 Score " + str(score))
                        model_acc = model_acc.append({'acc' : acc, 'Estimators' : estimators, 'Splits' : x, 'Leaves': y, 'Depth': z, 'F1' : score, 'Precision' : means, 'Features': feat, 'criterion': crit}, ignore_index=True)           
                        print("This is the Precision Score "+str( cv['test_score'].mean()))
                       

                   
                        feature_collection.to_csv('Z:\\DATA\\Dissertation\\Data\\feature_imp_matrix.csv' )
                        model_acc.to_csv('Z:\\DATA\\Dissertation\\Data\\models.csv' )