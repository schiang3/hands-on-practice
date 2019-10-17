library(Hmisc) #Describe Function
library(psych) #Multiple Functions for Statistics and Multivariate Analysis
library(GGally) #ggpairs Function
library(ggplot2) #ggplot2 Functions
library(vioplot) #Violin Plot Function
library(corrplot) #Plot Correlations
library(REdaS) #Bartlett's Test of Sphericity
library(psych) #PCA/FA functions
library(factoextra) #PCA Visualizations
library("FactoMineR") #PCA functions
library(ade4) #PCA Visualizations
######################
setwd('C:/Users/Shuya C/Desktop/depaul/DSC 424/Final project')
cancer <- read.csv(file="data.csv", header=TRUE, sep=",")
cancer2 <- cancer[,c(2:32)]
cancer2
cancer3 <-cancer2[,c(2:31)]
cancer3
library(psych)
describe(cancer2)
dim(cancer2)
head(cancer2)
names(cancer2)
sum(is.na(cancer2))
library(psych)
library(GGally)
library(ggplot2)
library(corrplot)
describe(cancer2)
p1 <- ggpairs(cancer2[,2:31])
p1
M<-cor(cancer3, method="spearman")
M
corrplot(M, method = "square")
summary(cancer2$diagnosis)

#check correlaiton
library(psych)
CorrTest = corr.test(cancer2[,2:31], adjust="none")
CorrTest
M2 = CorrTest$p
M2
MTest = ifelse(M2 < .01, T, F)
MTest
colSums(MTest) - 1  


