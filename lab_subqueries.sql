-- Lab | SQL Subqueries --

-- In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.
use sakila;

-- 1 How many copies of the film Hunchback Impossible exist in the inventory system?

#join:
select f.title, count(i.inventory_id) as nr_of_copies 
from inventory as i
join film as f
on i.film_id = f.film_id
where f.title = 'Hunchback Impossible';

#subquery option 1:
select f.title, count(i.inventory_id) as nr_of_copies 
from inventory as i
join film as f
on i.film_id = f.film_id
where i.film_id in (
	select film_id
    from film
    where title = 'Hunchback Impossible');

#subquery option 2:
select b.title, a.nr_of_copies
from (
	select film_id, count(inventory_id) as nr_of_copies
	from inventory
	group by film_id
	) as a
join film as b
using (film_id)
where b.title = 'Hunchback Impossible';


-- 2 List all films whose length is longer than the average of all the films.

select title, length 
from film
where length > (select avg(length) from film)
order by length desc;


-- 3 Use subqueries to display all actors who appear in the film Alone Trip.

#subquery option 1:
select f.title as film_title, fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name
from film as f
join film_actor as fa
on f.film_id = fa.film_id
join actor as a
on fa.actor_id = a.actor_id
where f.film_id in (
	select film_id
    from film
    where title = 'Alone Trip');

#subquery option 2:
select actor_id, first_name, last_name
from actor
where actor_id in (
	select actor_id
	from film_actor
	where film_id in (
		select film_id
		from film
		where title = 'Alone Trip'))
order by last_name, first_name;


-- 4 Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

#join
select c.name as category, f.film_id, f.title as film_title
from film as f
join film_category as fc
on f.film_id = fc.film_id
join category as c
on fc.category_id = c.category_id
where c.name = 'Family'
order by f.title;

#subquery
select film_id, title
from film
where film_id in (
	select film_id 
	from film_category
	where category_id in (
		select category_id
		from category
		where name = 'family'))
order by title;


-- 5 Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

#join
select concat(c.first_name, ' ', c.last_name) as customer_name, email
from customer as c
join address as a
on c.address_id = a.address_id
join city as ci
on a.city_id = ci.city_id
join country as co
on ci.country_id = co.country_id
where country = 'Canada';

#subquery
select concat(first_name,' ',last_name) as customer_name, email
from customer 
where address_id in (
	select address_id 
    from address 
    where city_id in (
		select city_id 
		from city 
		where country_id in (
			select country_id 
			from country 
            where country = 'Canada')));


-- 6 Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

#step 1:
select actor_id, count(film_id) as no_of_films
from film_actor
group by actor_id;

#step 2:
select actor_id
from (select actor_id, count(film_id) as no_of_films
	from film_actor
	group by actor_id
	order by no_of_films desc
	limit 1) sub1;

#step 3:
select film_id 
from film_actor
where actor_id in (
	select actor_id
		from (select actor_id, count(film_id) as no_of_films
		from film_actor
		group by actor_id
		order by no_of_films desc
		limit 1) sub1);

#step 4:
select title 
from film
where film_id in (
	select film_id 
	from film_actor
	where actor_id in (
		select actor_id
			from (select actor_id, count(film_id) as no_of_films
			from film_actor
			group by actor_id
			order by no_of_films desc
			limit 1) sub1));


-- 7 Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

select title from film
where film_id in(
	select film_id from inventory
	where inventory_id in (
		select inventory_id from rental
		where rental_id in(
			select rental_id from payment
			where customer_id = (
				select customer_id
				from payment
				group by customer_id
				order by sum(amount) DESC
				limit 1))));


-- 8 Customers who spent more than the average payments.

select customer_id, sum(amount) as total_amount from payment
group by customer_id
having total_amount > (
	select avg(sum_amount) from (
		select customer_id, sum(amount) as sum_amount from payment
		group by customer_id
		order by sum(amount) desc
		) as sub1)
order by total_amount;
