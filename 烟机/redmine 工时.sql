--刷新平台数据
--172.16.31.120:8080/MSS
--admin
--123456
--ods_redmine           刷新工时
--redmine_dashboard     移动端看板





with tmp as (
select 
distinct
b.name as proj_name,
g.spent_on,
null as create_date,
g.tweek,
i.lastname+i.firstname as assign_user_name,
--e.lastname+e.firstname as assign_user_name,
c.lastname+c.firstname as user_name,
h.name as content_name,
cast(a.id as nvarchar(50))+':'+a.subject as subject,
d.name as tracker_name,
f.name as issue_status,
g.comments,
g.hours,
b.created_on,
a.start_date,
a.due_date,
a.done_ratio
from ODS_REDMINE.dbo.issues a
left join ODS_REDMINE.dbo.projects b on a.project_id=b.id
left join ODS_REDMINE.dbo.trackers d on a.tracker_id=d.id
left join ODS_REDMINE.dbo.users e on a.assigned_to_id=e.id
left join ODS_REDMINE.dbo.issue_statuses f on a.status_id=f.id
left join ODS_REDMINE.dbo.time_entries g on a.id=g.issue_id and a.project_id=g.project_id
left join ODS_REDMINE.dbo.users c on g.user_id=c.id
left join ODS_REDMINE.dbo.enumerations h on g.activity_id=h.id
left join ODS_REDMINE.dbo.users i on a.author_id=i.auth_source_id
where DATEADD(day, -33, getdate())<=g.spent_on   --时间段
)
select * from tmp 
where  user_name like '%yk%' 
order by spent_on


