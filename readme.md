# TFT Smart Hub

A modern web platform for analyzing and visualizing TFT team compositions, inspired by [tftactics.gg](https://tftactics.gg) and [tactics.tools](https://tactics.tools).

The key feature that different from the above webs it that this website higight the composition recommendation function: user input their current, incompelete composition, and click the search/recommend button. And then the web recommend some compositions that have the following features:
1. high win-rate (so that user can win the game)
2. relevent to user's current composition (have overlap units or same trait so that the user can achieve that ultimate high win-rate composition easily and do not need to start from scratch. The give of units each refresh is random so that recommend based on the user's current hava units is better than recomment a composition that all the units the user do not have)
3. is achievable (some compositions is high win-rate but it is very expensive or require some essmble or hard rquirement that the user can not meet in each round. The recommened high win-rate compositions should be achievable)
4. personal (sometimes the user meet some toguh reqirement e.g. have some essmble, or have some strong item or have some strong hexs. At this time the recommendation should be able to not waste the user's currrent advantage)

There are two types of composition. One is provided by the website, it is obtained by the statistics of the real-world match data, and ontains statistics like win-rate or so. Another type is created by users, it may contains the comment, the 前中后期过度. These two types should be splited. 

## Layout
The webs should have the follwoing navitagtion tabs or buttons or so
1. Recommendation (core function): a tab
descriptions: 

2. Chanpion list (may support some sort or filter) a tab

3. Item list (may support some sort or filter) a tab

4. User related: 
after log in, the user can:
    - Save the recommended comps (type 1)
    - Create their own comps (type 2)
    - View the saved comps (both type 1 and type 2, but splited)

4. (future) Composisions library (list all compositions, both type 1 and type 2 , and user can leave comments or like or save the compositions, also , the two types should be splited show(buton to swith between two views maybe) )


