import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
from stargazer.stargazer import Stargazer, LineLocation
from scipy import stats
import statsmodels.api as sm
from datetime import date
from linearmodels import IVGMM

datapath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-5\data'
outputpath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-7\output'
np.random.seed(1)
data=pd.read_csv(datapath +'/instrumentalvehicles.csv')
# Generate new variable 'treatment' = 1 if length>225 and 0 otherwise
data['treatment'] = np.where(data['length'] > 225, 1, 0)

'''
------------------------------------------------------------------------------
Q1.2: Scatter plot with mpg on the y-axis and length − cutof f on the x-axis with a line at the RD
cutoff.
------------------------------------------------------------------------------
'''
# Scatter plot with mpg on the y-axis and length − cutof f on the x-axis with a line at the RD cutoff
plt.figure()
plt.scatter(data['length'], data['mpg'], c=data['treatment'], cmap='RdBu', s=7, alpha=0.5)
plt.axvline(x=225, color='black', linestyle='--')
plt.xlabel('Length (in)')
plt.ylabel('Fuel efficiency (mpg)')
plt.title('Scatter plot of vehicle fuel efficiency vs length')
plt.xlim(100, 350)
#plt.show()
plt.savefig(outputpath + '/figure/scatterplot.pdf')

'''
------------------------------------------------------------------------------
Q1.3: Fit first order polynomial on both sides of the cutoff
------------------------------------------------------------------------------
'''
# Create quadratic to fifth-order terms to use later
data['l2'] = data['length']**2
data['l3'] = data['length']**3
data['l4'] = data['length']**4
data['l5'] = data['length']**5

# Interact length with treatment
indep_1="+".join(data.columns.difference(["price",
                                          "car","weight","height","treatment", 'mpg','l2','l3','l4','l5']))
formula= 'mpg ~ treatment * ({})'.format(indep_1)
# RD regression with first order polynomial
rd_1=sm.OLS.from_formula(formula, data=data).fit()
beta=rd_1.params
rd_1=rd_1.get_robustcov_results(cov_type='HC1')
print(rd_1.summary())

'''
------------------------------------------------------------------------------
Q1.3: Plot RD estimates 
------------------------------------------------------------------------------
'''
# Scatter plot with mpg on the y-axis and length − cutof f on the x-axis with a line at the RD cutoff
plt.figure()
plt.scatter(data['length'], data['mpg'], c=data['treatment'], cmap='RdBu', s=7, alpha=0.5)
plt.axvline(x=225, color='black', linestyle='--')
plt.xlabel('Length (in)')
plt.ylabel('Fuel efficiency (mpg)')
plt.xlim(100, 350)
# Add linear equation of x before and after the cutoff
x_below = np.linspace(100, 225, 100)
y_below = beta['Intercept'] + beta['length'] * x_below
plt.plot(x_below, y_below, color='red', linestyle='--')
x_above = np.linspace(225, 350, 100)
y_above = beta['Intercept'] + beta['length'] * x_above + beta['treatment']+beta['treatment:length']*x_above
plt.plot(x_above, y_above, color='red', linestyle='--')
#plt.show()
plt.savefig(outputpath + '/figure/RD_1.pdf')

'''
------------------------------------------------------------------------------
Q1.4: Fit second order polynomial on both sides of the cutoff
------------------------------------------------------------------------------
'''
# Interact length with treatment
indep_2="+".join(data.columns.difference(["price","car","weight","height","treatment", 'mpg','l3','l4','l5']))
formula= 'mpg ~ treatment * ({})'.format(indep_2)
# First stage mpg on weight (instrument) and car type
rd_2=sm.OLS.from_formula(formula, data=data).fit()
beta=rd_2.params
rd_2=rd_2.get_robustcov_results(cov_type='HC1')
print(rd_2.summary())

'''
------------------------------------------------------------------------------
Q1.4: Plot RD estimates using second order polynomial
------------------------------------------------------------------------------
'''
# Scatter plot with mpg on the y-axis and length − cutof f on the x-axis with a line at the RD cutoff
plt.figure()
plt.scatter(data['length'], data['mpg'], c=data['treatment'], cmap='RdBu', s=7, alpha=0.5)
plt.axvline(x=225, color='black', linestyle='--')
plt.xlabel('Length (in)')
plt.ylabel('Fuel efficiency (mpg)')
plt.xlim(100, 350)
# Add quadratic equation of x before and after the cutoff
x_below = np.linspace(100, 225, 100)
y_below = beta['Intercept'] + beta['length'] * x_below + beta['l2']*x_below**2
plt.plot(x_below, y_below, color='red', linestyle='--')
x_above = np.linspace(225, 350, 100)
y_above = beta['Intercept'] + beta['length'] * x_above + beta['treatment']+beta['treatment:length']*x_above+beta['l2']*x_above**2+beta['treatment:l2']*x_above**2
plt.plot(x_above, y_above, color='red', linestyle='--')
#plt.show()
plt.savefig(outputpath + '/figure/RD_2.pdf')

