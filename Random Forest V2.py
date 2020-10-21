# -*- coding: utf-8 -*-
"""
Created on Fri Jan 24 10:28:01 2020

@author: Robert Schuldt

MLR Model Random Forest
"""


import pandas as pd 
import numpy as np

from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.ensemble import RandomForestClassifier

from sklearn.metrics import f1_score
from sklearn.model_selection import train_test_split
import seaborn as sns

from sklearn.preprocessing import StandardScaler



#Need tim port my files in chunks because it is a large data set
csv_file = "Z:\\DATA\\Dissertation\\Python\\MLR Testing3.csv"
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






#create graphics and vars for testing best selection of criteria for hyperparms
n_estimators = [ 140] #120
splits = [2] #2
leaves = [ 0.0001 ] #0.0003
depth = [ 20 ] #22
#Creating empty data frames to place my scores and images into. 

f1score = []


feature_meaures = []
for estimators  in n_estimators:
    for x in splits:
        for y in leaves:
            for z in depth:
                    clf = RandomForestClassifier(n_estimators = estimators, 
                    random_state = 42,
                    verbose = 1,
                    max_features = 'sqrt',
                    min_samples_split = x ,
                    min_samples_leaf = y,
                    criterion = 'entropy',
                    oob_score = True,
                    n_jobs = 4,
                    max_depth = z,
                    bootstrap=True,)
                                                             
                                                             
                                                
                                                 
                                                 
                                                                             
                                                 
                    clf.fit(X_under, y_under)
                    train_pred= clf.predict(X_under)
                    y_pred= clf.predict(X_test)
                    
                    cv = cross_validate(clf, X_under, y_under, cv = 10, scoring='precision')
        
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
                    feature_plot.figure.savefig('Z:\\DATA\\Dissertation\\Python\\feature_importance'+str(estimators)+'.png', dpi = 300)
                    
                    print("This is the Precision Score "+str( cv['test_score'].mean()))
                    print("This is the F1 Score " + str(score))
    
                   
                    
#                     df = df.append({a_parameter_name: estimators, b_parameter_name: x, 
#                                    c_parameter_name: y, 'accuracy' : score}, ignore_index=True)
                    
    
    

# def plot_acc(meas):
    
#     plt.figure(figsize=(12,6))
#     sns.pointplot(x=meas, y="accuracy", data=df)
#     title = 'Model F1 Score(%) vs '+str(meas)+' parameter'
#     plt.title(title)
#     plt.xticks(rotation= 90)
#     plt.grid()

# plot_acc(a_parameter_name)
# plot_acc(b_parameter_name)
# plot_acc(c_parameter_name)
# plot_acc(d_parameter_name)


#visualize confusion Matrix
def plot_confusion_matrix(cm, 
                          target_names,
                          title='Figure 6. Confusion Matrix Of the Final Model',
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



#Convert features to dataframe

feature_data = feature_imp.to_csv('Z:\\DATA\\Dissertation\\Data\\feature_imp_final_model.csv')

 
from sklearn.linear_model import LogisticRegression




clf2 = LogisticRegression(random_state = 42, max_iter = 250)
clf2.fit(X_under, y_under)

#now predict my test
y_pred2 = clf2.predict(X_test)

acc = clf2.score(X_test, y_test)


score2 = f1_score(y_test, y_pred2,  average= 'weighted')  


cv2 = cross_validate(clf2, X_under, y_under, cv = 10, scoring='precision')

cm2 = confusion_matrix(y_test, y_pred2)

feature_log= pd.DataFrame(list(X_under.columns.values))

log_importance = clf2.coef_[0]
for i, v in enumerate(log_importance):
    print('Feature: %0d, Score: %.5f' % (i,v))
    
log_importance = pd.DataFrame(log_importance)

feature_log_set = feature_log.merge(log_importance, how='outer', left_index=True , right_index=True)

print("This is the accuracy of the model " +str(acc))
print("This is the F1 Score of the model " +str(score2))
print("This is the Precision Score "+str( cv2['test_score'].mean()))
plot_confusion_matrix(cm = cm2,
                      normalize = False,
                      target_names = ['No Event', 'Event'],
                      title = 'Figure 9. Logistic Classifier Confusion Matrix')