p2<-ggplot(cancer2, aes(x=diagnosis, y=radius_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="radius_mean",y="radius_mean", x="diagnosis")
p2
p3<-ggplot(cancer2, aes(x=diagnosis, y=texture_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="texture_mean",y="texture_mean", x="diagnosis")
p3
p4<-ggplot(cancer2, aes(x=diagnosis, y=perimeter_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="perimeter_mean",y="perimeter_mean", x="diagnosis")
p4
p5<-ggplot(cancer2, aes(x=diagnosis, y=area_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="area_mean",y="area_mean", x="diagnosis")
p5
p6<-ggplot(cancer2, aes(x=diagnosis, y=smoothness_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="smoothness_mean",y="smoothness_mean", x="diagnosis")
p6
p7<-ggplot(cancer2, aes(x=diagnosis, y=compactness_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="compactness_mean",y="compactness_mean", x="diagnosis")
p7
p8<-ggplot(cancer2, aes(x=diagnosis, y=concavity_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="concavity_mean",y="concavity_mean", x="diagnosis")
p8
p9<-ggplot(cancer2, aes(x=diagnosis, y=concave.points_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="concave.points_mean ",y="concave.points_mean ", x="diagnosis")
p9
p10<-ggplot(cancer2, aes(x=diagnosis, y=symmetry_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="symmetry_mean ",y="symmetry_mean ", x="diagnosis")
p10
p11<-ggplot(cancer2, aes(x=diagnosis, y=fractal_dimension_mean, fill=diagnosis)) +
  geom_violin(trim=FALSE) +
  guides(fill=guide_legend(title="diagnosis")) +
  labs(title="fractal_dimension_mean ",y="fractal_dimension_mean ", x="diagnosis")
p11
## create diagnosis vector
diagnosis <- as.numeric(cancer2$diagnosis == "M")
diagnosis
table(cancer2$diagnosis)
########
PCA_Plot = function(pcaData)
{
  library(ggplot2)
  
  theta = seq(0,2*pi,length.out = 100)
  circle = data.frame(x = cos(theta), y = sin(theta))
  p = ggplot(circle,aes(x,y)) + geom_path()
  
  loadings = data.frame(pcaData$rotation, .names = row.names(pcaData$rotation))
  p + geom_text(data=loadings, mapping=aes(x = PC1, y = PC2, label = .names, colour = .names, fontface="bold")) +
    coord_fixed(ratio=1) + labs(x = "PC1", y = "PC2")
}

PCA_Plot_Secondary = function(pcaData)
{
  library(ggplot2)
  
  theta = seq(0,2*pi,length.out = 100)
  circle = data.frame(x = cos(theta), y = sin(theta))
  p = ggplot(circle,aes(x,y)) + geom_path()
  
  loadings = data.frame(pcaData$rotation, .names = row.names(pcaData$rotation))
  p + geom_text(data=loadings, mapping=aes(x = PC3, y = PC4, label = .names, colour = .names, fontface="bold")) +
    coord_fixed(ratio=1) + labs(x = "PC3", y = "PC4")
}

PCA_Plot_Psyc = function(pcaData)
{
  library(ggplot2)
  
  theta = seq(0,2*pi,length.out = 100)
  circle = data.frame(x = cos(theta), y = sin(theta))
  p = ggplot(circle,aes(x,y)) + geom_path()
  
  loadings = as.data.frame(unclass(pcaData$loadings))
  s = rep(0, ncol(loadings))
  for (i in 1:ncol(loadings))
  {
    s[i] = 0
    for (j in 1:nrow(loadings))
      s[i] = s[i] + loadings[j, i]^2
    s[i] = sqrt(s[i])
  }
  
  for (i in 1:ncol(loadings))
    loadings[, i] = loadings[, i] / s[i]
  
  loadings$.names = row.names(loadings)
  
  p + geom_text(data=loadings, mapping=aes(x = PC1, y = PC2, label = .names, colour = .names, fontface="bold")) +
    coord_fixed(ratio=1) + labs(x = "PC1", y = "PC2")
}

PCA_Plot_Psyc_Secondary = function(pcaData)
{
  library(ggplot2)
  
  theta = seq(0,2*pi,length.out = 100)
  circle = data.frame(x = cos(theta), y = sin(theta))
  p = ggplot(circle,aes(x,y)) + geom_path()
  
  loadings = as.data.frame(unclass(pcaData$loadings))
  s = rep(0, ncol(loadings))
  for (i in 1:ncol(loadings))
  {
    s[i] = 0
    for (j in 1:nrow(loadings))
      s[i] = s[i] + loadings[j, i]^2
    s[i] = sqrt(s[i])
  }
  
  for (i in 1:ncol(loadings))
    loadings[, i] = loadings[, i] / s[i]
  
  loadings$.names = row.names(loadings)
  
  print(loadings)
  p + geom_text(data=loadings, mapping=aes(x = PC3, y = PC4, label = .names, colour = .names, fontface="bold")) +
    coord_fixed(ratio=1) + labs(x = "PC3", y = "PC4")
}
##### CREATE PCA
bc = prcomp(cancer3, center=T, scale=T)
plot(bc)
abline(1, 0)
summary(bc)
print(bc)
plot(bc)
PCA_Plot(bc) 
PCA_Plot_Secondary(bc)
print(bc)

library("FactoMineR")
bc_pca <- PCA(cancer3, graph = FALSE)
print(bc_pca)
variables <- get_pca_var(bc_pca)
head(variables$contrib, 11)
library("corrplot")
corrplot(variables$contrib, is.corr=FALSE)    
bc_pca$eig
bc_pca$var
bc_pca$var$coord
#####
bc2 = psych::principal(cancer3, rotate="varimax", nfactors=6, scores=TRUE)
bc2
print(bc2$loadings, cutoff=.4, sort=T)
print(bc2$loadings, cutoff=.568, sort=T)
print(bc2$loadings, cutoff=.5, sort=T)
print(bc2$loadings, cutoff=.6, sort=T)
summary(bc2)
ls(bc2)
bc2$values
bc2$communality
bc2$rot.mat
bc2$fit
library("FactoMineR")
variables <- get_pca_var(bc2)
head(variables$contrib, 11)
library("corrplot")
corrplot(variables$contrib, is.corr=FALSE)  
##
bc3 = psych::principal(cancer3, rotate="varimax", nfactors=5, scores=TRUE)
bc3

print(bc3$loadings, cutoff=.4, sort=T)
print(bc3$loadings, cutoff=.5, sort=T)
print(bc3$loadings, cutoff=.6, sort=T)
summary(bc3)
bc4 = psych::principal(cancer3, rotate="varimax", nfactors=4, scores=TRUE)
bc4
print(bc4$loadings, cutoff=.4, sort=T)
print(bc4$loadings, cutoff=.5, sort=T)
print(bc4$loadings, cutoff=.6, sort=T)
summary(bc4)
bc5 = psych::principal(cancer3, rotate="varimax", nfactors=3, scores=TRUE)
bc5
print(bc5$loadings, cutoff=.4, sort=T)
print(bc5$loadings, cutoff=.5, sort=T)
print(bc5$loadings, cutoff=.61, sort=T)
summary(bc5)
ls(bc5)
bc5$values
bc5$communality
bc5$rot.mat
bc5$scores
bc6 = psych::principal(cancer3, rotate="varimax", nfactors=2, scores=TRUE)
bc6
print(bc6$loadings, cutoff=.4, sort=T)
print(bc6$loadings, cutoff=.5, sort=T)
print(bc6$loadings, cutoff=.6, sort=T)
summary(bc6)
### PCA 

dbc.pcs <- bc$x[,1:6]
head(dbc.pcs, 20)


wdbcpc <- dbc.pcs
wdbcpc <- cbind(dbc.pcs, diagnosis)
head(wdbcpc)
#using 3 components
dbc.pcs3 <- bc$x[,1:3]
wdbcpc2<-dbc.pcs3
wdbcpc2 <- cbind(dbc.pcs3, diagnosis)

#nrow(train_data)
#nrow(test_data)

# Create a random number vector
N <- nrow(wdbcpc)
rvec <- runif(N)

# Select rows from the dataframe
wdbCtrain <- wdbcpc[rvec < 0.8,]
wdbctest <- wdbcpc[rvec >= 0.8,]
# Check the number of observations
nrow(wdbCtrain)
nrow(wdbctest)


library(caret)
set.seed(1234)
df_index=createDataPartition(cancer2$diagnosis, p=0.8, list = FALSE)
train_data = cancer2[df_index,]
test_data =cancer2[-df_index,]
df_diagnosis=(cbind(dbc.pcs,diagnosis))#1 for m,0 for b
df_diagnosis.df=as.data.frame(df_diagnosis)
#LDA USING PCA 6PC
library(MASS)
wdbctrain.df <- wdbCtrain
# convert matrix to a dataframe
wdbctrain.df <- as.data.frame(wdbCtrain)
wdbclda <- lda(diagnosis ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6, data = wdbCtrain)
wdbclda
wdbctest.df <- wdbctest
wdbctest.df <- as.data.frame(wdbctest)
wdbctest.df
wdbctest.df$diagnosis
wdbclda.pred <- predict(wdbclda, newdata = wdbctest)
ls(wdbclda.pred)
wdbclda.pred$class
library("ROCR")
# Get the posteriors as a dataframe.
wdbldapredposteriors <- as.data.frame(wdbclda.pred$posterior)
# Evaluate the model
pred <- prediction(wdbldapredposteriors[,2], wdbctest.df$diagnosis)
rocperf = performance(pred, measure = "tpr", x.measure = "fpr")
auctrain <- performance(pred, measure = "auc")
auctrain <- auctrain@y.values
plot(rocperf)
abline(a=0, b= 1)
text(x = .40, y = .6,paste("AUC = ", round(auctrain[[1]],3), sep = ""))
library(e1071)
library(caret)
cm_lda <- confusionMatrix(table(wdbctest.df$diagnosis, wdbclda.pred$class))
cm_lda

## 3 c with lda
# Create a random number vector
n <- nrow(wdbcpc2)
rvec <- runif(n)

# Select rows from the dataframe
wdbCtrain2 <- wdbcpc2[rvec < 0.8,]
wdbctest2<- wdbcpc2[rvec >= 0.8,]
# Check the number of observations
nrow(wdbCtrain2)
nrow(wdbctest2)
#LDA USING PCA 3PC
library(MASS)
wdbctrain2.df <- wdbCtrain2
# convert matrix to a dataframe
wdbctrain2.df <- as.data.frame(wdbCtrain2)
wdbclda2 <- lda(diagnosis ~ PC1 + PC2 + PC3 , data = wdbctrain2.df)
wdbclda2
wdbctest2.df <- wdbctest2
wdbctest2.df <- as.data.frame(wdbctest2)
wdbctest2.df
wdbctest2.df$diagnosis
wdbclda.pred2 <- predict(wdbclda2, newdata = wdbctest2.df)
ls(wdbclda.pred2)
wdbclda.pred2$class
library("ROCR")
# Get the posteriors as a dataframe.
wdbldapredposteriors2 <- as.data.frame(wdbclda.pred2$posterior)
# Evaluate the model
pred2 <- prediction(wdbldapredposteriors2[,2], wdbctest2.df$diagnosis)
rocperf2 = performance(pred2, measure = "tpr", x.measure = "fpr")
auctrain2 <- performance(pred2, measure = "auc")
auctrain2 <- auctrain2@y.values
plot(rocperf2)
abline(a=0, b= 1)
text(x = .40, y = .6,paste("AUC = ", round(auctrain2[[1]],3), sep = ""))
library(e1071)
library(caret)
cm_lda2 <- confusionMatrix(table(wdbctest2.df$diagnosis, wdbclda.pred2$class))
cm_lda2

## 
## split train and test  randon forest
library(caret)
set.seed(1234)
df_index=createDataPartition(cancer2$diagnosis, p=0.8, list = FALSE)
train_data = cancer2[df_index,]
test_data =cancer2[-df_index,]
fitControl <- trainControl(method="cv", number = 5,preProcOptions = list(thresh = 0.99),classProbs = TRUE,summaryFunction = twoClassSummary)
fitControl
m_pca_rf<- train(diagnosis~.,train_data, method="ranger", metric="ROC",preProcess = c('center', 'scale' ),trControl=fitControl)
pred_pca_rf <- predict(m_pca_rf, test_data)
pred_pca_rf
cm_pca_rf <- confusionMatrix(pred_pca_rf, test_data$diagnosis, positive = "M")
cm_pca_rf
