/* Joining the Contests, Colleges and the Challenges table gives you a table containing data of contest that is used to screen
   candidates in a college and different challenges organised in the college.
   Things to remember:
   1) A specific contest can be used to screen candidates in more than one colleges.
   2) A specific college can only screen candidates using a single contest.
   This implies that every challenge organised in a college will be of a single contest, that is the contest used to screen
   students in that colleges. 
*/
-- Select the required fields(columns) as mentioned in the question
-- Confused with some of the fields starting with their table names and others not. Fields like contest_id occur in more that one table
-- we are joining. Inorder to avoid ambiguity they are called as c1.contest_id etc.(c2.contest_id would also work).
-- Fields like hacker_id, name, total_submissions are present only in a single table among the tables we are joining and need not be 
-- following their table name, but it's good practice to name uniformly.
SELECT c1.contest_id, c1.hacker_id, c1.name, sum(total_submissions) as t_s, sum(total_accepted_submissions) as t_a_s, 
       sum(total_views) as t_v, sum(total_unique_views) as t_u_v
FROM Contests as c1
-- Using USING(contest_id) instead of ON c1.contest_id = c2.contest_id is efficient
INNER JOIN Colleges as c2 USING (contest_id)
INNER JOIN Challenges as c3 USING (college_id)
/* On analysing the View_Stats and the Submission_Stats table you can find that there can be more than one challenges with the 
   same challenge_id. So, first create a new table by grouping over challenge_id and using sum to aggregate fields in the View_Stats 
   and Submission_Stats table.
   Here, we use LEFT JOIN instead of INNER JOIN because there may be challenges in Challenges table that aren't in the View_Stats and the 
   Submission_Stats tables and challenges in View_Stats that aren't in Submission_Stats which will be omitted if we use INNER JOIN.
*/
LEFT JOIN (SELECT challenge_id, sum(total_views) as total_views, sum(total_unique_views) as total_unique_views 
           FROM View_Stats GROUP BY challenge_id) as v_s USING (challenge_id) 
LEFT JOIN (SELECT challenge_id, sum(total_submissions) as total_submissions, sum(total_accepted_submissions) as total_accepted_submissions
           FROM Submission_Stats  GROUP BY challenge_id) as s_s USING (challenge_id)
/* For all those who have tried to run the program using GROUP BY c1.contest_id would have been hit with an error message like this:
         ERROR 1055 (42000) at line 1: Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 
         'run_zoyjnfsjncg.c1.hacker_id' which is not functionally dependent on columns in GROUP BY clause; this is incompatible 
         with sql_mode=only_full_group_by
   This means that you can add only those fields in the SELECT query which are either the field you use to group the table or aggregates
   of any other columns.
   And if you stackoverflow the error you can find that this can be solved by adding this SQL query:
         SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
   Now if you try to run the program with this command, NOT AGAIN!
          ERROR 1227 (42000) at line 1: Access denied; you need (at least one of) the SUPER privilege(s) for this operation
   Which most probably you won't be having so inorder to select the hacker_id and the name fields use GROUP BY query as below.
*/
GROUP BY c1.contest_id, c1.hacker_id, c1.name
-- There's a condition in the question not to include those records(rows) that have all the four sums as zero
-- You can't use WHERE clause here because these fields are derived fields and are computed only after the WHERE clause is evaluated.
-- Incase you are wondering what '<>' is, that's 'not equal to' in SQL
HAVING (t_v + t_u_v + t_s + t_a_s) <> 0
ORDER BY c1.contest_id;
