#Read data
high_note <- read.csv("~/Desktop/UCI/Coursework/BANA 277 LEC A- CUST & SOCIAL ANLYTICS/Midterm/HighNote Data Midterm.csv")

str(high_note)

#Part 1 - Summary Statistics
library(psych)
describeBy(high_note, high_note$adopter)

#Part 2 - Data Visualizations
library(ggplot2)
#Songs listened by adopters and non-adopters
ggplot(high_note, aes(x=adopter, y=songsListened)) + geom_boxplot() + ylim(c(0,50000))

#Average friend ages by adopters and non-adopters
ggplot(high_note, aes(x=adopter, y=avg_friend_age)) + geom_boxplot() + ylim(c(10,60))

# Average number of countries where friends belong from by adopters and non-adopters 
ggplot(high_note, aes(x=factor(adopter), y=friend_country_cnt)) + stat_summary(fun.y = mean, geom = 'bar') + scale_y_continuous(breaks = seq(0,8, by = 1))

#Scatterplot of number of friends by adopters and non-adopters - Indicates that younger users on the platform have more friends
ggplot(high_note, aes(x = age, y = friend_cnt)) + 
  geom_point() +
  facet_wrap(~ adopter)+
  ylim(c(0, 750))+
  geom_smooth(method = 'lm', color='red')

#Scatterplot matrix - Number of friends, tenure, number of friends who are subscribers and number of songs listened
high_note_adopter <- subset(high_note, high_note$adopter == 1)
high_note_nonadopter <- subset(high_note, high_note$adopter == 0)
pairs(~friend_cnt+tenure+subscriber_friend_cnt+songsListened, data=high_note_adopter,lower.panel = panel.smooth, upper.panel = panel.smooth,
      main="Scatterplot Matrix for Adopters")

pairs(~friend_cnt+tenure+subscriber_friend_cnt+songsListened, data=high_note_nonadopter,lower.panel = panel.smooth, upper.panel = panel.smooth,
      main="Scatterplot Matrix for NonAdopter")


#Part 3 - Propensity score matching

#Converting the subscriber friends column into treatement and control group
#Treatment Group = Subscriber_friend_cnt > 1
#Control Group = Subscriber_friend_cnt = 0

#Creating new variable treatment where treatment group = 1 and control group = 0
high_note$treatment <- ifelse(high_note$subscriber_friend_cnt >0,1,0)

#Difference in means: Output variable 'adopter'
library(magrittr)
library(dplyr)
high_note %>%
  group_by(treatment) %>%
  summarise(n_people = n(),
            mean_adopter = mean(adopter),
            std_error = sd(adopter)/sqrt(n_people))
#Indicates that the mean of treatment group is very large compared to the control group

#t-test
with(high_note, t.test(adopter ~ treatment))
#The difference in means is statistically significant at conventional levels of confidence


#Difference in means: Pre-treatment covariates
#The following covariates shall be used:
high_note_cov <- c('age', 'male', 'friend_cnt', 'avg_friend_age', 'avg_friend_male', 'friend_country_cnt', 'subscriber_friend_cnt', 'songsListened', 'lovedTracks', 'posts', 'playlists', 'shouts', 'tenure', 'good_country')

high_note %>%
  group_by(treatment) %>%
  select(one_of(high_note_cov)) %>%
  summarise_all(funs(mean(., na.rm = T)))

#We can observe the people in treatment group have higher number of friends and from different countries. Also, they are more active on the platform as they listen to more song, make more posts, etc.

#Carry out t-tests to evaluate whether these means are statistically distinguishable:
lapply(high_note_cov, function(v) {
  t.test(high_note[, v] ~ high_note[, 'treatment'])})

#It is observed that there is statistically significant difference in means of all the above covariates except the covariate 'male'

#Propensity score estimation
#Running a logit model
m_ps <- glm(treatment ~ age + male + friend_cnt + avg_friend_age + avg_friend_male 
                  + friend_country_cnt + songsListened + lovedTracks + posts + playlists
                  + shouts + adopter + tenure + good_country, family = binomial(), data = high_note)
summary(m_ps)

#Using the above model, we can calculate the propensity score for each person. It is simply the person's predicted probability of being treated, given the estimates from the logit model.
#We use predict() and create a dataframe that has the propensity score and person's actual treatment status

prs_df <- data.frame(pr_score = predict(m_ps, type = 'response'),
                     treatment = m_ps$model$treatment)

#Histogram of estimated propensity scores by treatment status:
prs_df %>%
      ggplot(aes(x = pr_score)) +
      geom_histogram(color = "white") +
     facet_wrap(~treatment)

#Creating a tableone pre-matching table
library(tableone)
table1 <- CreateTableOne(vars = high_note_cov, strata = "treatment", data = high_note, test = FALSE)
print(table1, smd = TRUE)
#The SMD or Standardized Mean differences indicates whether there is imbalance among the variables in the dataset. Variables with SMD > 0.1 show imbalance in the dataset and that is where we actually need to do the propensity score matching.
#So, we should consider all variables except 'male', 'avg_friend_male' and 'good_country'



#Executing a matching algorithm
library(MatchIt)

high_note_nomiss <- high_note %>%
  select(treatment, adopter, one_of(high_note_cov)) %>%
  na.omit()

high_note_match <- subset(high_note_nomiss, select = -c(4,7,16))

mod_match <- matchit(treatment ~ age + friend_cnt + avg_friend_age 
                     + friend_country_cnt + songsListened + lovedTracks + posts + playlists
                     + shouts + tenure, method = 'nearest', data = high_note_match)

summary(mod_match)
plot(mod_match)

#Making a dataframe of the matched data
dta_m <- match.data(mod_match)
dim(dta_m)


#difference in means
dta_m %>%
  group_by(treatment) %>%
  select(one_of(high_note_cov)) %>%
  summarise_all(funs(mean))

#t-test with all the covariates
high_note_cov_new <- c('age', 'friend_cnt', 'avg_friend_age', 'friend_country_cnt', 'subscriber_friend_cnt', 'songsListened', 'lovedTracks', 'posts', 'playlists', 'shouts', 'tenure')

lapply(high_note_cov_new, function(v) {
  t.test(dta_m[, v] ~ dta_m$treatment)})

#Creating a tableone for matching data
table_match1 <- CreateTableOne(vars = high_note_cov_new, strata = 'treatment', data = dta_m, test = FALSE)
print(table_match1, smd = TRUE)


#Estimating treatment effects
with(dta_m, t.test(adopter ~ treatment))
#We can observe that there is significant difference in means between treatment and control groups after running the propensity score matching. This indicates that having more subscriber friends increases the chances of any person adopting the service i.e., becoming a premium member.

#Using OLS
lm_treat1 <- lm(adopter ~ treatment, data = dta_m)
summary(lm_treat1)
#The result indicates a highly significant model

#Regression analysis - With matched dataset
lm_treat2 <- lm(adopter ~ treatment + age + friend_cnt + avg_friend_age + friend_country_cnt 
                + songsListened + lovedTracks + posts + playlists + shouts 
                + tenure, family = binomial(), data = dta_m)
summary(lm_treat2)

#Regression analysis - With original dataset
#Removing the variable 'id' and dummy variable 'treatment' which was created for PSM
high_note_reg <- subset(high_note, select = -c(1,17))

lm_treat3 <- lm(adopter ~ ., family = binomial(),data = high_note_reg)
summary(lm_treat3)

#Calculating the exponential of coefficents because log(odds) are difficult to interpret
exp(coef(lm_treat3))

