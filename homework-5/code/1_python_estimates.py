import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
from scipy import stats
import statsmodels.api as sm
from datetime import date
from linearmodels import IVGMM

datapath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-5\data'
outputpath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-5\output'
np.random.seed(1)
data=pd.read_csv(datapath +'/instrumentalvehicles.csv')

'''
------------------------------------------------------------------------------
Q1.1: OLS of price on mpg
------------------------------------------------------------------------------
'''
ols1=sm.OLS(data['price'],sm.add_constant(data['mpg'])).fit()
print(ols1.summary())

'''
------------------------------------------------------------------------------
Q1.3.(a): 2SLS of price on mpg using weight as instrument
------------------------------------------------------------------------------
'''
# First stage mpg on weight (instrument) and car type
first_stage_a=sm.OLS(data['mpg'],sm.add_constant(data[['weight','car']])).fit()
data['mpg_hat_a']=first_stage_a.predict(sm.add_constant(data[['weight','car']]))
f_stat_a=first_stage_a.fvalue
second_stage_a=sm.OLS(data['price'],sm.add_constant(data[['mpg_hat_a','car']])).fit()
beta_a=second_stage_a.params
se_a=second_stage_a.HC1_se

'''
------------------------------------------------------------------------------
Q1.3.(b): 2SLS of price on mpg using weight^2 as instrument
------------------------------------------------------------------------------
'''
# Generate variables weight^2
data['weight2']=data['weight']**2

# First stage mpg on weight (instrument) and car type
first_stage_b=sm.OLS(data['mpg'],sm.add_constant(data[['weight2','car']])).fit()
data['mpg_hat_b']=first_stage_b.predict(sm.add_constant(data[['weight2','car']]))
f_stat_b=first_stage_b.fvalue
second_stage_b=sm.OLS(data['price'],sm.add_constant(data[['mpg_hat_b','car']])).fit()
beta_b=second_stage_b.params
se_b=second_stage_b.HC1_se

'''
------------------------------------------------------------------------------
Q1.3.(c): 2SLS of price on mpg using height as instrument
------------------------------------------------------------------------------
'''
# First stage mpg on weight (instrument) and car type
first_stage_c=sm.OLS(data['mpg'],sm.add_constant(data[['height','car']])).fit()
data['mpg_hat_c']=first_stage_c.predict(sm.add_constant(data[['height','car']]))
f_stat_c=first_stage_c.fvalue
second_stage_c=sm.OLS(data['price'],sm.add_constant(data[['mpg_hat_c','car']])).fit()
beta_c=second_stage_c.params
se_c=second_stage_c.HC1_se

report_table=pd.DataFrame(
    {'(a)': ["{:0.2f}".format(beta_a['mpg_hat_a']), "({:0.2f})".format(se_a['mpg_hat_a']), 
             "{:0.2f}".format(beta_a['car']), "({:0.2f})".format(se_a['car']),
             "Weight","{:0.2f}".format(f_stat_a)],
     '(b)': ["{:0.2f}".format(beta_b['mpg_hat_b']), "({:0.2f})".format(se_b['mpg_hat_b']), 
             "{:0.2f}".format(beta_b['car']), "({:0.2f})".format(se_b['car']),
             "Weight$^2$","{:0.2f}".format(f_stat_b)],
     '(c)': ["{:0.2f}".format(beta_c['mpg_hat_c']), "({:0.2f})".format(se_c['mpg_hat_c']), 
             "{:0.2f}".format(beta_c['car']), "({:0.2f})".format(se_c['car']),
             "Height","{:0.2f}".format(f_stat_c)]},
     index=['Miles per gallon', ' ',
            '=1 if the vehicle is sedan', ' ',
            '\midrule Instrumental variable',
            'First Stage F-statistic'])
report_table.to_latex(outputpath + '/table/2SLS.tex', column_format='lccc', float_format="%.2f", escape=False)

'''
------------------------------------------------------------------------------
Q1.3.(d): Exclusion Restriction
------------------------------------------------------------------------------
'''
# Plot height vs car type
plt.clf()
sns.scatterplot(x='car',y='height',data=data)
plt.title('Height of the Vehicle by Car Type')
# Change the x-axis to only show 1 and 0
plt.xticks([0,1],['SUV','Sedan'])
# Scale so that the x-axis is not too wide
plt.xlim(-0.5,1.5)
plt.xlabel('Car Type')
plt.ylabel('Height of the Vehicle')
plt.savefig(outputpath + '/figure/exclusion_restriction_1.pdf')

# Plot weight vs car type
plt.clf()
sns.scatterplot(x='car',y='weight',data=data)
plt.title('Weight of the Vehicle by Car Type')
# Change the x-axis to only show 1 and 0
plt.xticks([0,1],['SUV','Sedan'])
# Scale so that the x-axis is not too wide
plt.xlim(-0.5,1.5)
plt.xlabel('Car Type')
plt.ylabel('Weight of the Vehicle')
plt.savefig(outputpath + '/figure/exclusion_restriction_2.pdf')

# Plot weight2 vs car type
plt.clf()
sns.scatterplot(x='car',y='weight2',data=data)
plt.title('Weight$^2$ of the Vehicle by Car Type')
# Change the x-axis to only show 1 and 0
plt.xticks([0,1],['SUV','Sedan'])
# Scale so that the x-axis is not too wide
plt.xlim(-0.5,1.5)
plt.xlabel('Car Type')
plt.ylabel('Weight$^2$ of the Vehicle')
plt.savefig(outputpath + '/figure/exclusion_restriction_3.pdf')

'''
------------------------------------------------------------------------------
Q1.4: IVGMM of price on mpg using weight as instrument
------------------------------------------------------------------------------
'''
iv_gmm=IVGMM(data['price'],sm.add_constant(data['car']),data['mpg'],data['weight']).fit()
beta_gmm=iv_gmm.params
se_gmm=iv_gmm.std_errors

report_table=pd.DataFrame(
    {'By Hand 2SLS': ["{:0.2f}".format(beta_a['mpg_hat_a']), "({:0.2f})".format(se_a['mpg_hat_a']), 
             "{:0.2f}".format(beta_a['car']), "({:0.2f})".format(se_a['car'])],
     'IVGMM': ["{:0.2f}".format(beta_gmm['mpg']), "({:0.2f})".format(se_gmm['mpg']), 
             "{:0.2f}".format(beta_gmm['car']), "({:0.2f})".format(se_gmm['car'])]},
     index=['Miles per gallon', ' ',
            '=1 if the vehicle is sedan', ' '])
report_table.to_latex(outputpath + '/table/2SLS_IVGMM.tex', column_format='lcc', float_format="%.2f", escape=False)