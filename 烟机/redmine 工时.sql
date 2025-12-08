
with tmp as (
select 
distinct
b.name as proj_name,
g.spent_on,
null as create_date,
g.tweek,
i.lastname+i.firstname as assign_user_name,
c.lastname+c.firstname as user_name,
h.name as content_name,
cast(a.id as nvarchar(50))+':'+a.subject as subject,
d.name as tracker_name,
f.name as issue_status,
g.comments,
g.hours,
j.value is_over_hour, 
b.created_on,
a.start_date,
a.due_date,
a.done_ratio
from ODS_REDMINE.dbo.issues a
left join ODS_REDMINE.dbo.projects b 
       on a.project_id=b.id
left join ODS_REDMINE.dbo.trackers d 
       on a.tracker_id=d.id
left join ODS_REDMINE.dbo.users e 
       on a.assigned_to_id=e.id
left join ODS_REDMINE.dbo.issue_statuses f 
       on a.status_id=f.id
left join ODS_REDMINE.dbo.time_entries g 
       on a.id=g.issue_id 
			and a.project_id=g.project_id
left join ODS_REDMINE.dbo.users c 
       on g.user_id=c.id
left join ODS_REDMINE.dbo.enumerations h 
       on g.activity_id=h.id
left join ODS_REDMINE.dbo.users i 
       on a.author_id=i.auth_source_id
left join  ODS_REDMINE.dbo.custom_values j 
       on g.id = j.customized_id
		  and custom_field_id =9
where g.spent_on>='2025-01-01' 
)
select * from tmp 
where  user_name like '%yk%' or user_name like '%秦帅鹏%'
order by spent_on
