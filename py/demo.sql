select
        distinct
        a.eindt,
      --  case when a.ebelp like '0%' then cast(substring(a.ebelp, patindex('%[^0]%', a.ebelp), len(a.ebelp)-patindex('%[^0]%', a.ebelp)+1) as int)
      --  else cast(a.ebelp as int) end as ebelp,
        a.ebeln,
        a.menge,
        a.wemng,
        b.bukrs,
        b.frgke,
        b.ekgrp,
        b.bedat,
        b.lifnr,
        c.loekz,
        c.idnlf,
        c.infnr,
        c.adpri,
        d.budat,
        d.elikz,
       -- c.netrr/c.peinh as purchase_price,
        null as overdue_or_not,
        null as finish_or_not,
        null as order_num_overdue_days,
        null as order_num_overdue_finish_days,
        null as completion_date
      --  case when datepart(day, d.budat)=getdate() then '当日'
      --  when datepart(day, d.budat)=dateadd(day, -1, getdate()) then '昨日' end as day_c_l,
      --  case when datepart(wk, d.budat)=datepart(wk, getdate()) then '本周'
      --  when datepart(wk, d.budat)=datepart(wk, getdate())-1 then '上周' end as week_c_l,
        -- case when datediff(day, getdate(),a.eindt)<=30 and datediff(day, getdate(),a.eindt)>0 and datediff(day, getdate(),a.eindt)>0 and a.eindt>=convert(nvarchar(8),getdate(),112) then '小于等于30'
        -- when datediff(day, getdate(),a.eindt)>30 and  a.eindt>=convert(nvarchar(8),getdate(),112) then '大于30'
        -- end as delivery_days_30,
        -- case when d.budat>a.eindt and a.menge!=a.wemng then datediff(day, a.eindt, getdate())
        -- when d.budat>a.eindt and a.menge=a.wemng then datediff(day, a.eindt, d.budat)
        -- end as delay_days
from ( select * from yk_admin123_ods.ods_eket where dt ='20240314')a
join  (select * from yk_admin123_ods.ods_ekko_dt where dt ='20240314')b on a.ebeln=b.ebeln
join (select * from  yk_admin123_ods.ods_ekpo_dt where dt ='20240314')c on a.ebeln = c.ebeln 
  and a.ebelp = c.ebelp 
left join (select ebeln,ebelp,max(budat) budat,max(elikz) as elikz  
            from  yk_admin123_ods.ods_ekbe_dt
            where dt = '20240314' and elikz = 'x' 
            group by ebeln,ebelp
        ) d  on a.ebeln=d.ebeln and a.ebelp=d.ebelp
where  -- isdate(a.eindt) = 1 and 
 b.bukrs='2000' and b.ekgrp='203' and c.retpo is null