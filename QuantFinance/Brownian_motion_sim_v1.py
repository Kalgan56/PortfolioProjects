# Model the paths of a stochastic process ie random variables through a set number of steps
# Modified from https://compfinance.ddns.net/wordpress/computational-finance/

# Generate stochastic paths using geometric brownian motion

import numpy as np
import matplotlib.pyplot as plt


# fix the randomness if we want to run experiments on the same outputs everytime
#np.random.seed(100)

numSteps=500
numPaths=25
mean=0.04
stdDev=0.4
S_0=100
Z=np.random.normal(0.0,1.0,[numPaths,numSteps]) # gives a 2D array of random normal values, row is a path and column a slice in time

X=np.zeros([numPaths,numSteps+1]) # set up 2D array to store the SDE calculations
time=np.zeros([numSteps+1])
X[:,0]=np.log(S_0)

dt=1.0/float(numSteps)

for i in range(0,numSteps):
    if numPaths>1: # making sure samples from a normal distribution have mean 0.0 and variance 1.0
        Z[:,i]=(Z[:,i]-np.mean(Z[:,i]))/np.std(Z[:,i])

    X[:,i+1]=X[:,i]+(mean-0.5*stdDev**2)*dt+stdDev*(np.power(dt,0.5)*Z[:,i])
    time[i+1]=time[i]+dt

S=np.exp(X)


plt.plot(time,np.transpose(X))
plt.show()




plt.figure(2)
plt.plot(time,np.transpose(X))
plt.xlabel('time t')
plt.ylabel('X(t)')

plt.figure(3)
plt.plot(time,np.transpose(S))
plt.xlabel('time t')
plt.ylabel('S(t)')

# Check whether the process is a martingale or not
ExpS=np.mean(S[:,-1])
print(ExpS)

plt.show()