truncate table Report0624.dbo.r24_inquiry_status
insert into Report0624.dbo.r24_inquiry_status
select material_code,
       inquiry_hd_cd,
       create_time,
       inquiry_status,
       confirm_number,
       confirm_status
from (
         select a.PRODUCT_CODE                                                            as material_code,
                b.INQUIRY_HD_CD                                                           as inquiry_hd_cd,
                b.CREATED_TS                                                              as create_time,
                case
                    when b.STATUS_CD_ID = 'INQ_HD_STATUS_DRAFT'
                        then '编辑中'

                    when b.STATUS_CD_ID = 'INQ_HD_STATUS_WAITING'
                        then
                            case
                                when ((e.PROCESS_STATUS_CODE = '10') or (e.CURRENT_NODE_TYPE = 'draftNode)'))
                                    then '待审核'
                                else '审核中'
                                end

                    when b.STATUS_CD_ID = 'INQ_HD_STATUS_PUBLISHED'
                        then
                            case
                                when
                                    b.START_DATE>convert(varchar(10),getdate(),120)
                                then '已发布'
                                when
                                    ((b.END_DATE > convert(varchar(10),getdate(),120)) and (b.QUOTING_IND = 'T'))
                                then '已报价'
                                when
                                    ((b.END_DATE > convert(varchar(10),getdate(),120)) and (b.QUOTING_IND = 'F'))
                                then '待报价'
                                when
                                    ((b.START_DATE <=convert(varchar(10),getdate(),120)) and (b.END_DATE <= convert(varchar(10),getdate(),120)))
                                then
                                    case
                                        when
                                            ((b.QUOTING_IND = 'T') and (b.CONFIRM_SOURCE_IND = 'T'))
                                        then '已确认'
                                        when
                                            ((b.QUOTING_IND = 'T') and (b.CONFIRM_SOURCE_IND = 'F'))
                                        then '待确认'
                                        when
                                            (b.QUOTING_IND = 'F')
                                        then '已关闭'
                                        end
                            end
                    when b.STATUS_CD_ID = 'INQ_HD_STATUS_CLOSED'
                        then '已关闭'
                    end
                                                                                          as inquiry_status
                 ,
                c.CONFIRM_NUM                                                             as confirm_number,
       d.STATUS_NAME        as confirm_status,
                row_number() over (partition by PRODUCT_CODE order by b.CREATED_TS desc ) as rn
-- into BI_TEMP.dbo.inquiry_status

         from ODS_SRM.dbo.srm_inq_inquiry_item as a
                  left join ODS_SRM.dbo.srm_inq_inquiry_hd as b
                            on a.INQUIRY_HD_ID = b.id
                  left join ODS_SRM.dbo.srm_inq_supplier_tender_field as c
                            on b.INQUIRY_HD_CD = c.INQUIRY_CD
                  left join ODS_SRM.dbo.srm_inq_supplier_confirm_head_field as d
                            on c.CONFIRM_NUM = d.CONFIRM_NUM
                  left join ODS_SRM.dbo.srm_inq_inquiry_process as e
                            on b.ID =e.REF_ID

         where a.PRODUCT_CODE is not null
            and a.PLANT = '2000'
     ) as a
where rn = 1;