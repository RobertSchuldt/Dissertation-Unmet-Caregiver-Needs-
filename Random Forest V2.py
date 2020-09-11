# -*- coding: utf-8 -*-
"""
Created on Fri Jan 24 10:28:01 2020

@author: Robert Schuldt

MLR Model Random Forest
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
                            'BENE_ID', 'fips_state', 'total_medicare_expenditure', 'density_zip_codes_2',  'index', 'other', 'part_dual'])

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

#For making graphics down the line my X value
a_parameter_name = 'N Estimators'
b_parameter_name = 'Splits'
c_parameter_name = 'Leaf'
d_parameter_name = 'Depth'

#create graphics and vars for testing best selection of criteria for hyperparms
n_estimators = [ 20, 40, 60, 80, 100, 120, 140] #120
splits = [2, 3, 4, 5, 6] #2
leaves = [  0.1, 0.01, 0.001, 0.0001 ] #0.0003
depth = [ 20, 40, 60, 80, 100 ] #22
#Creating empty data frames to place my scores and images into. 

model_acc = pd.DataFrame(columns = ['Acc', 'Esimator', 'splits', 'leaves', 'depth', 'F1'])
f1score = []
df = pd.DataFrame(columns=[a_parameter_name, b_parameter_name, c_parameter_name, d_parameter_name, 'F1 Score'])

#Create a collection of feature importanec scores
feature_collection = feature_names
feature_collection = pd.Series(index= feature_names)


feature_meaures = []
for estimators  in n_estimators:
    for x in splits:
        for y in leaves:
            for z in depth:
                    clf = RandomForestClassifier(n_estimators = estimators, 
                    random_state = 42,
                    verbose = 1,
                    max_features = 'auto',
                    min_samples_split = x ,
                    min_samples_leaf = y,
                    criterion = 'gini',
                    oob_score = True,
                    n_jobs = 4,
                    max_depth = 22,
                    bootstrap=True,)
                                                             
                                                             
                                                
                                                 
                                                 
                                                                             
                                                 
                    clf.fit(X_under, y_under)
                    train_pred= clf.predict(X_under)
                    y_pred= clf.predict(X_test)
                    
                    cv = cross_validate(clf, X_under, y_under, cv = 10, scoring='precision')
        
                    acc = accuracy_score(y_test, y_pred)
                    model_acc['Acc'].append(acc)
                    model_acc['Esimator'].append(estimators)
                    model_acc['splits'].append(x)
                    model_acc['leaves'].append(y)
                    
                    print("Accuracy of %s is %s"%(clf, acc))
                    cm = confusion_matrix(y_test, y_pred)
                    print("Confusion Matrix of %s is %s"%(clf, cm))
                    score = f1_score(y_test, y_pred,  average= 'weighted') 
                    model_acc['F1'].append(score)
                    f1score.append(score)
                    print(score)
    
    #Create my feature importance matrix 
            
            
                    feature_imp = pd.Series(clf.feature_importances_ , index= feature_names).sort_values(ascending=False)
                    feature_meaures.append(feature_imp)
                    feature_collection= feature_collection.merge(feature_imp, left_on=feature_names)
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
                    feature_plot.figure.savefig('Z:\\DATA\\Dissertation\\Python\\feature_importance'+str(estimators)+'.png', dpi = 300)
    
    
                   
                    
                    df = df.append({a_parameter_name: estimators, b_parameter_name: x, 
                                   c_parameter_name: y, 'accuracy' : score}, ignore_index=True)
                    
    
    

def plot_acc(meas):
    
    plt.figure(figsize=(12,6))
    sns.pointplot(x=meas, y="accuracy", data=df)
    title = 'Model F1 Score(%) vs '+str(meas)+' parameter'
    plt.title(title)
    plt.xticks(rotation= 90)
    plt.grid()

plot_acc(a_parameter_name)
plot_acc(b_parameter_name)
plot_acc(c_parameter_name)
plot_acc(d_parameter_name)


#visualize confusion Matrix
def plot_confusion_matrix(cm, 
                          target_names,
                          title='Confusion Matrix',
                          cmap=None,
                          normalize = True):
    
    import matplotlib.pyplot as plt
    import itertools
    
   
  
    
    if cmap is None:
        cmap = plt.get_cmap('Blues')
        plt.figure(figsize=(8, 6), dpi = 300)
        plt.imshow(cm, interpolation='nearest', cmap=cmap)
        plt.title(title)
        plt.colorbar()
    
    if target_names is not None:
        tick_marks = np.arange(len(target_names))
        plt.xticks(tick_marks, target_names, rotation=45)
        plt.yticks(tick_marks, target_names)
    
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
                      target_names = None,
                      title = 'Confusion Matrix')


#Convert features to dataframe

feature_data = feature_imp.to_csv('Z:\\DATA\\Dissertation\\Data\\feature_imp.csv')

 
from sklearn.linear_model import LogisticRegression

clf2 = LogisticRegression(random_state = 42)
clf2.fit(X_train, y_train)

#now predict my test
y_pred2 = clf2.predict(X_test)

acc = clf2.score(X_test, y_test)
print(acc)

score2 = f1_score(y_test, y_pred2,  average= 'weighted')  
print(score2)
