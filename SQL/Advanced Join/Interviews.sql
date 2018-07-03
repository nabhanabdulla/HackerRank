SELECT c1.contest_id, c1.hacker_id, c1.name, sum(total_submissions) as s, sum(total_accepted_submissions) as sa, sum(total_views) as v, sum(total_unique_views) as vu
FROM Contests as c1
INNER JOIN Colleges as c2 USING (contest_id)
INNER JOIN Challenges as c3 USING (college_id)
LEFT JOIN (SELECT challenge_id, sum(total_views) as total_views, sum(total_unique_views) as total_unique_views FROM View_Stats GROUP BY challenge_id) as v_s USING (challenge_id) 
LEFT JOIN (SELECT challenge_id, sum(total_submissions) as total_submissions, sum(total_accepted_submissions) as total_accepted_submissions FROM Submission_Stats  GROUP BY challenge_id) as s_s USING (challenge_id)
GROUP BY c1.contest_id, hacker_id, name
HAVING (v + vu + s + sa) <> 0
ORDER BY c1.contest_id;
