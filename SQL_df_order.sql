USE yashdb;
GO
SELECT * FROM df_orders;

--1.) Find top 10 highest revenue generating products:

select  top 10 product_id, sum(sale_price * quantity) as revenue
from df_orders
group by product_id
order by revenue desc;

--2.) Find top 5 highest selling products in each region:

with cte as (select region, product_id, sum(quantity) as total_quantity_sold
from df_orders
group by region, product_id)
--order by region ,sales desc)
select * from (
select region, product_id, total_quantity_sold , row_number() over(partition by region order by total_quantity_sold desc) as rn
from cte) A
where rn<= 5
--order  by rn desc

--3.) Find month over month growth comparison for 2022 and 2023 sales

with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

--4.) For each category which month had highest sale

select * from df_orders

with ctf as 
(select format(order_date, 'yyyyMM') as order_year_month, category, sum(sale_price * quantity) as revenue
from df_orders
group by  format(order_date, 'yyyyMM'), category)
--order by year, month)
select * from  
(select *, row_number() over(partition by category order by revenue desc) as rn
from ctf) A
where rn <2
order by order_year_month


--5.) Which sub category had the highest growth by profit in 2023 compare to 2022

with cte as (select sub_category, sum((sale_price - cost_price)* quantity) as profit, year(order_date) as order_year
from df_orders
group by sub_category, year(order_date)
--order by year(order_date),profit desc
)

, cte2 as ( select sub_category, 
sum(case when order_year=2022 then profit else 0 end) as sales_2022,
sum(case when order_year=2023 then profit else 0 end) as sales_2023
from cte 
group by sub_category)

select  top 1 *  , (sales_2023-sales_2022)*100/sales_2022 as percent_profit
from cte2
order by percent_profit desc





