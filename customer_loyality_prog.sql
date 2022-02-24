
------------table creation --------------

create table members
(
customer_id varchar(1) primary key,
join_data date
);

create table menu
(
product_id integer primary key,
product_name varchar(5),
price int
);

create table sales
(
customer_id varchar(1) references members(customer_id),
order_data date,
product_id int references menu(product_id) 
);

--------------insertion--------------------------------------------------------
insert into menu(product_id,product_name,price) values(1,'sushi',10);
insert into menu(product_id,product_name,price) values(2,'curry',15);
insert into menu(product_id,product_name,price) values(3,'ramen',12);

insert into members(customer_id,join_data) values('A','2021-01-07');
insert into members(customer_id,join_data) values('B','2021-01-09');
insert into members(customer_id,join_data) values('C','2021-01-07');

describe members;


insert into sales(customer_id,order_data,product_id) values('A','2021-01-01',1);
insert into sales(customer_id,order_data,product_id) values('A','2021-01-01',2);
insert into sales(customer_id,order_data,product_id) values('A','2021-01-07',2);
insert into sales(customer_id,order_data,product_id) values('A','2021-01-10',3);
insert into sales(customer_id,order_data,product_id) values('A','2021-01-11',3);
insert into sales(customer_id,order_data,product_id) values('A','2021-01-11',3);
insert into sales(customer_id,order_data,product_id) values('B','2021-01-01',2);
insert into sales(customer_id,order_data,product_id) values('B','2021-01-02',2);
insert into sales(customer_id,order_data,product_id) values('B','2021-01-04',1);
insert into sales(customer_id,order_data,product_id) values('B','2021-01-11',1);
insert into sales(customer_id,order_data,product_id) values('B','2021-01-16',3);
insert into sales(customer_id,order_data,product_id) values('B','2021-02-01',3);
insert into sales(customer_id,order_data,product_id) values('C','2021-01-01',3);
insert into sales(customer_id,order_data,product_id) values('C','2021-01-01',3);
insert into sales(customer_id,order_data,product_id) values('C','2021-01-07',3);

select * from menu;
select * from members;
select * from sales;


-------------------question 1 -------------------------------------------
select customer_id,sum(price) as total_expenditure
from menu
inner join sales
on menu.product_id = sales.product_id
group by customer_id;


---------question 2-----------------------------------------------------
select customer_id,count(distinct(order_data)) as total_visit
from sales
group by customer_id
order by total_visit desc;

------------------------------question 3--------------------------------------

select distinct customer_id, product_name from 
(select customer_id, product_name from
(select s.customer_id , m.product_name, rank() over (partition by customer_id order by order_data) as rn
from sales s join menu m on s.product_id = m.product_id) where rn=1);



/*select distinct customer_id, product_name from
(select s.customer_id , m.product_name, rank() over (partition by customer_id order by order_data) as rn
from sales s join menu m on s.product_id = m.product_id) where rn=1;*/

-----------------------------question 4-----------------------------------------

/*with menu_sales as
(
select customer_id,s.product_id,product_name from sales s
join menu m
on s.product_id = m.product_id
)
select distinct customer_id, count(product_name) as total_order, max(product_name) as product
from menu_sales
where product_id = (select max(product_id) from menu_sales)
group by customer_id;*/
----------------------------question 4---------------------------------------
with menu_sales as
(
select customer_id,s.product_id,product_name from sales s
join menu m
on s.product_id = m.product_id
)
select * from (
select product_name, count(product_id) as total_order
from menu_sales
group by product_name
order by total_order desc)
where rownum = 1
;


/*with menu_sales as
(
select customer_id,s.product_id,product_name from sales s
join menu m
on s.product_id = m.product_id
)
select customer_id,max(product_name), count(product_id)
from (
select customer_id,product_id, product_name
from menu_sales
order by customer_id
)
group by customer_id;*/

----------------------------question 5-----------------------------------------

WITH ORDER_SET AS (
select customer_id,product_name,count(s.product_id) as no_of_times_ordered
from sales s inner join menu m on s.product_id=m.product_id 
group by customer_id,product_name order by customer_id ASC,
no_of_times_ordered DESC
), POPULAR_SET AS ( 
select customer_id,product_name,no_of_times_ordered,
rank() over (partition by customer_id order by no_of_times_ordered DESC)
as RANK from ORDER_SET)
select customer_id,product_name,no_of_times_ordered from POPULAR_SET where
RANK = 1;

---------------------------question 6-------------------------------------------
with all_table as
(
select s.product_id,product_name,price,s.customer_id,order_data,join_data from menu m
inner join sales s
on m.product_id = s.product_id
inner join members mem
on mem.customer_id = s.customer_id
)
select customer_id,product_name,order_data
from
(select customer_id,product_name,order_data, rank() over(partition by customer_id order by order_data) as rn
from all_table
where join_data <= order_data ) sn
where rn = 1;

----------------------------question 7-----------------

with all_table as
(
select s.product_id,product_name,price,s.customer_id,order_data,join_data from menu m
inner join sales s
on m.product_id = s.product_id
inner join members mem
on mem.customer_id = s.customer_id
)
select customer_id,product_name,order_data
from
(select customer_id,product_name,order_data, rank() over(partition by customer_id order by order_data) as rn
from all_table
where join_data >= order_data ) sn
where rn = 1;

------------------------- question 8 -------------------------------------
with all_table as
(
select s.product_id,product_name,price,s.customer_id,order_data,join_data from menu m
inner join sales s
on m.product_id = s.product_id
inner join members mem
on mem.customer_id = s.customer_id
)
select customer_id,sum(price) total_amount_spent,count(product_name) total_products
from all_table
where join_data>order_data
group by customer_id;


-----------------question 9---------------------------------------------------
with menu_sales as
(
select customer_id,s.product_id,product_name,price from sales s
join menu m
on s.product_id = m.product_id
)
select customer_id,sum(total_spent), sum(rewards) as total_rewards
from(
select customer_id,product_name,total_spent,
 case 
    when product_name ='curry' then 10* total_spent
    when product_name ='ramen' then 10*total_spent
    when product_name = 'sushi' then 20* total_spent
end as rewards
from(
select customer_id,product_name,sum(price) as total_spent
from menu_sales
group by customer_id,product_name
order by customer_id)
)
group by customer_id
order by customer_id;


-------------------question 10------------------------------------------------

select customer_id,SUM(amount_spent*2*10) AS POINTS FROM (
select s.customer_id,m.product_name,sum(m.price) as amount_spent
from sales s inner join menu m on s.product_id = m.product_id
inner join members me on s.customer_id=me.customer_id 
where join_data<=order_data and join_data+7>=order_data
and to_char(order_data,'MM')='01'
group by s.customer_id,m.product_name order by s.customer_id) A group by customer_id order by customer_id;