'''
------------------------------------------------------------------------------
Q1.5: Fit fifth order polynomial on both sides of the cutoff
------------------------------------------------------------------------------
'''
# Interact length with treatment
indep_3="+".join(data.columns.difference(["price","car","weight","height","treatment", 'mpg']))
formula= 'mpg ~ treatment * ({})'.format(indep_3)
# First stage mpg on weight (instrument) and car type
rd_3=sm.OLS.from_formula(formula, data=data).fit()
beta=rd_3.params
rd_3=rd_3.get_robustcov_results(cov_type='HC1')
print(rd_3.summary())

'''
------------------------------------------------------------------------------
Q1.5: Plot RD estimates using fifths order polynomial
------------------------------------------------------------------------------
'''
# Scatter plot with mpg on the y-axis and length − cutof f on the x-axis with a line at the RD cutoff
plt.figure()
plt.scatter(data['length'], data['mpg'], c=data['treatment'], cmap='RdBu', s=7, alpha=0.5)
plt.axvline(x=225, color='black', linestyle='--')
plt.xlabel('Length (in)')
plt.ylabel('Fuel efficiency (mpg)')
plt.xlim(100, 350)
# Add fifth order polynomial equation of x before and after the cutoff
x_below = np.linspace(100, 225, 100)
y_below = beta['Intercept'] + beta['length'] * x_below \
            + beta['l2']*x_below**2+beta['l3']*x_below**3+beta['l4']*x_below**4+beta['l5']*x_below**5
plt.plot(x_below, y_below, color='red', linestyle='--')
x_above = np.linspace(225, 350, 100)
y_above = beta['Intercept'] + beta['length'] * x_above \
            + beta['treatment']+beta['treatment:length']*x_above+beta['l2']*x_above**2 \
            +beta['treatment:l2']*x_above**2+beta['l3']*x_above**3+beta['treatment:l3']*x_above**3 \
            +beta['l4']*x_above**4+beta['treatment:l4']*x_above**4+beta['l5']*x_above**5+beta['treatment:l5']*x_above**5
plt.plot(x_above, y_above, color='red', linestyle='--')
#plt.show()
plt.savefig(outputpath + '/figure/RD_3.pdf')

'''
------------------------------------------------------------------------------
Q1.3-5. Export table
------------------------------------------------------------------------------
'''
output=Stargazer([rd_1,rd_2,rd_3])

output.rename_covariates({'treatment':'LATE'})
output.covariate_order(['treatment'])
output.add_line('Polynomial specification',['1$^{st}$ order','2$^{nd}$ order','5$^{th}$ order'], LineLocation.FOOTER_TOP)
output.dependent_variable_name('Fuel efficiency (mpg)')
output.show_degrees_of_freedom(False)
output.show_stars=True

tex_file = open(outputpath+'\\table\\RD_estimates.tex', "w" ) #This will overwrite an existing file
tex_file.write( output.render_latex(only_tabular=True) )
tex_file.close()
#plt.savefig(outputpath + '/figure/exclusion_restriction_1.pdf')

'''
------------------------------------------------------------------------------
Q1.6: 2SLS of price on mpg using weight as instrument
------------------------------------------------------------------------------
'''
# First stage mpg on discontinuity adding car type
# Interact length with treatment
indep="+".join(data.columns.difference(["price",
                                          "car","weight","height","treatment", 'mpg','l2','l3','l4','l5']))
formula_first= 'mpg ~ car + treatment * ({})'.format(indep)
# RD regression with first order polynomial
first_stage=sm.OLS.from_formula(formula_first, data=data).fit()
first_stage=first_stage.get_robustcov_results(cov_type='HC1')
print(first_stage.summary())
data['mpg_hat_a']=first_stage.predict()
formula_second= 'price ~ mpg_hat_a + car'
second_stage=sm.OLS.from_formula(formula_second, data=data).fit()
second_stage=second_stage.get_robustcov_results(cov_type='HC1')
print(second_stage.summary())