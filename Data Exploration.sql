-- what is the total amount each customer spent at the restaurant?
create view Total_Spending_by_customer as
Select customer_id, sum(price) as total_price
from sales
join menu on sales.product_id = menu.product_id
group by customer_id;

-- How many days has each customer visited the restaurant?
create view Customer_Visiting_frequency as
Select customer_id , Count(distinct order_date) as number_of_visits
from sales
group by customer_id;

-- What Was the first item from the menu purchased by each customer?
Create view First_item_purchased as
with customer_first_purchase as (
Select customer_id, Min(order_date) as first_order
from sales
group by customer_id)
Select cfp.customer_id, cfp.first_order,menu.product_name
from customer_first_purchase as cfp
join sales on sales.customer_id = cfp.customer_id
AND cfp.first_order = sales.order_date
join menu on menu.product_id = sales.product_id;

-- What is the most purchased item on the menu and how many times was it purchased?
Create view Most_purchased_item as
Select menu.product_name, count(*) As total_purchased 
from sales
join menu on sales.product_id = menu.product_id
group by menu.product_name
order by total_purchased DESC
limit 1;

-- Which item is most popular for each customer
Create View Item_popularity_by_customer as
With Customer_Popularity as (
Select sal.customer_id, m.product_name ,count(*) as purchase_count,
row_number() Over (Partition by sal.customer_id order by count(*)DESC) 
as ranking
from sales sal
join menu m on sal.product_id = m.product_id
group by sal.customer_id,m.product_name
order by sal.customer_id,purchase_count desc)
Select cp.customer_id,cp.product_name,purchase_count
from customer_popularity as cp
where ranking = 1;

-- Which item was purchased first by the customer after they became a member
Create view first_order_after_membership  as 
With first_order_after_membership as (
Select sales.customer_id, min(order_date) as first_order_member
from sales
join members on sales.customer_id = members.customer_id 
where sales.order_date >= members.join_date
group by sales.customer_id)
Select fom.customer_id, fom.first_order_member,
menu.product_name
from first_order_after_membership as fom
join sales on fom.customer_id = sales.customer_id
And fom.first_order_member = sales.order_date
Join menu on sales.product_id = menu.product_id
order by fom.first_order_member;

-- Which item was purchased just before a customer became a member
	Create View Last_order_before_Membership as
    With Last_order_before_membership as(
	Select sales.customer_id, max(sales.order_date) AS Last_purchase
	from sales 
	join members on sales.customer_id = members.customer_id
	where sales.order_date < members.join_date
	group by sales.customer_id)
	Select lom.customer_id,lom.last_purchase,menu.product_name
	from Last_order_before_membership as lom
	join sales on sales.customer_id = lom.customer_id
	And sales.order_date = lom.Last_purchase
	join menu on sales.product_id = menu.product_id;

-- what is the total items and amount spent for each member before they became a member
Create View total_items_and_Price as
Select sales.Customer_id , Count(*) as Total_items, sum(menu.price)
 AS Total_Spent
from sales 
join menu on sales.product_id = menu.product_id
join members on sales.customer_id = members.customer_id
Where Sales.order_date < members.join_date
group by customer_id
order by customer_id;

-- recreate table
Create view Recreate_Table as
Select s.customer_id,s.order_date,m.product_name,m.price,
case 
when s.order_date >= memb.join_date then 'Yes'
Else'No' End as Member
from sales as s
join menu m on m.product_id = s.product_id
left join members memb on memb.customer_id = s.customer_id

