use [musical_store]
1.Who is the senior most employee based on job title ?

select top 3 * from [dbo].[employee]
order by levels desc

2.Which co .  k   
untries have the most invoices ?

SELECT billing_country, COUNT(*) AS count
FROM [dbo].[invoice]
GROUP BY billing_country
order by count desc

3.What are the top 3 values of invoices ?

select top 3 total from [dbo].[invoice]
order by total desc
4.Which city has the best customer?Return both city name & Sum of all invoices?

SELECT top 1 SUM(total) AS total_invoice, billing_city
FROM [dbo].[invoice]
GROUP BY billing_city
order by total_invoice desc

5. Who is the best customer ?Write a query that the person who has spent the most money?

SELECT top 1 customer.first_name, customer.last_name, Sum(invoice.total) as total
FROM customer
INNER JOIN invoice ON customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by total desc

6. Return email,first name,lastname& genre of all rock music listener.Alphabetically start with A

select distinct customer.first_name,customer.last_name,customer.email from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id

where track_id in(
select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name='Rock')
order by email

7.Lets invite artist who have written most rock music ?Artist name and total track count of top 10 rock bands
use musical_store
SELECT top 10 artist.artist_id, artist.name,count(artist.artist_id) as no_of_songs
FROM track
join album ON album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id,artist.name
order by no_of_songs desc;

8.Return all the track names that have a song length longer than the avg strong length .Return name and milliseconds  for each track.
Order by desc song with the longest song listed 1st.

select track.name,track.milliseconds from track
where track.milliseconds> 
	(select AVG(track.milliseconds) as average_track_length from track)
order by track.milliseconds desc
 
 9.Find how much amount spent by each customer on artist?return customer name  artist name and total spent.
 use [musical_store]
 with best_selling_artist as (
 select top 1
		artist.artist_id as artist_id,
		artist.name as artist_name,
		SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales 
 from 
	invoice_line
 join 
	track on track.track_id=invoice_line.track_id
 join 
	album on album.album_id=track.album_id
 join 
	artist on artist.artist_id=album.artist_id
group by 
	artist.artist_id,artist.name
order by 
	total_sales desc
)
select customer.customer_id,customer.first_name,customer.last_name,best_selling_artist.artist_name,
SUM(invoice_line.quantity*invoice_line.unit_price) as amount_spent
from invoice
join customer on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join best_selling_artist on best_selling_artist.artist_id=album.artist_id
group by customer.customer_id,customer.first_name,customer.last_name,best_selling_artist.artist_name
order by amount_spent desc;

10.Find out the most popular music genre for each country means have highest purchase.Returns each country along with the 
top genre.For countries where the maximum no of purchase is shared return all genres.

WITH popular_genre AS (
    SELECT 
        COUNT(invoice_line.quantity) AS purchases,
        customer.country,
        genre.name,
        genre.genre_id,
        ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Rowno
    FROM 
        invoice_line
    JOIN 
        invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        genre ON genre.genre_id = track.genre_id
    GROUP BY 
        customer.country, genre.name, genre.genre_id
    )
SELECT * FROM popular_genre WHERE Rowno = 1

11.Write a query that determines the customer that has spent the most on music for each country .Write a query that returns the country
along with the top customer and how much they spent .For countries where the top amount spent is shared provide all customers who spent this amount.


WITH customer_with_country AS (
    SELECT 
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rowno
    FROM 
        invoice 
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    GROUP BY 
        customer.customer_id, customer.first_name, customer.last_name, billing_country
)
SELECT 
    * 
FROM 
    customer_with_country 
WHERE 
    rowno = 1;

