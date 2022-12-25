-- Pulling the total number of views along with their percent of total for each content style (This includes both paid and non paid videos)

SELECT 
	*,
    ExecutionerViews / Total_Views * 100 AS ExecutionerViewPercentage,
    UGCViews / Total_Views * 100 AS UGCViewPercentage,
    CampaignViews / Total_Views * 100 AS CampaignViewPercentage,
    InfluencerViews / Total_Views * 100 AS InfluencerViewPercentage
FROM
    (SELECT
	SUM(CASE WHEN content_style = 'Executioner' THEN Views END) ExecutionerViews,
    SUM(CASE WHEN content_style = 'UGC' THEN Views END) UGCViews,
    SUM(CASE WHEN content_style = 'campaign' THEN Views END) CampaignViews,
    SUM(CASE WHEN content_style = 'Influencer' THEN Views END) InfluencerViews,
    SUM(Views) AS Total_Views
FROM liquiddeath.ldengagement) x;

-- Finding the sum cost and sum views of each content style (Incorporate that these numbers are specifically from whenever Tony gathered the data)

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Spent
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyfinal m ON e.video_name = m.ad_name;

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN e.views END) InfluencerViews,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN e.views END) ExecutionerViews,
    SUM(CASE WHEN e.content_style = 'campaign' THEN e.views END) CampaignViews,
    SUM(e.views) AS Total_Views
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyfinal m ON e.video_name = m.ad_name;

-- calculating how much each view costs across content styles (Again this may not be a great metric considering some of these campaigns are meant to gain followers and not views

WITH TotalCost_TotalViews AS(SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(CASE WHEN e.content_style = 'Influencer' THEN e.views END) InfluencerViews,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN e.views END) ExecutionerViews,
    SUM(CASE WHEN e.content_style = 'campaign' THEN e.views END) CampaignViews
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyfinal m ON e.video_name = m.ad_name)
SELECT
	InfluencerCost / InfluencerViews AS InfluencerCostPerView,
    ExecutionerCost / ExecutionerViews AS ExecutionCostPerView,
    CampaignCost / CampaignViews AS CampaignCostPerView
FROM TotalCost_TotalViews;

-- After this point a new table called LDMoneyV3 was added that allowed us to compare view and follow campaigns so all of the above queries do not account for follow or view campaigns

SELECT * 
FROM liquiddeath.ldmoneyv3;

-- Searching for any errors where tables won't join or if data types were imported improperly

SELECT COUNT(*)
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name;

-- This count function should return 40 but is only returning 37 As shown below

SELECT COUNT(*) FROM liquiddeath.ldmoneyv3;

-- Now we are going to try to find which field or fields are not joining

SELECT *
FROM liquiddeath.ldengagement e
RIGHT JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name;

-- Now we have found that water boy pt 1, KFAD, and the halloween costume video from ldmoneyv3 are not finding a field to match in ldengagement so we will take a look at them

SELECT *
FROM liquiddeath.ldengagement
WHERE video_name IN('KFAD', 'water boy pt 1', 'halloween costume');

SELECT *
FROM liquiddeath.ldmoneyv3
WHERE ad_name IN('KFAD', 'water boy pt 1', 'halloween costume');

-- With these two queries we have found that both of the errors occurred in the ldengagement table

SELECT *
FROM liquiddeath.ldengagement
WHERE video_name LIKE '%KFAD%' OR video_name LIKE '%water%boy%1%' OR video_name LIKE '%halloween%';

-- Now we know that all of the video names are there, there is just some type of error like an extra space that may be disallowing them to be joined with the ldmoneyv3 table 

SELECT *
FROM liquiddeath.ldengagement
WHERE video_name = 'water boy pt1';

-- here we found that water boy pt 1 lacks a space between pt and 1

SELECT *
FROM liquiddeath.ldengagement
WHERE video_name = 'KFAD ';

-- We found that KFAD has an extra space after the text

SELECT *
FROM liquiddeath.ldengagement
WHERE video_name = 'halloween custume';

-- lastly we found that costume is simply just spelled incorrectly so we will now update the table to fix these errors

UPDATE liquiddeath.ldengagement
SET video_name = 'water boy pt 1'
WHERE video_name = 'water boy pt1';

