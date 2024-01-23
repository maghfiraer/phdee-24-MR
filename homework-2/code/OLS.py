import numpy as np
import pandas as pd
from scipy.optimize import minimize

class manualOLS:
    def __init__(self, X, y, addIntercept=True, method='byhand', useRobust=False):
        '''
        This class implements the OLS estimator using different methods: 'byhand', 'leastsquares', and 'statsmodels'
        '''
        self.X = X
        self.y = y.to_numpy()
        self.method = method
        self.addIntercept = addIntercept
        self.useRobust = useRobust
        
        if self.X.ndim==1:
            self.X = self.X[:,np.newaxis]
        if self.y.ndim==1:
            self.y = self.y[:,np.newaxis]
        if self.addIntercept:
            self.X = np.concatenate((self.X, np.ones((self.X.shape[0],1))), axis=1)
        
        self.xxinv= np.linalg.inv(self.X.T @ self.X)
        self.n,self.k=self.X.shape
        
    def beta(self):
        if self.method=='byhand':
            beta = self.xxinv @ self.X.T @ self.y
            
        elif self.method=='leastsquares':
            def ssr(b, X, y):
                return np.sum(np.square(y-X@b[:,np.newaxis]))
            beta=minimize(ssr, x0=np.zeros(self.X.shape[1]), args=(self.X, self.y)).x[:,np.newaxis]
                
        elif self.method=='statsmodels':
            import statsmodels.api as sm
            beta = sm.OLS(self.y, self.X).fit().params[:,np.newaxis]
            
        else:
            raise ValueError('Method not recognized')
        
        return beta
    
    def beta_std(self):
        cov=self.cov()
        beta_std=np.sqrt(np.diag(cov))[:,np.newaxis]
        return beta_std
    
    def cov(self):
        yhat=self.predict()
        e=self.y-yhat
        s2=e.T@e/(self.n-self.k)
        
        if self.useRobust:
            cov=(self.n/(self.n-self.k))*self.xxinv @ (self.X.T @ np.diag(np.diag(e @ e.T)) @self.X) @self.xxinv
        else:
            cov=s2*self.xxinv
        return cov
    
    def MSE(self):
        yhat=self.predict()
        e=self.y-yhat
        s2=e.T@e/(self.n-self.k)
        MSE=np.sqrt(s2)[0,0]
        return MSE
    
    
    def predict(self):
        yhat=self.X@self.beta()
        return yhat
    
    def R2(self):
        y_hat = self.predict()
        return np.sum((y_hat - self.y)**2) / np.sum((self.y - np.mean(self.y))**2)
    
    def report(self):
        print('Regression using {:s} method'.format(self.method))
        print('Number of observations: {:d}\nNumber of parameters: {:d}'.format(self.n,self.k))
        if self.useRobust:
            hetero=('heteroskedasticity-robust')
        else:
            hetero=('')
        print('OLS estimates ({:s} standard errors in parentheses):'.format(hetero))
        for b,std in zip(self.beta(),self.beta_std()):
                b=b[0]
                std=std[0]
                print('{:1.5f} ({:1.5f})'.format(b,std))
        print('MSE = {:1.5f}'.format(self.MSE()))
        print('R2 = {:1.5f}\n'.format(self.R2()))
                