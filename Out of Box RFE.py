# -*- coding: utf-8 -*-
"""
Created on Mon Sep 28 12:56:14 2020

@author: 3043340
"""


import pandas as pd 
import numpy as np
from numpy import where
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.ensemble import RandomForestClassifier
from matplotlib import pyplot
from sklearn.metrics import f1_score
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
                            'BENE_ID', 'fips_state','sample', 'total_medicare_expenditure', 'density_zip_codes_2',  'index', 'other', 'part_dual'])

    #Desscribe my X list of vars                       
varlist = X.describe()
    #Define the features in my feature importance set
feature_names= list(X.columns.values)

y = data_set[['event']]

y.describe()
id_y = y['event'].value_counts() 

# Split the data set into test and training'''
X_train, X_test, y_train, y_test = train_test_split(X,y,test_size=0.3, shuffle=True)


#However now I want to undersample my training sets as to try and create a better model
from imblearn.under_sampling import RandomUnderSampler
from sklearn.model_selection import cross_validate

undersample = RandomUnderSampler(sampling_strategy= 'majority')
X_under, y_under = undersample.fit_sample(X_train, y_train)

#Creating empty data frames to place my scores and images into. 

f1score = []



clf = RandomForestClassifier(n_estimators = 100, 
                                random_state = 42,
                                verbose = 1,
                                max_features = 'auto',
                                min_samples_split = 2,
                                min_samples_leaf = 1,
                                criterion = 'gini',
                                n_jobs = 4)
                                     
                                     
                        
                         
                         
                                                     
                         
clf.fit(X_train, y_train)
train_pred= clf.predict(X_train)
y_pred= clf.predict(X_test)

cv = cross_validate(clf, X_train, y_train, cv = 10, scoring='precision')

print(cv['test_score'].mean())

acc = accuracy_score(y_test, y_pred)
  
print("Accuracy of %s is %s"%(clf, acc))
cm = confusion_matrix(y_test, y_pred)
print("Confusion Matrix of %s is %s"%(clf, cm))
score = f1_score(y_test, y_pred,  average= 'weighted') 

f1score.append(score)
print(score)

#Create my feature importance matrix 


feature_imp = pd.Series(clf.feature_importances_ , index= feature_names).sort_values(ascending=False)
   
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


   
#visualize confusion Matrix
def plot_confusion_matrix(cm, 
                          target_names,
                          title='Figure 5. Confusion Matrix Of the Default Parameters',
                          cmap=None,
                          normalize = True):
    
    import matplotlib.pyplot as plt
    import itertools
    
   
  
    
    if cmap is None:
        cmap = plt.get_cmap('Blues')
        plt.figure(figsize=(8, 6), dpi = 300)
        plt.imshow(cm, interpolation='nearest', cmap=cmap)
        plt.title(title)
        
    
    if target_names is not None:
        tick_marks = np.arange(len(target_names))
        plt.xticks(tick_marks, target_names, rotation=45, fontsize=12  )
        plt.yticks(tick_marks, target_names, rotation=45, fontsize=12  )
    
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
    
    
    thresh = cm.max() / 1.5 if normalize else cm.max() / 2
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        if normalize:
            plt.text(j, i, "{:0.4f}".format(cm[i, j]),
                     horizontalalignment="center",
                     color="white" if cm[i, j] > thresh else "black")
        else:
            plt.text(j, i, "{:,}".format(cm[i, j]),
                     horizontalalignment="center",
                     color="white" if cm[i, j] > thresh else "black")
    
    
    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.show()



plot_confusion_matrix(cm = cm,
                      normalize = False,
                      target_names = ['No Event', 'Event'],
                      )