UPDATE liquiddeath.ldengagement
SET video_name = 'KFAD'
WHERE video_name = 'KFAD ';

UPDATE liquiddeath.ldengagement
SET video_name = 'halloween costume'
WHERE video_name = 'halloween custume';

-- Now that all of our tables are updated, we will take a look back at the original query and see if we get 40 rather than 37

SELECT COUNT(*)
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name;

-- Now that the table is returning 40 rows, we are ready to move onto analyzing the new data

-- Finding how much money was spent on each content style across the two different campaign types

SELECT
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Cost_Follower
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE m.campaign_type = 'Follow';

SELECT
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Cost_Views
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE m.campaign_type = 'Views';

SELECT
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Cost
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name;


-- Finding highest impressions based on campaign type and content style

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.impression END) InfluencerImpressions,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.impression END) ExecutionerImpressions,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.impression END) CampaignImpressions,
    SUM(m.impression) AS Total_Impressions
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE m.campaign_type = 'Follow';

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.impression END) InfluencerImpressions,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.impression END) ExecutionerImpressions,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.impression END) CampaignImpressions,
    SUM(m.impression) AS Total_Impressions
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE m.campaign_type = 'Views';

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.impression END) InfluencerImpressions,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.impression END) ExecutionerImpressions,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.impression END) CampaignImpressions,
    SUM(m.impression) AS Total_Impressions
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name;

-- the cost per single impression broken down by view or follow campaigns

SELECT 
	SUM(cost) / SUM(impression) AS cost_per_single_impression_follow
FROM liquiddeath.ldmoneyv3
WHERE campaign_type = 'follow';

SELECT 
	SUM(cost) / SUM(impression) AS cost_per_single_impression_view
FROM liquiddeath.ldmoneyv3
WHERE campaign_type = 'views';

SELECT 
	SUM(cost) / SUM(impression) AS cost_per_single_impression
FROM liquiddeath.ldmoneyv3;

-- Finding the sum of impressions between follow and view campaigns along with their total cost

SELECT 
	SUM(CASE WHEN campaign_type = 'Follow' THEN Impression END) AS Follow_campaign_Impressions,
    SUM(CASE WHEN campaign_type = 'Views' THEN Impression END) AS View_campaign_Impressions,
    SUM(CASE WHEN campaign_type = 'Follow' THEN Cost END) AS Follow_campaign_cost,
    SUM(CASE WHEN campaign_type = 'Views' THEN Cost END) AS View_campaign_cost
FROM LiquidDeath.LDMoneyV3;

-- Now lets find the cost per impression broken down by campaign type (but add them together to graph more effectively in tableau)

SELECT 
	View_campaign_cost / View_campaign_Impressions AS View_Campaign_CostPerImpression,
    Follow_campaign_cost / Follow_campaign_Impressions AS Follow_Campaign_CostPerImpression
FROM (SELECT 
	SUM(CASE WHEN campaign_type = 'Follow' THEN Impression END) AS Follow_campaign_Impressions,
    SUM(CASE WHEN campaign_type = 'Views' THEN Impression END) AS View_campaign_Impressions,
    SUM(CASE WHEN campaign_type = 'Follow' THEN Cost END) AS Follow_campaign_cost,
    SUM(CASE WHEN campaign_type = 'Views' THEN Cost END) AS View_campaign_cost
FROM LiquidDeath.LDMoneyV3) x;

-- Finding the top ten videos with the highest engagement rate

SELECT 
	ad_name,
	SUM(cost) AS total_cost,
    AVG(CPM) AS avg_cpm,
    SUM(Impression) AS total_impressions,
    AVG(engagement_rate) AS avg_ER,
    SUM(Paid_followers) AS Total_followers
FROM LiquidDeath.ldmoneyv3
GROUP BY ad_name
ORDER BY avg_ER DESC
LIMIT 10;

-- Finding campaigns and their corresponding top ten videos with the most paid followers gained

SELECT
	ad_name,
    paid_followers,
    campaign_type,
    cost
FROM liquiddeath.ldmoneyv3
ORDER BY paid_followers DESC
LIMIT 10;

