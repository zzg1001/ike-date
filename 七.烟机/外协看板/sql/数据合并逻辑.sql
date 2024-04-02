     drop table sap_base_field_merge_wide;

                select 
                *
                into Outsourcing_Dashboard.dbo.sap_base_field_merge_wide
                from (
                    SELECT
                    (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) ) year_month 
                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
                    ,*
                    ,GETDATE() etl_time
                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
                where (LOEKZ <> 'L' or LOEKZ is null) 
                and BUKRS='2000' and FRGKE='S' 
            and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )=CONVERT(varchar(7), GETDATE(), 120)

            union all

            SELECT 
                    (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2))  year_month
                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
                    ,*
                    ,GETDATE() etl_time
                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
                where (LOEKZ <> 'L' or LOEKZ is null) 
                and BUKRS='2000' and FRGKE='S' 
                and finish_or_not = '未完成' and overdue_or_not = '逾期'
                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )< CONVERT(varchar(7), GETDATE(), 120)
                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2))>= CONVERT(varchar(7), DATEADD(MONTH, -12, GETDATE()), 120)

                ) a;

              insert into  Outsourcing_Dashboard.dbo.sap_base_field_merge_wide
                select 
                 *
                from Outsourcing_Dashboard.dbo.sap_base_field_histry_wide
