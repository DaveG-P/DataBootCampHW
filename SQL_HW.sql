USE sakila;

SELECT * FROM actor;

-- 1A Display the first and last names of all actors from the table `actor`.
SELECT first_name,last_name from actor;

-- 1B Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UCASE(first_name), " ", UCASE(last_name)) 
AS "Actor Name"
FROM actor;

-- 2A  You need to find the ID number, first name, and last name 
-- of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name 
FROM actor;
WHERE first_name = "Joe";

 -- 2B Find all actors whose last name contain the letters `GEN`
SELECT actot_id, first_name, last_name
FROM actor;
WHERE last_name LIKE "%gen%";

-- 2C) Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order
SELECT actor_id, firs_name, last_name
FROM actor;
WHERE last_name LIKE "%Li%";
ORDER BY last_name AND first_name  ASC;

-- 2D Using `IN`, display the `country_id` and `country` 
-- columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3A create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;
ALTER TABLE actor MODIFY middle_name BLOB;

-- 3B Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP middle_name;

-- 4A, List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Number of Actors' 
FROM actor
GROUP BY last_name;

-- 4B List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Number of Actors' 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4C The actor `HARPO WILLIAMS` was accidentally entered in the
--     `actor` table as `GROUCHO WILLIAMS`. Write a query to fix 
--      the record.
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4D Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
--      It turns out that `GROUCHO` was the correct name after all! 
--      In a single query, if the first name of the actor is currently
--      `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name= REPLACE()first_name, "GROUCHO", "HARPO")
WHERE last_name= "Williams";

-- 5A You cannot locate the schema of the `address` table. 
--     Which query would you use to re-create it?
SHOW COLUMNS 
FROM sakila.address;
SHOW CREATE TABLE sakila.address;

-- 6A  Use `JOIN` to display the first and last names, 
--    as well as the address, of each staff member. Use the 
--    tables `staff` and `address`
SELECT first_name, last_name, address 
FROM staff s
INNER JOIN address a ON s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each 
--   staff member in August of 2005. Use tables `staff` and `payment`
SELECT s.staff_id, first_name, last_name, SUM(amount) as "Total Amount Rung Up"
FROM staff s
INNER JOIN payment p 
ON s.staff_id = p.staff_id
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are 
-- listed for that film. Use tables `film_actor` and `film`. 
-- Use inner join.
SELECT f.title, COUNT(fa.actor_id) as "Number of Actors"
FROM film f
LEFT JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6D  How many copies of the film `Hunchback Impossible` 
--   exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id) as "Number in Inventory"
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
GROUP BY f.film_id
HAVING title = "Hunchback Impossible";

-- 6E Using the tables `payment` and `customer` and the 
--   `JOIN` command, list the total paid by each customer. 
--    List the customers alphabetically by last name
SELECT c.last_name, c.first_name, SUM(p.amount) as "Total Paid"
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY last_name, first_name;

-- 7A Use subqueries to display the titles of movies starting 
--  with the letters `K` and `Q` whose language is English.
SELECT title 
FROM film
WHERE language_id IN
	(SELECT language_id FROM language
	WHERE name = "English")
AND (title LIKE "K%") OR (title LIKE "Q%");

-- 7B Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id 
    FROM film_actor 
    WHERE film_id IN
		SELECT film_id FROM film
        WHERE title * "ALone Trip")
);

-- 7C Use joins to retrieve the names and email addresses of all Canadian customers.
SELECT c.first_name, c.last_name, c.email, co.country 
FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci
ON ci.city_id = a.city_id
LEFT JOIN country co
ON co.country_id = ci.country_id
WHERE country = "Canada";

-- 7D Identify all movies categorized as family films.
SELECT title, description FROM film 
WHERE film_id IN
(SELECT film_id FROM film_category
WHERE category_id IN
(SELECT category_id FROM category
WHERE name = "Family"
));

-- 7E Display the most frequently rented movies in descending order.
SELECT f.title , COUNT(r.rental_id) AS "Number of Rentals" 
FROM film f
RIGHT JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r 
ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;

-- 7F Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, SUM(amount) AS 'Revenue'
FROM payment p
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON (i.inventory_id = r.inventory_id)
JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id; 

-- 7G Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, co.country 
FROM store s
JOIN address a
ON s.address_id = a.address_id
JOIN city ci
ON a.city_id = ci.city_id
JOIN country co
ON ci.country_id = co.country_id;

-- 7H List the top five genres in gross revenue in descending order.
SELECT c.name, sum(p.amount) as "Revenue per Category" 
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY name;

-- 8A 
CREATE VIEW top_5_by_genre AS
SELECT c.name, sum(p.amount) as "Revenue per Category" 
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8B How would you display the view that you created in 8a?
SELECT * FROM top_5_by_genre;

-- 8C You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_by_genre;