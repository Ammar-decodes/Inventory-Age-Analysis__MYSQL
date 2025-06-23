create database warehouse ;
use warehouse;

create table warehouse_data
(
	ID						varchar(10),
	OnHandQuantity			int,
	OnHandQuantityDelta		int,
	event_type				varchar(10),
	event_datetime			timestamp
);

insert into warehouse_data values
('SH0013', 278,   99 ,   'OutBound', '2020-05-25 0:25'), 
('SH0012', 377,   31 ,   'InBound',  '2020-05-24 22:00'),
('SH0011', 346,   1  ,   'OutBound', '2020-05-24 15:01'),
('SH0010', 346,   1  ,   'OutBound', '2020-05-23 5:00'),
('SH009',  348,   102,   'InBound',  '2020-04-25 18:00'),
('SH008',  246,   43 ,   'InBound',  '2020-04-25 2:00'),
('SH007',  203,   2  ,   'OutBound', '2020-02-25 9:00'),
('SH006',  205,   129,   'OutBound', '2020-02-18 7:00'),
('SH005',  334,   1  ,   'OutBound', '2020-02-18 8:00'),
('SH004',  335,   27 ,   'OutBound', '2020-01-29 5:00'),
('SH003',  362,   120,   'InBound',  '2019-12-31 2:00'),
('SH002',  242,   8  ,   'OutBound', '2019-05-22 0:50'),
('SH001',  250,   250,   'InBound',  '2019-05-20 0:45');

select *
from warehouse_data;

with wh as 
         (select * from warehouse_data 
         order by event_datetime desc),
         
	Days as
		(select onhandquantity,event_datetime
		 	  , date_sub(event_datetime, interval "90" day) as day90
              ,date_sub(event_datetime, interval "180" day) as day180
		 	  , date_sub(event_datetime, interval "270" day) as day270
		 	  , date_sub(event_datetime, interval "365" day) as day365
		 from WH limit 1),
       
    inv_90_days as 
				(select sum(WH.OnHandQuantityDelta) as DaysOld_90
		 from WH cross join days
		 where WH.event_datetime >= days.day90
		 and event_type = 'InBound'),                     
         
    inv_90_days_final as 
                 (select case when daysold_90 > onhandquantity then onhandquantity
                 else daysold_90
                 end daysold_90
                   from inv_90_days cross join days ),
              
   inv_180_days as 
				(select sum(WH.OnHandQuantityDelta) as Daysold_180
		 from WH cross join days
		 where wh.event_datetime between day180 and day90
		 and event_type = 'InBound'
         ),
                   
   inv_180_days_final  as 
				(select case when daysold_180 > (onhandquantity - daysold_90) then (onhandquantity - daysold_90)
                 else daysold_180
                 end daysold_180
                   from inv_180_days cross join days 
                   cross join inv_90_days_final),

   inv_270_days as 
				(select coalesce(sum(WH.OnHandQuantityDelta),0) as Daysold_270
		 from WH cross join days
		 where wh.event_datetime between day270 and day180
		 and event_type = 'InBound'
         ),
         
   inv_270_days_final  as 
				(select case when daysold_270 > (onhandquantity -(daysold_90 + daysold_180)) then (onhandquantity -(daysold_90 + daysold_180))
                 else daysold_270
                 end daysold_270
                   from inv_270_days cross join days 
                   cross join inv_180_days_final
                   cross  join inv_90_days_final),
              
  inv_365_days as 
				(select coalesce(sum(WH.OnHandQuantityDelta),0) as Daysold_365
		 from WH cross join days
		 where wh.event_datetime between day365 and day270
		 and event_type = 'InBound'
         ),
         
   inv_365_days_final  as 
				(select case when daysold_365 > (onhandquantity -(daysold_90 + daysold_180 + daysold_270)) 
			      then (onhandquantity -(daysold_90 + daysold_180 + daysold_270))
                 else daysold_365
                 end daysold_365
                   from inv_365_days 
                   cross join  inv_270_days cross join days 
                   cross join inv_180_days_final
                   cross  join inv_90_days_final)            
   
Select daysold_90 as "0-90 days old", 
daysold_180 as "90-180 days old",
daysold_270 as "180-270 days old",
daysold_365 as "270-365 days old"
from inv_90_days_final 
cross join inv_180_days_final
cross join inv_270_days_final
cross join inv_365_days_final;

