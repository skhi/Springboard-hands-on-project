/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to
setup your local SQLite connection in PART 2 of the case study.

The questions in the case study are exactly the same as with Tier 2.

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface.
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
select * from Facilities
where membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
select count(*) from Facilities
where membercost = 0
/* 4 clubs do not charge member fee */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid, name, membercost, monthlymaintenance
from Facilities
where membercost > 0 AND membercost < monthlymaintenance*0.2

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
select * from Facilities
where  facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance,
case when monthlymaintenance < 100 then 'cheap'
         else 'expensive' END AS Type
from Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
select surname, firstname, joindate
from Members
where joindate = (select MAX(joindate) from Members)

-- or

select  surname, firstname, joindate
from Members
order by joindate desc


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT(Members.firstname,  ' ', Members.surname,
                       ' at ', Facilities.name ) AS active_member

    FROM Members
    JOIN Bookings
        ON Members.memid = Bookings.memid
    JOIN Facilities
        ON Facilities.facid = Bookings.facid
where Facilities.name like '%Tennis Court%'
ORDER BY Members.surname




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select Facilities.name, concat(Members.firstname, ' ',  Members.surname) AS MemName,
case when (Bookings.memid = 0 ) then Bookings.slots*Facilities.guestcost
else  Bookings.slots*Facilities.membercost
END as Cost
  FROM Members
   INNER  JOIN Bookings
        ON Members.memid = Bookings.memid
   INNER JOIN Facilities
        ON Facilities.facid = Bookings.facid
where Bookings.starttime like '2012-09-14%' and (Bookings.memid = 0 )  and (Bookings.slots*Facilities.guestcost > 30)
or Bookings.starttime like '2012-09-14%'  and (Bookings.memid <> 0 )  and  (Bookings.slots*Facilities.membercost>30)
order by Cost Desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select *
from
(select Facilities.name, concat(Members.firstname, ' ',  Members.surname) AS MemName,
case when (Bookings.memid = 0 ) then Bookings.slots*Facilities.guestcost
     else  Bookings.slots*Facilities.membercost
END as Cost
  FROM Members
  INNER JOIN Bookings
      ON Members.memid = Bookings.memid and Bookings.starttime like '2012-09-14%'
  INNER JOIN Facilities
      ON Facilities.facid = Bookings.facid)sub
where sub.Cost > 30
order by sub.Cost Desc

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine.

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it.

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to.

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select*
From(
select sub.FacName, sum(sub.Rev) as total_rev
from(
select Facilities.name AS FacName,
case when (Bookings.memid = 0 ) then Bookings.slots*Facilities.guestcost
else  Bookings.slots*Facilities.membercost
END as Rev
  FROM Facilities
 INNER JOIN Bookings
   ON Facilities.facid = Bookings.facid
INNER JOIN Members
ON Bookings.memid = Members.memid)sub
GROUP BY sub.FacName)sub2
where sub2.total_rev < 1000

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
select  r.surname as mem_surname, r.firstname as mem_firstname, m.surname as rec_surname, m.firstname as rec_fistname
from Members m
INNER JOIN Members r
ON m.memid = r.recommendedby
Where m.memid != 0
ORDER BY mem_surname, mem_firstname


/* Q12: Find the facilities with their usage by member, but not guests */
select distinct Facilities.name as FacName, concat(Members.surname, ' ',  Members.firstname) AS MemName
FROM Members
INNER  JOIN Bookings
ON Members.memid = Bookings.memid and Members.memid != 0
INNER JOIN Facilities
ON Facilities.facid = Bookings.facid
ORDER BY MemName


/* Q13: Find the facilities usage by month, but not guests */
