# NOT RUN {
#Examples of "sim"
set.seed (1)
J <- 15
n <- J*(J+1)/2
group <- rep (1:J, 1:J)
mu.a <- 5
sigma.a <- 2
a <- rnorm (J, mu.a, sigma.a)
b <- -3
x <- rnorm (n, 2, 1)
sigma.y <- 6
y <- rnorm (n, a[group] + b*x, sigma.y)
u <- runif (J, 0, 3)
y123.dat <- cbind (y, x, group) #short for column bind – can be used to combine two data frames 
                          #with the same number of rows into a single data frame
y123.dat
# Linear regression
x1 <- y123.dat[,2] 
y1 <- y123.dat[,1]
M1 <- lm (y1 ~ x1)
display(M1)
M1.sim <- sim(M1)
coef.M1.sim <- coef(M1.sim)
sigma.M1.sim <- sigma.hat(M1.sim)
## to get the uncertainty for the simulated estimates
##step 4 in King reading
apply(coef(M1.sim), 2, quantile)
quantile(sigma.hat(M1.sim))

#-----------------------LOGISTIC REGRESSION--------
# Logistic regression
u.data <- cbind (1:J, u)
dimnames(u.data)[[2]] <- c("group", "u")
u.dat <- as.data.frame (u.data)
y <- rbinom (n, 1, invlogit (a[group] + b*x))
M2 <- glm (y ~ x, family=binomial(link="logit"))
display(M2)
M2.sim <- sim (M2)
coef.M2.sim <- coef(M2.sim)
sigma.M2.sim <- sigma.hat(M2.sim)
