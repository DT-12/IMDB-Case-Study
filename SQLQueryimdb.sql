/* Let's look at the data 
In the movie table the year column has roman numbers, we have to remove those.
In order to do this we will be creating a user defined persistant function which will return numeric values only.
*/


  Create function UDF_ExtractNumbersnew
(  
  @input varchar(255)  
)  
Returns varchar(255)  
with schemabinding -- making this function deterministic
As  
Begin  
  Declare @alphabetIndex int = Patindex('%[^0-9]%', @input)  
  Begin  
    While @alphabetIndex > 0  
    Begin  
      Set @input = Stuff(@input, @alphabetIndex, 1, '' )  
      Set @alphabetIndex = Patindex('%[^0-9]%', @input )  
    End  
  End  
  Return @input
End

-- checking to see if this is working?
Select dbo.UDF_ExtractNumbersnew(movie.year) as year_new  from movie


-- adding the column by applying the function to the column
alter table movie
add year_new as dbo.UDF_ExtractNumbersnew(year) persisted 
go

-----
select * from movie
--Q1)

/*List all the directors who directed a 
'Comedy' movie in a leap year. (You need to check that the genre is 'Comedy’ 
and year is a leap year) Your query should return director name, the movie name, and the year
*/

select * from dbo.m_director
select * from dbo.person
select * from dbo.m_cast
select * from dbo.m_genre
select * from dbo.genre where GID = 35
select * from movie 
select * from person

--answer
select m_genre.gid, m_genre.MID, genre.Name as genre, movie.title,
movie.year_new,person.Name as Director from
dbo.m_genre 
join dbo.genre 
on m_genre.GID = genre.GID 
join dbo.movie 
on m_genre.MID = movie.MID
join dbo.m_director
on m_director.MID = movie.MID
join dbo.person
on m_director.PID = person.PID
where genre.Name like '%Comedy%'
and year_new % 4 = 0 AND year_new % 100 <> 0 OR year_new % 400 = 0

------------------------------------------------------------------------------------------------------------
--List the names of all the actors who played in the movie 'Anand' (1971)


--removing leading and trailing spaces from pid
update person set pid = LTRIM(RTRIM(pid))
update m_cast set PID = LTRIM(RTRIM(pid))


select movie.title, person.Name
from movie
join m_cast
on movie.MID = m_cast.MID
join person
on m_cast.PID = person.PID
where movie.title ='Anand'

-----------------------------------------------------------------------------------------------------------

--List all the actors who acted in a film before
--1970 and in a film after 1990. (That is: < 1970 and > 1990.)


select movie.year_new, person.Name
from movie
join m_cast
on movie.MID = m_cast.MID
join person
on m_cast.PID = person.PID
where movie.year_new NOT between 1970 and 1990

--------------------------------------------------------------------------------------------------------

--List all directors who directed 10 movies or more,
--in descending order of the number of movies they directed.
--Return the directors' names and the number of movies each of them directed.


select person.Name, COUNT(title) as Count_of_movies from movie
join m_director
on m_director.MID = movie.MID
join person
on m_director.PID = person.PID

group by person.Name
having COUNT(title) > 10

order by Count_of_movies desc
---------------------------------------------------------------------------------------------------------

--For each year, count the number of movies in that year that had only female actors.

select * from movie
select * from person

select year_new, COUNT(title) as [count of movies with only female actors ]
from movie
join m_cast
on movie.MID = m_cast.MID
join person
on m_cast.PID = person.PID
where person.Gender = 'Female'
group by movie.year_new
order by COUNT(Title) desc

--Now include a small change:
--report for each year the percentage of movies in that year with only female actors, 
--and the total number of movies made that year. 
--For example, one answer will be: 1990 31.81 13522 
--meaning that in 1990 there were 13,522 movies, and 31.81% had only female actors.
--You do not need to round your answer.

select a.year_new, [count of movies],
[count of movies with only female actors ],

CAST([count of movies with only female actors ] as decimal(12,0))/ [count of movies] * 100 as [percent of movies with female actors only]
from
(select year_new, COUNT(title) as [count of movies]
from movie
join m_cast
on movie.MID = m_cast.MID
join person
on m_cast.PID = person.PID
group by movie.year_new
--order by COUNT(Title) desc
) a
join 
(
select year_new, COUNT(title) as [count of movies with only female actors ]
from movie
join m_cast
on movie.MID = m_cast.MID
join person
on m_cast.PID = person.PID
where person.Gender = 'Female'
group by movie.year_new
--order by COUNT(Title) desc
) b
on a.year_new = b.year_new
order by a.year_new

------------------------------------------------------------------------------------------------------------
/*Find the film(s) with the largest cast.
Return the movie title and the size of the cast.
By "cast size" we mean the number of distinct actors that 
played in that movie: if an actor played multiple roles, 
or if it simply occurs multiple times in casts,
we still count her/him only once.*/


select * from movie
select * from m_cast
select * from person
/*
select movie.title, COUNT(distinct m_cast.pid) as [count of actors] from dbo.m_cast
join person 
on m_cast.PID = person.PID
join movie
on m_cast.MID = movie.MID

group by movie.title
order by [count of actors] desc
*/


select movie.title, COUNT(distinct person.Name) as [count of actors] from dbo.m_cast
join person 
on m_cast.PID = person.PID
join movie
on m_cast.MID = movie.MID

group by movie.title
order by [count of actors] desc

/*
A decade is a sequence of 10 consecutive years.
For example, say in your database
you have movie information starting from 1965. 
Then the first decade is 1965, 1966, ..., 1974; 
the second one is 1967, 1968, ..., 1976 and so on.
Find the decade D with the largest number of films and the total number of films in D.
*/

/*
--1931 - 2018
select * from movie
--group by year_new
order by year_new


select distinct (select floor(year(movie.year_new) / 10)) * 10 as decade , count(*)
--, COUNT(title)
from movie


select d.year_new as start, d.year_new + 9 as end,
count(*) as  [no of films]
from dbo.movie d

SELECT d.year_new Start, d.year_new+9 End,
count(*) no_of_films FROM
 (SELECT DISTINCT year_new from Movie) d JOIN Movie m ON m.year_new >= Start and m.year_new<= End 
                            GROUP BY End ORDER BY no_of_films desc LIMIT 1




select distinct year_new, year_new + 9 from dbo.movie
order by year_new

select COUNT(*) from dbo.movie
where year_new
*/

-------------------------------------------------------------------------------------------
--9. Find all the actors that made more movies with Yash Chopra than any other director.

select * from person
select * from m_cast
select * from movie
select * from m_director

