-- 1.Fetch all the paintings which are not displayed on any museums?

select distinct name 
from work
where museum_id is null;

-- 2.Are there any museums without any paintings?

select m.name, count(w.work_id) as count
from museum m
left join work w
on m.museum_id = w.museum_id 
and w.museum_id is not null
group by m.name
having count(w.work_id) = 0
order by count(w.work_id) desc;

-- 3.How many paintings have an asking price of more than their regular price?

select count(work_id) as no_of_paintings
from product_size 
where sale_price > regular_price;

-- 4.Identify the paintings whose asking price is less than 50% of its regular price. 

select distinct w.name  as Paintings
from product_size p
join work w
on p.work_id = w.work_id
where p.sale_price < 0.5* p.regular_price;      # Approach 1


with cte as (
select work_id from product_size where sale_price < 0.5 *  regular_price) 
select distinct t2.name
from cte t1
join work t2
on t1.work_id = t2.work_id;                      # Approach 2

-- 5.Which canva size costs the most?

select c.label as Canva_size, p.sale_price as Price
from canvas_size c
left join product_size p
on c.size_id = p.size_id
where p.sale_price = (select max(sale_price) from product_size);

-- 6.Delete duplicate records from work,product_size,subject and image_link tables.

with cte as 
(select work_id, artist_id,
row_number() over(partition by work_id,artist_id) as rnk
from work
)
select * 
from work
where work_id in (select work_id
from cte
where rnk > 1);

with cte as (
select work_id, size_id,
row_number() over(partition by work_id,size_id) as rnk
from product_size
)
select *
from product_size
where work_id in ( select work_id
from cte
where rnk > 1);

with cte as (
select work_id,subject,
row_number() over(partition by work_id, subject) as rnk
from subject
)
select *
from subject
where work_id in (select work_id
from cte
where rnk >1);

with cte as (
select work_id,
row_number() over(partition by work_id) as rnk
from image_link
)
select * 
from image_link
where work_id in (select work_id
from cte 
where rnk > 1);


-- 7.Identify the museums with invalid city information in the given dataset

select distinct name 
from museum
where cast(city as integer) != 0;


-- 8.Museum_Hours table has 1 invalid entry. Identify it and remove it. 

select *
from museum_hours
where close like '___:00:PM';


-- 9.Fetch the top 10 most famous painting subject.

select s.subject, count(w.work_id) as count
from subject s
left join work w
on s.work_id = w.work_id
group by  s.subject
order by count(w.work_id) desc
limit 10;


-- 10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.

with cte as (
select museum_id 
from museum_hours 
where day in ('Sunday','Monday')
group by museum_id
having count(distinct(day) = 2 )
)
select distinct m.name, m.city 
from cte c
join museum m
on c.museum_id = m.museum_id
order by m.city desc;


-- 11. How many museums are open every single day?

with cte as (
select museum_id
from museum_hours
where day in ('Sunday','Monday')
group by museum_id
having count(distinct(day) = 7)
)
select m.name,m.city
from cte c
join museum m 
on c.museum_id = m.museum_id
order by m.city desc;


-- 12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

select m.name, count(w.work_id) as count
from museum m
join work w
on m.museum_id = w.museum_id
and w.museum_id is not null
group by m.name
order by count(w.work_id) desc
limit 5;


-- 13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

select a.full_name, count(w.artist_id) as count
from artist a
join work w
on a.artist_id = w.artist_id
and w.artist_id is not null
group by a.full_name
order by count(w.artist_id) desc
limit 5;


-- 14.Display the 3 least popular canva sizes

select c.label, count(c.label) as count
from product_size p
join work w
on w.work_id = p.work_id
join canvas_size c
on p.size_id = c.size_id
where c.label is not null
group by c.label
order by count(c.label) asc
limit 3;


-- 15. Which museum has the most no of most popular painting style?

with cte as (
select museum_id,style,count(style) as count
from work
where museum_id is not null
and style is not null
group by museum_id,style
)
select m.name, c.style, c.count
from cte c
join museum m
on c.museum_id = m.museum_id
where count in (select max(count) from cte);


-- 16. Identify the artists whose paintings are displayed in multiple countries

with cte as (
select w.artist_id, count(m.country) as count
from work w
join museum m
on w.museum_id = m.museum_id
group by w.artist_id
having count(m.country) > 1
)
select a.full_name, c.count
from cte c
join artist a 
on a.artist_id = c.artist_id
order by c.count desc;


-- 17. Display the country and the city with most no of museums. 
--      Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma. 

with cte as (
select country,city,count(city) as count
from museum 
group by country,city
order by count(city) desc
)
select *
from cte
where count in (select max(count) from cte);


-- 18. Identify the artist and the museum where the most expensive and least expensive painting is placed. 
--       Display the artist name, sale_price, painting name, museum name, museum city and canvas label.

with artist_max as (
select a.full_name,max(p.sale_price) as price
from work w
join artist a on w.artist_id = a.artist_id
join museum m on m.museum_id = w.museum_id
join product_size p on p.work_id = w.work_id
group by a.full_name
order by max(p.sale_price) desc
limit 1
),
artist_min as (
select a.full_name,min(p.sale_price) as price
from work w
join artist a on w.artist_id = a.artist_id
join museum m on m.museum_id = w.museum_id
join product_size p on p.work_id = w.work_id
group by a.full_name
order by min(p.sale_price) asc
limit 1
)
select * from artist_max
union all
select * from artist_min;


with artist_max as (
select m.name,max(p.sale_price) as price
from work w
join artist a on w.artist_id = a.artist_id
join museum m on m.museum_id = w.museum_id
join product_size p on p.work_id = w.work_id
group by m.name
order by max(p.sale_price) desc
limit 1
),
artist_min as (
select m.name,min(p.sale_price) as price
from work w
join artist a on w.artist_id = a.artist_id
join museum m on m.museum_id = w.museum_id
join product_size p on p.work_id = w.work_id
group by m.name
order by min(p.sale_price) asc
limit 1
)
select * from artist_max
union all
select * from artist_min;


-- 19. Which country has the 5th highest no of paintings?

with cte as (
select country,count(country) as count
from museum m
join work w
on m.museum_id = w.museum_id
group by country
order by count(country) desc
),
cte1 as (
select *,
row_number() over(order by count desc) as rnk
from cte)
select country,count 
from cte1
where rnk = 5;


-- 20. Which are the 3 most popular and 3 least popular painting styles?

with max_style as (
select style, count(style) as count
from work
where style is not null
group by style
order by count(style) desc
limit 3
),
min_style as (
select style, count(style) as count
from work
where style is not null
group by style
order by count(style) asc
limit 3
)
select * from max_style
union all
select * from min_style;