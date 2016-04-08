# BNPMediation

To install this package:
```
library(devtools)
install_github("lit777/BNPMediation")
library(BNPMediation)
```
Before run the function:
- Firstly, fit the observed data models using DPdensity (from DPpackage) for both treatments.
```
install_packages("DPpackage")
library(DPpackage)

fit1 <- DPdensity(y=w1,prior=prior,mcmc=mcmc,state=state,status=TRUE, na.action=na.omit)
fit0 <- DPdensity(y=w0,prior=prior,mcmc=mcmc,state=state,status=TRUE, na.action=na.omit)

```
