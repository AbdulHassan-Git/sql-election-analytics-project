---------------------------------------------------------
/* 1. Who won each election? */
---------------------------------------------------------
SELECT 
	e.electionid,
	e.title AS election_title,
	c.fullname AS winner,
	c.party AS winner_party,
	er.totalvotes AS votes_recorded
FROM election AS e
JOIN electionresult AS er
	ON er.electionid = e.electionid
JOIN candidate AS c 
	ON c.candidateid = er.candidateid
ORDER BY e.electionid

------------------------------------------------------------------------------
/* 2. Total votes per candidate (across all elections) */
------------------------------------------------------------------------------
SELECT
	c.candidateid,
	c.fullname AS candidate_name,
	c.party,
	COUNT(v.voteid) AS total_votes
FROM candidate AS c
LEFT JOIN vote AS v
 ON v.candidateid = c.candidateid
GROUP BY c.candidateid, c.fullname, c.party
ORDER BY total_votes DESC

-------------------------------------------------------------
/* 3. Votes per election (turnout) */
--------------------------------------------------------------
SELECT 
	e.electionid,
	e.title,
	COUNT(v.voteid) AS total_vote_cast,
	COUNT(DISTINCT v.voterid) AS unique_Voters
FROM election AS e
LEFT JOIN vote AS v 
	ON e.electionid = v.electionid
GROUP BY e.electionid, e.title
ORDER BY total_vote_cast DESC

-------------------------------------------------------------------------
/* 4. Party performance (which party got the most votes?) */
-------------------------------------------------------------------------
SELECT
    c.party,
    COUNT(v.voteid) AS total_votes
FROM candidate c
LEFT JOIN vote v 
    ON v.candidateid = c.candidateid
GROUP BY c.party
ORDER BY total_votes DESC;

------------------------------------------------------------------------------
/* 5. Voter demographics (gender breakdown) */
------------------------------------------------------------------------------
SELECT 
	gender,
	COUNT(*) AS number_of_voters
FROM voter
GROUP BY gender

--------------------------------------------------------------------------------
/* 6. Age distribution of voters */
--------------------------------------------------------------------------------
SELECT
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(*) AS voters_in_group
FROM voter
GROUP BY 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END;

-----------------------------------------------------------------------
/* 7. Voter engagement — who voted the most? */
------------------------------------------------------------------------
SELECT 
    v.voterid,
    vt.fullname,
    COUNT(v.voteid) AS votes_cast
FROM vote v
JOIN voter AS vt 
    ON vt.voterid = v.voterid
GROUP BY v.voterid, vt.fullname
ORDER BY votes_cast DESC;

------------------------------------------------------------------------
/* 8. Audit log analysis — most common actions */
-------------------------------------------------------------------------
SELECT 
    action,
    COUNT(*) AS occurrences
FROM auditlog
GROUP BY action
ORDER BY occurrences DESC;

-------------------------------------------------------------------------
/* 9. Which election had the highest turnout? */
----------------------------------------------------------------------------
SELECT TOP 1
    e.electionid,
    e.title,
    COUNT(v.voteid) AS total_votes_cast
FROM election e
LEFT JOIN vote AS v 
    ON v.electionid = e.electionid
GROUP BY e.electionid, e.title
ORDER BY total_votes_cast DESC;

---------------------------------------------------------------------------------
/* 10. Which candidate is the most popular overall? (Total votes across all elections) */
--------------------------------------------------------------------------------------
SELECT TOP 1
    c.candidateid,
    c.fullname AS candidate_name,
    c.party,
    COUNT(v.voteid) AS total_votes
FROM candidate AS c
LEFT JOIN vote AS v 
    ON v.candidateid = c.candidateid
GROUP BY c.candidateid, c.fullname, c.party
ORDER BY total_votes DESC;

-------------------------------------------------------------------------
/* 11. Voting pattern by NOTA (None Of The Above) */
--------------------------------------------------------------------------
SELECT
    nota,
    COUNT(*) AS occurrences
FROM vote
GROUP BY nota;

--------------------------------------------------------------------
/* 12. Which gender participated more in voting? */
-----------------------------------------------------------------------
SELECT
    vt.gender,
    COUNT(v.voteid) AS votes_cast
FROM voter vt
LEFT JOIN vote v ON v.voterid = vt.voterid
GROUP BY vt.gender;

-------------------------------------------------------------------------------------------
/* 13. Does age impact likelihood of voting?  Create age brackets → compare vote counts: */
--------------------------------------------------------------------------------------------
SELECT
    CASE 
        WHEN vt.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN vt.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN vt.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN vt.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(v.voteid) AS votes_cast
FROM voter vt
LEFT JOIN vote v ON v.voterid = vt.voterid
GROUP BY 
    CASE 
        WHEN vt.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN vt.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN vt.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN vt.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END
ORDER BY votes_cast DESC;

----------------------------------------------------------------------------------
/* 14. Winner margin for each election
How much the winner won by: */
---------------------------------------------------------------------------------

WITH VoteCounts AS (
    SELECT 
        e.electionid,
        c.candidateid,
        c.fullname,
        COUNT(v.voteid) AS votes
    FROM election e
    JOIN candidate c ON c.electionid = e.electionid
    LEFT JOIN vote v ON v.candidateid = c.candidateid
    GROUP BY e.electionid, c.candidateid, c.fullname
),
Ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY electionid ORDER BY votes DESC) AS rn
    FROM VoteCounts
)
SELECT
    w.electionid,
    w.fullname AS winner,
    w.votes AS winner_votes,
    r.fullname AS runner_up,
    r.votes AS runner_up_votes,
    (w.votes - r.votes) AS win_margin
FROM Ranked w
JOIN Ranked r
    ON w.electionid = r.electionid AND r.rn = 2  -- runner up
WHERE w.rn = 1;

--------------------------------------------------------------------------
/* 15. What % of voters participated in voting? 
This is turnout rate — extremely common KPI. */
---------------------------------------------------------------------------
SELECT
    (COUNT(DISTINCT v.voterid) * 100.0) / (SELECT COUNT(*) FROM voter) 
        AS percentage_of_voters_who_voted
FROM vote v;

-------------------------------------------------------------------------
/* 16. Votes per party */
--------------------------------------------------------------------
SELECT
    c.party,
    COUNT(v.voteid) AS total_votes
FROM candidate c
LEFT JOIN vote v ON v.candidateid = c.candidateid
GROUP BY c.party
ORDER BY total_votes DESC;