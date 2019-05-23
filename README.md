<b> Factors influencing customers to become premium subscribers for a music streaming company </b>

The “freemium” business model — widely used by online services such as LinkedIn, Match.com, Dropbox, and music-listening sites — divides user populations into groups that use the service for free and groups that pay a fee for additional features.

High Note is an anonymized real music streaming company similar to Spotify or Pandora that uses a freemium business model. The data includes factors such as: <br> 
- Demographic characteristics such as age, gender and country
- Social network characteristics such as number of friends a user has on the network
- Engagement level data on activities performed when using the service, which include the number of songs the user has listened to, playlists created, “shouts” sent to friends, etc.

<b> Objective: </b>
Given the higher profitability of premium subscribers, it is generally in the interest of company to motivate users to go from “free to fee”; that is, convert free accounts to premium subscribers. Your task in regards to this case is to analyze the data for potential insight to inform a “free-to-fee” strategy

After running some basic statistics and data visualizations, I used Propensity score matching algorithms to create a matched  treatment and control sample and identify significant differences.
Then, I used logistic regression to test which variables are significant for explaining the likelihood of becoming an adopter of premium subscription. <br> <br>

<b> Results </b>
Factors which are leading to an increase in probability of adopters (an individual adopting the premium subscription) are: <br>
-	Male
-	Age
-	Avg Friend age
-	Avg Friend male
-	Friend country count
-	Subscriber Friend count
-	Songs Listened
-	Loved Tracks
-	Posts
-	Playlists
-	Shouts

Factors which are leading to decrease in the probability of adopter are: <br>
-	Friend count
-	Tenure
-	Good country

Of all the above variables, we can state that ‘subscriber friend count’ is the most influential factor (exponential coefficient = 1.01) to predict adopter i.e., having more subscriber friends leads to high probability of becoming an adopter and buying the premium subscription. <br>

<b> Action points for the company to build a ‘free to fee’ strategy </b>
-	Identify people who have more subscriber friends in their community and focus their marketing budget on them. These people are more likely to purchase the premium subscription and stay loyal to the service. <br>
-	Identify people who are more active on the platform. These people are happy using High note platform for listening to songs, however are reluctant to pay for the premium subscription. Being active on the platform can be accounted through the following factors: <br>
- Loved Tracks
- Posts
- Playlists
- Shouts
A specific form of marketing towards these members might lead them to switch to premium subscription over the long run.
