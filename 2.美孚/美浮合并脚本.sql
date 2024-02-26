create table   meifu_analysis_platform_main_2023 as 
select 
	auto_id
	,title
	,is_comment
	,webpageUrl
	,captureWebsiteNew
	,publishedMinute
	,originType
	,author
 -- ,relativity
	,summary
	,province
	,city
	,originTypeThird
	,secondTradeList
	,originAuthorId
 -- ,verified
	,referenceKeywordNew
	,shareCount
	,comments
	,praiseNum
	,forwardNumber
 -- ,favourites_count
	,favouritesCount
 -- ,collectCount
	,fansNumber
 -- ,followers_count
	,friendsCount
	,gender
	,icpProvince
	,id
	,publishedDay
	,readCount
	,subDomain
	,titleHs
	,topicInteractionCount
 -- ,url
	,weiboTopicKeyword
	,weiboUserBeanNew
	,zaikanCount
	,create_date
	,description
	,content
	,referenceKeyword
	,project_name
from data_23q3_1 
