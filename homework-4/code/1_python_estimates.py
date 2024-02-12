import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
from scipy import stats
import statsmodels.api as sm
from datetime import date


datapath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-4\data'
outputpath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-4\output'
np.random.seed(1)

'''
------------------------------------------------------------------------------
Q1
------------------------------------------------------------------------------
'''
# Read csv file
data=pd.read_csv(datapath +'/fishbycatch.csv')

# Convert wide to long
data_long=pd.wide_to_long(data, ["shrimp", "salmon", "bycatch"], i="firm", j="Month")
data_long=data_long.sort_values(by=['firm','Month'], ascending=True).reset_index()
data_long['month']= np.where(data_long['Month']%12==0,12,data_long['Month']%12)
data_long['year']= np.where(data_long['Month']<=12,2017,2018)
data_long['date'] = pd.to_datetime(data_long[['year', 'month']].assign(day=1))

# Create a new column for Treatment and Control groups
data_long['Group'] = np.where(data_long['treated'] == 1, "Treatment", "Control")

# Question 1
# Create line plot of bycatch over time
plt.clf()
sns.lineplot(data=data_long, x="date", y="bycatch", hue="Group")
plt.xlabel('Month')
plt.ylabel('Pounds of bycatch in a month')
plt.axvline(x=date(2018,1,1), color='r', linestyle='-', linewidth=1)
plt.xlim(date(2017,1,1), date(2018,12,1))
plt.ylim(50000, 250000)
# format date on x-axis to show month and year and lean the text
plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%b %Y'))
plt.savefig(outputpath + '/figure/paralleltrend.pdf',format='pdf')

# Question 2
treatment_pre=data_long[(data_long['month']==12) & (data_long['year']==2017) & (data_long['treated'] == 1)]['bycatch'].mean()
treatment_post=data_long[(data_long['month']==1) & (data_long['year']==2018) & (data_long['treated'] == 1)]['bycatch'].mean()
control_pre=data_long[(data_long['month']==12) & (data_long['year']==2017) & (data_long['treated'] == 0)]['bycatch'].mean()
control_post=data_long[(data_long['month']==1) & (data_long['year']==2018) & (data_long['treated'] == 0)]['bycatch'].mean()
DID=(treatment_post-treatment_pre)-(control_post-control_pre)

did_table=pd.DataFrame({'Sample analog value': [treatment_pre, 
                                      treatment_post, 
                                      control_pre, 
                                      treatment_post, 
                                      DID]},
                        index=['$\E[Y_{igt}|g(i)=treatment,t=Pre]=$', 
                               '$\E[Y_{igt}|g(i)=treatment,t=Post]=$', 
                               '$\E[Y_{igt}|g(i)=control,t=Pre]=$', 
                               '$\E[Y_{igt}|g(i)=control,t=Post]=$', 
                               '\midrule DID='])
did_table.to_latex(outputpath + '/table/didcalculation.tex', column_format='rl', float_format="%.2f", escape=False)

#Question 3
#Shaping the data matrix
data_q1a=data_long.loc[data_long['Month'].isin([12,13])]
data_q1a['t2017']=np.where(data_q1a['year']==2017,1,0)
data_q1a['treatit']=np.where((data_q1a['year']==2018) & (data_q1a['treated']==1),1,0)
data_q1a.head()


# Estimate the DID model using pyfixest the python equivalent of R fixest package
from pyfixest.estimation import feols, fepois
from pyfixest.utils import get_data
from pyfixest.summarize import etable

#Qustion 3a
ols_a=feols(fml="bycatch ~ treated + treatit | t2017", data=data_q1a, vcov={'CRV1': 'firm'})
beta_a=ols_a.coef()
se_a=ols_a.se()
ci_a=ols_a.confint()
ols_a.summary()

# Question 3 b
# Create the indicator variable
data_long['treatit']=np.where((data_long['year']==2018) & (data_long['treated']==1),1,0)
# Get the OLS estimates
ols_b=feols(fml="bycatch ~ treated + treatit | Month", data=data_long, vcov={'CRV1': 'firm'})
beta_b=ols_b.coef()
se_b=ols_b.se()
ci_b=ols_b.confint()
ols_b.summary()

# Question 3 c
# Create the indicator variable
data_long['treatit']=np.where((data_long['year']==2018) & (data_long['treated']==1),1,0)
# Get the OLS estimates
ols_c=feols(fml="bycatch ~ treated + treatit + firmsize + salmon + shrimp | Month", data=data_long, vcov={'CRV1': 'firm'})
beta_c=ols_c.coef()
se_c=ols_c.se()
ci_c=ols_c.confint()
ols_c.summary()

# Export to latex
report_table=pd.DataFrame({'(a)': ["{:0.2f}".format(ols_a.coef()['treatit']), "({:0.2f})".format(ols_a.se()['treatit']), "\checkmark", "\checkmark", "$\\times$","Dec 2017 - Jan 2018"],
                           '(b)': ["{:0.2f}".format(ols_b.coef()['treatit']), "({:0.2f})".format(ols_b.se()['treatit']), "\checkmark", "\checkmark", "$\\times$","Jan 2017 - Dec 2018"],
                           '(c)': ["{:0.2f}".format(ols_c.coef()['treatit']), "({:0.2f})".format(ols_c.se()['treatit']), "\checkmark", "\checkmark", "\checkmark","Jan 2017 - Dec 2018"]},
                        index=['DID estimates', 
                               ' ',
                               '\midrule Group FE',
                               'Month Indicator' ,
                               'Controls', 
                               'Sample'])
report_table.to_latex(outputpath + '/table/reporttable1.tex', column_format='rccc', float_format="%.2f", escape=False)