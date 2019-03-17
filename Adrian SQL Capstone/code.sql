
A note: for much of the below code, a temporary database called “funnel” is created and used as the basis for queries; as such, it’s presented basically once at the top, and implicitly begins most queries below (certainly all that call “from funnel”)

Q1:

select * from survey
limit 10;

Q2:

select question, count(user_id) from survey
group by 1;

Q4:

select * from quiz limit 5;

select * from home_try_on limit 5;

select * from purchase limit 5;

Q5: 

select * from quiz
limit 5;

select * from home_try_on
limit 5;

select * from purchase
limit 5;

select distinct quiz.user_id,
case when home_try_on.user_id is not null then 'True' else 'False' end as is_home_try_on,
number_of_pairs,
case when purchase.user_id is not null then 'True' else 'False' end as is_purchase
from quiz
left join home_try_on on quiz.user_id = home_try_on.user_id
left join purchase on home_try_on.user_id = purchase.user_id
group by 1
limit 10;

//////

funnel definition:

with funnel as (select distinct quiz.user_id,
case when home_try_on.user_id is not null then 'True' else 'False' end as is_home_try_on,
number_of_pairs,
case when purchase.user_id is not null then 'True' else 'False' end as is_purchase
from quiz
left join home_try_on on quiz.user_id = home_try_on.user_id
left join purchase on home_try_on.user_id = purchase.user_id
group by 1)

percent of quizzed that tried on, and tried who bought:

select 1.0*sum(case when is_home_try_on='True' then 1 else 0 end)/count(is_home_try_on)
as 'Quizzed who tried %',
1.0*sum(case when is_purchase='True' then 1 else 0 end)/sum(case when is_home_try_on='True' then 1 else 0 end)
as 'Tried who bought %'
from funnel;

percent of 3- and 5-triers who bought

select 
100*round(1.0*sum(case when is_purchase='True' and number_of_pairs='3 pairs' then 1 else 0 end)/sum(case when is_home_try_on='True' and number_of_pairs='3 pairs' then 1 else 0 end),2)
as tried_3_conversion_pct,
100*round(1.0*sum(case when is_purchase='True' and number_of_pairs='5 pairs' then 1 else 0 end)/sum(case when is_home_try_on='True' and number_of_pairs='5 pairs' then 1 else 0 end),2)
as tried_5_conversion_pct 
from funnel;

how many 3-try purchases total? 5-try?

select count(is_purchase)
as '3-try purchases'
from funnel
where number_of_pairs = '3 pairs'
and is_purchase is 'True';

select count(is_purchase)
as '5-try purchases'
from funnel
where number_of_pairs = '5 pairs'
and is_purchase is 'True';

percent of quizzed who bought

select 
1.0*sum(case when is_purchase='True' then 1 else 0 end)/count(is_purchase)
as quizzed_bought_pct
from funnel;

most common quiz results; total number and top x

select fit, count(fit) 
from quiz 
group by 1
order by 2 desc;

select shape, count(shape) 
from quiz 
group by 1
order by 2 desc;

select color, count(color) 
from quiz 
group by 1
order by 2 desc;

most common purchases; total number and top x

select model_name as 'Most popular model'
from purchase
group by 1
order by count(model_name) desc
limit 1;

select color as 'Most popular color'
from purchase
group by 1
order by count(color) desc
limit 1;

women vs men

select style, count(style)
from purchase
group by 1
order by 2 desc;

price per customer, and total, for 3 vs 5

different opener:

with funnel as (select distinct quiz.user_id,
case when home_try_on.user_id is not null then 'True' else 'False' end as is_home_try_on,
number_of_pairs,
price
from quiz
left join home_try_on on quiz.user_id = home_try_on.user_id
left join purchase on home_try_on.user_id = purchase.user_id
group by 1)

	for 3 pairs total and per customer:

select 
1.0*sum(price) as '3 total purchase',
round(1.0*sum(price)/count(price),2) as '3 purchase per customer'
from funnel
where price is not null
and number_of_pairs = '3 pairs';

	for 5 pairs total and per customer:

select 
1.0*sum(price) as '5 total purchase',
round(1.0*sum(price)/count(price),2) as '5 purchase per customer'
from funnel
where price is not null
and number_of_pairs = '5 pairs';

offerings: price difference for, say, the same color?

select model_name, color, price
from purchase
group by 1, 2
order by 1, 2 desc;
