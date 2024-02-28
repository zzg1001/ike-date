drop table if  exists   meifu_analysis_platform_main_2023_1;
create table meifu_analysis_platform_main_2023_1 as
	select 
		auto_id
		,REGEXP_REPLACE(title, '<[^>]+>', '') AS title 
		,is_comment
		,webpageUrl
		,captureWebsiteNew
		,publishedMinute
		,originType
		,author
		,summary
		,province
		,city
		,originTypeThird
		,secondTradeList
		,originAuthorId
		,referenceKeywordNew
		,shareCount
		,comments
		,praiseNum
		,forwardNumber
		,favouritesCount
		,fansNumber
		,friendsCount
		,gender
		,icpProvince
		,id
		,publishedDay
		,readCount
		,subDomain
		,titleHs
		,topicInteractionCount
		,weiboTopicKeyword
		,weiboUserBeanNew
		,zaikanCount
		,create_date
		,description
		,REGEXP_REPLACE(content, '<[^>]+>', '') AS content 
		,referenceKeyword
		,project_name
	from meifu_analysis_platform_main_2023 ;