-- finding the sum difference of followers gained between follow and view campaigns (it is important to note what is more important to the company: number of impressions or follower count)
-- Follower campaigns were spent on nearly two-to-one in comparison to view campaigns but view campaigns raked in nearly double the number of impressions

SELECT 
	SUM(CASE WHEN campaign_type = 'follow' THEN paid_followers END) AS TotalFollowers_Follow,
    SUM(CASE WHEN campaign_type = 'Views' THEN paid_followers END) AS TotalFollowers_Views,
    SUM(paid_followers) AS TotalFollowersGained
FROM LiquidDeath.LDMoneyV3;

-- Finding a possible correlation between cost and paid followers
-- Finding a possible correlation bewteen CPM and followers
-- Finding a possible correlation between Impressions and cost
-- No analysis will be done in SQL, I will take the below query and create a scatter plot in Tableau to find the Correlation Coefficient
 
SELECT 
	ad_name, 
    cost,
    paid_followers,
    campaign_type,
    impression,
    cpm
FROM liquiddeath.ldmoneyv3;

-- Trying to find number of views across the different category types for those which are strictly view and strictly follow campaigns
-- seperate the tables by campaign type, assign a 1 or 2 value to each of the campaign types and then unionize and sort by ad name and get rid of those which different types

WITH V AS (SELECT
	*
FROM liquiddeath.ldmoneyv3
WHERE campaign_type = 'views'),

F AS (SELECT
	*
FROM liquiddeath.ldmoneyv3
WHERE campaign_type = 'follow')

SELECT 
	V.*,
    F.campaign_type
FROM V
INNER JOIN F ON V.ad_name = F.ad_name;

-- Using the above query to see which paid videos ran both follow and view campaigns so I can exclude them from view vs follow campigns and how successful they were in total views

SELECT
	* 
FROM liquiddeath.ldmoneyv3
WHERE ad_name NOT IN('bert', 'cherie', 'steve-o', 'Superbowl Ad');

-- We have found that these 4 are the only ones with two different types of ads so we can view the others with the other table to compare theie views and cost
-- The below queries show differences in cost for videos ONLY which had one single type of campaign run on them

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Spent
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE ad_name NOT IN('bert', 'cherie', 'steve-o', 'Superbowl Ad') AND campaign_type = 'Follow';

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Spent
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE ad_name NOT IN('bert', 'cherie', 'steve-o', 'Superbowl Ad') AND campaign_type = 'Views';

SELECT 
	SUM(CASE WHEN e.content_style = 'Influencer' THEN m.cost END) InfluencerCost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) ExecutionerCost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) CampaignCost,
    SUM(m.cost) AS Total_Spent
FROM liquiddeath.ldengagement e
JOIN liquiddeath.ldmoneyv3 m ON e.video_name = m.ad_name
WHERE ad_name NOT IN('bert', 'cherie', 'steve-o', 'Superbowl Ad');

-- Now we will look at the difference in views 
-- Note that when joining LDEndgagement on LDMoneyV3, we only have the video's title to join, so whenever a video appears twice in LDMoneyV3, it's view count doubles or even triples so we used a subquery to only show video titles once

SELECT 
    SUM(CASE WHEN e.content_style = 'Influencer' THEN e.views END) InfluencerViews,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN e.views END) ExecutionerViews,
    SUM(CASE WHEN e.content_style = 'campaign' THEN e.views END) CampaignViews,
    SUM(e.views) AS Total_Views
FROM (
    SELECT DISTINCT(ad_name), campaign_type
    FROM liquiddeath.ldmoneyv3
    GROUP BY ad_name
) m
JOIN liquiddeath.ldengagement e ON e.video_name = m.ad_name
WHERE m.ad_name NOT IN ('bert', 'cherie', 'steve-o', 'Superbowl Ad') AND campaign_type = 'Follow';

SELECT 
    SUM(CASE WHEN e.content_style = 'Influencer' THEN e.views END) InfluencerViews,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN e.views END) ExecutionerViews,
    SUM(CASE WHEN e.content_style = 'campaign' THEN e.views END) CampaignViews,
    SUM(e.views) AS Total_Views
