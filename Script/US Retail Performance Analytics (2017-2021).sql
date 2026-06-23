select * from store_sales_usa;
select * from `sales order_usa`;
describe `sales order_usa`;
select * from `sales team_usa`;
describe `sales team_usa`;
select * from region_usa;

-- Removing the whitespaces and commas from the unit price and unit cost so that the datatype can be changed
Update `sales order_usa`
Set 
`Unit Price` = trim(replace(replace(`Unit Price`,'$',''),',','')),
`Unit Cost` = trim(replace(replace(`Unit Cost`,'$',''),',',''));

-- Changing the datatype from text to decimal
Alter table `sales order_usa`
Modify column `Unit Price` decimal(19,2),
Modify column `Unit Cost` decimal(19,2);

-- Calculating Total Profit from unit price and unit cost
select round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))) as Total_Profit
from `sales order_usa`;
-- Total Profit is '$21,325,311'

-- Calculating Total Revenue from unit price and discount
select round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`))) as Total_Revenue
from `sales order_usa`;
-- Total Revenue is '$73,143,380'

-- Calculating Profit Margin from revenue and profit
select round((round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))) / round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`))))*100,2) as Profit_Margin
from `sales order_usa`;
-- Profit Margin is '29.16%'

-- Calculating Total Quantity Sold
select sum(`Order Quantity`) as Total_Quantity_Sold
from `sales order_usa`;
-- Total Quantity Sold is '36,162'

-- Calculating Total Number of Customers using COUNT
select count( distinct _CustomerID) as Total_Number_of_Customers
from `sales order_usa`;
-- Total Customers is '50'

-- Total Profit by Region and which region performed best
Select `sales team_usa`.Region,round(sum(`sales order_usa`.`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))) as Total_Profit
from `sales team_usa` 
left join `sales order_usa` on
`sales team_usa`._SalesTeamID =`sales order_usa`._SalesTeamID
group by Region
order by Region asc;
-- The 'Midwest' is the best performing region with a total profit of '$6,180,636'

-- Product that contributed the most to profit per region
With RankedData as(
Select `sales order_usa`._ProductID,`sales team_usa`.Region,
rank() over (partition by `sales team_usa`.Region order by sum(`sales order_usa`.`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))desc) as Profit_rank
from `sales team_usa` 
right join `sales order_usa` on
`sales team_usa`._SalesTeamID =`sales order_usa`._SalesTeamID
group by Region, _ProductID
)
select _ProductID,Region, Profit_rank from RankedData
group by Region, _ProductID
having Profit_rank = 1;
-- Product '35' Contributed the most to the profit of the 'Midwest' region
-- Product '23' Contributed the most to the profit of the 'Northeast' region
-- Product '24' Contributed the most to the profit of the 'South' region
-- Product '11' Contributed the most to the profit of the 'West' region

-- How do different sales channels affect profit
select `Sales Channel`, round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))) as Total_Profit
from `sales order_usa`
group by `Sales Channel`;
-- The Sales Channel 'In-Store' has the most profit with '$8,797,853'

-- Average Profit across different regions
Select `sales team_usa`.Region,round(avg(`sales order_usa`.`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))) as Total_Average_Profit
from `sales team_usa` 
left join `sales order_usa` on
`sales team_usa`._SalesTeamID =`sales order_usa`._SalesTeamID
group by Region
order by Region asc;
-- The Midwest has the highest average profit per region of	$2,698

-- Top 10 Customers in terms of revenue generation
select _CustomerID, round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`)-(`Unit Cost`*`Order Quantity`))) as Total_Profit
from `sales order_usa`
group by _CustomerID
order by Total_Profit desc
limit 10;
-- Customer 12 generated the most profit of $616,719

-- Geographical distribution by customers
select `sales team_usa`.Region, count(`sales order_usa`._CustomerID) as Number_of_Customers
from `sales team_usa`
right join `sales order_usa` on
`sales team_usa`._SalesTeamID = `sales order_usa`._SalesTeamID
group by Region
order by Number_of_Customers desc;
-- The 'Midwest' has the most customers of any region with '2291'

-- Sales team member driving the most revenue
select `sales team_usa`.`Sales Team`, round(sum(`Unit Price`*`Order Quantity`*(1-`Discount Applied`))) as Total_Revenue
from `sales team_usa`
right join `sales order_usa` on
`sales team_usa`._SalesTeamID = `sales order_usa`._SalesTeamID
group by `Sales Team`
order by Total_Revenue desc;
-- Donald Reynolds was responsible for driving the most revenue with $2,980,413







