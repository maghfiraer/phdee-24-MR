import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import statsmodels.api as sm


datapath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-3\data'
outputpath = r'C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-3\output'
np.random.seed(1)

'''
------------------------------------------------------------------------------
Q1.(e): Estimate log-transformed model
------------------------------------------------------------------------------
'''

data=pd.read_csv(datapath +'/kwh.csv')

# Generate log-transformed data
data['ln_electricity']=np.log(data['electricity'])
data['ln_sqft']=np.log(data['sqft'])
data['ln_temp']=np.log(data['temp'])

## Estimate parameter from the log-transformed model
ols = sm.OLS(data['ln_electricity'],sm.add_constant(data[['retrofit','ln_sqft','ln_temp']])).fit()
param_ols = ols.params.to_numpy() # save estimated parameters
params, = np.shape(param_ols) # save number of estimated parameters
nobs3 = int(ols.nobs)
param_ols[1]=np.exp(param_ols[1]) # convert retrofit coefficient (ln delta) back to delta

## Calculate average marginal effects (AME)
marg_1=data.apply(lambda x: (param_ols[1]-1)*x['electricity']/(param_ols[1]**x['retrofit']),axis=1) # calculate AME for di
marg_2=data.apply(lambda x: param_ols[2]*x['electricity']/x['sqft'],axis=1) # calculate AME for sqft
marg_3=data.apply(lambda x: param_ols[3]*x['electricity']/x['temp'],axis=1) # calculate AME for temp
marg=[marg_1.mean(),marg_2.mean(),marg_3.mean()] #save estimated AME

# Bootstrap by hand and get confidence intervals of parameter estimates and AME -----------------------------
## Set values and initialize arrays to output to
breps = 1000 # number of bootstrap replications
olsparamblist = np.zeros((breps,params))
margblist = np.zeros((breps,params-1))

## Get an index of the data we will sample by sampling with replacement
bidx = np.random.choice(nobs3,(nobs3,breps)) # Generates random numbers on the interval [0,nobs3] and produces a nobs3 x breps sized array

## Sample with replacement to get the size of the sample on each iteration
for r in range(breps):
    ### Sample the data
    datab = data.iloc[bidx[:,r]]
    
    ### Perform the estimation
    olsb = sm.OLS(datab['ln_electricity'],sm.add_constant(datab[['retrofit','ln_sqft','ln_temp']])).fit()
    param_olsb = olsb.params.to_numpy() # save estimated parameters
    param_olsb[1]=np.exp(param_olsb[1]) # convert retrofit coefficient (ln delta) to delta
    
    ### Compute the marginal effect
    margb_1=datab.apply(lambda x: (param_olsb[1]-1)*x['electricity']/(param_olsb[1]**x['retrofit']),axis=1) # calculate AME for di
    margb_2=datab.apply(lambda x: param_olsb[2]*x['electricity']/x['sqft'],axis=1) # calculate AME for sqft
    margb_3=datab.apply(lambda x: param_olsb[3]*x['electricity']/x['temp'],axis=1) # calculate AME for temp
    margb=[margb_1.mean(),margb_2.mean(),margb_3.mean()]
    margblist[r,:]=margb
    
    ### Output the parameter estimates result
    olsparamblist[r,:] = param_olsb
    
## Extract 2.5th and 97.5th percentile for each parameter
lb_ols = np.percentile(olsparamblist,2.5,axis = 0,interpolation = 'lower')
ub_ols = np.percentile(olsparamblist,97.5,axis = 0,interpolation = 'higher')

## Extract 2.5th and 97.5th percentile for AMEs
lb_marg = np.percentile(margblist,2.5,axis = 0,interpolation = 'lower')
ub_marg = np.percentile(margblist,97.5,axis = 0,interpolation = 'higher')

# Regression output table with CIs
## Format parameter estimates and confidence intervals
paramP_ols = np.round(param_ols,3)

lbP_ols = pd.Series(np.round(lb_ols,3)) # Round to two decimal places and get a Pandas Series version
ubP_ols = pd.Series(np.round(ub_ols,3))
ci_ols = '[' + lbP_ols.map(str) + ', ' + ubP_ols.map(str) + ']'

## Format AME estimates and confidence intervals
margP = np.round(marg,3)

lbP_marg = pd.Series(np.round(lb_marg,3)) # Round to two decimal places and get a Pandas Series version
ubP_marg = pd.Series(np.round(ub_marg,3))
ci_marg = '[' + lbP_marg.map(str) + ', ' + ubP_marg.map(str) + ']'

## Get parameter estimates output in order
#order = [1,2,3,0]
output_ols = pd.DataFrame(np.column_stack([paramP_ols,ci_ols]))
col1=pd.concat([output_ols.stack(),pd.Series(nobs3)])

## Get AME estimates output in order
output_ame = pd.DataFrame(np.column_stack([margP,ci_marg]))
output_ame.loc[len(output_ame.index)]=[' ',' '] # shift the dataframe down one row
output_ame=output_ame.shift()
output_ame.loc[0]=[' ',' ']
col2=pd.concat([output_ame.stack(),pd.Series(nobs3)])

## Row and column names
rownames = pd.concat([pd.Series(['Constant','=1 if home received retrofit','Square feet of home','Outdoor average temperature (\\textdegree F)','Observations']),pd.Series([' ',' ',' ',' '])],axis = 1).stack() # Note this stacks an empty list to make room for CIs

## Append CIs, # Observations, row and column names
order = [1,2,3,0]
col = pd.DataFrame({'Parameter estimates': col1, 'Average marginal effects estimates': col2})
col.reindex(order)
col.index = rownames
col.to_latex(outputpath + '/table/h31e.tex',column_format='lccc',escape=False)

# Plot AME with error bars for sqft and temp -------------------------------------
lowbar = np.array(marg[1:3] - lb_marg[1:3])
highbar = np.array(ub_marg[1:3] - marg[1:3])
plt.errorbar(y = marg[1:3], x = np.arange(params-2), yerr = [lowbar,highbar], fmt = 'o', capsize = 5)
plt.ylabel('Average marginel effect estimates')
plt.xticks(np.arange(params-2),['Square feet of home', 'Outdoor average temperature ($\degree$F)'])
plt.xlim((-0.5,1.5)) # Scales the figure more nicely
plt.axhline(linewidth=2, color='r')
plt.savefig(outputpath + '/figure/ame.pdf',format='pdf')