FROM (
    SELECT DISTINCT(ad_name), campaign_type
    FROM liquiddeath.ldmoneyv3
    GROUP BY ad_name
) m
JOIN liquiddeath.ldengagement e ON e.video_name = m.ad_name
WHERE m.ad_name NOT IN ('bert', 'cherie', 'steve-o', 'Superbowl Ad') AND campaign_type = 'views';

SELECT 
    SUM(CASE WHEN e.content_style = 'Influencer' THEN e.views END) InfluencerViews,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN e.views END) ExecutionerViews,
    SUM(CASE WHEN e.content_style = 'campaign' THEN e.views END) CampaignViews,
    SUM(e.views) AS Total_Views
FROM (
    SELECT DISTINCT(ad_name)
    FROM liquiddeath.ldmoneyv3
    GROUP BY ad_name
) m
JOIN liquiddeath.ldengagement e ON e.video_name = m.ad_name
WHERE m.ad_name NOT IN ('bert', 'cherie', 'steve-o', 'Superbowl Ad');

-- Finding top ten most spent on videos

SELECT
	ad_name,
    SUM(cost) AS Total_Spent
FROM liquiddeath.ldmoneyv3
GROUP BY ad_name
ORDER BY Total_Spent DESC
LIMIT 10;

-- Finding the exact view per impression between the two types of campaigns

SELECT 
	View_campaign_cost / View_campaign_Impressions AS View_Campaign_CostPerImpression,
    Follow_campaign_cost / Follow_campaign_Impressions AS Follow_Campaign_CostPerImpression
FROM (SELECT 
	SUM(CASE WHEN campaign_type = 'Follow' THEN Impression END) AS Follow_campaign_Impressions,
    SUM(CASE WHEN campaign_type = 'Views' THEN Impression END) AS View_campaign_Impressions,
    SUM(CASE WHEN campaign_type = 'Follow' THEN Cost END) AS Follow_campaign_cost,
    SUM(CASE WHEN campaign_type = 'Views' THEN Cost END) AS View_campaign_cost
FROM LiquidDeath.LDMoneyV3) x;

-- Finding the exact view per impression between the three main content styles

SELECT
	Influencer_Cost / Influencer_Impressions AS Influencer_CostPerImpression,
    Executioner_Cost / Executioner_Impressions AS Executioner_CostPerImpression,
    Campaign_Cost / Campaign_Impressions AS Campaign_CostPerImpression
FROM (SELECT
	SUM(CASE WHEN e.content_style = 'influencer' THEN m.impression END) AS Influencer_Impressions,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.impression END) AS Executioner_Impressions,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.impression END) AS Campaign_Impressions,
    SUM(CASE WHEN e.content_style = 'influencer' THEN m.cost END) AS Influencer_Cost,
    SUM(CASE WHEN e.content_style = 'Executioner' THEN m.cost END) AS Executioner_Cost,
    SUM(CASE WHEN e.content_style = 'campaign' THEN m.cost END) AS Campaign_Cost
FROM liquiddeath.ldmoneyv3 m
JOIN liquiddeath.ldengagement e ON m.ad_name = e.video_name) X;

-- Finding the average number of impressions seperated by the content styles

SELECT
	AVG(CASE WHEN e.content_style = 'influencer' THEN m.impression END) AS AVG_Influencer_Impressions,
    AVG(CASE WHEN e.content_style = 'Executioner' THEN m.impression END) AS AVG_Executioner_Impressions,
    AVG(CASE WHEN e.content_style = 'Campaign' THEN m.impression END) AS AVG_Campaign_Impressions
FROM liquiddeath.ldmoneyv3 m
JOIN liquiddeath.ldengagement e ON m.ad_name = e.video_name;

-- Tallying up the number of each videos that were posted in 2022 under each content style

SELECT
    COUNT(CASE WHEN e.content_style = 'influencer' THEN ad_name END) inf,
    COUNT(CASE WHEN e.content_style = 'executioner' THEN ad_name END) EXe,
    COUNT(CASE WHEN e.content_style = 'Campaign' THEN ad_name END) camp
FROM liquiddeath.ldmoneyv3 m
JOIN liquiddeath.ldengagement e ON m.ad_name = e.video_name


	
