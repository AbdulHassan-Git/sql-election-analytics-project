USE ElectionDB;
GO

------------------------------------------------
-- 1. Admins (5 rows)
------------------------------------------------
INSERT INTO [admin] (adminid, username, [password], email, createdat)
SELECT TOP 5
    ROW_NUMBER() OVER (ORDER BY NEWID()) AS adminid,
    CONCAT('admin', ROW_NUMBER() OVER (ORDER BY NEWID())),
    'password123',
    CONCAT('admin', ROW_NUMBER() OVER (ORDER BY NEWID()), '@mail.com'),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 500, GETDATE())
FROM sys.objects;


------------------------------------------------
-- 2. Voters (100 rows)
------------------------------------------------
INSERT INTO voter (voterid, fullname, email, dob, nationalid, registereddate, [password], [address], age, gender, phone)
SELECT TOP 100
    ROW_NUMBER() OVER (ORDER BY NEWID()) AS voterid,
    CONCAT('Voter ', ROW_NUMBER() OVER (ORDER BY NEWID())),
    CONCAT('voter', ROW_NUMBER() OVER (ORDER BY NEWID()), '@mail.com'),
    DATEADD(YEAR, -(18 + ABS(CHECKSUM(NEWID())) % 40), GETDATE()),
    CONCAT('NID', ABS(CHECKSUM(NEWID())) % 999999),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 200, GETDATE()),
    'pass123',
    CONCAT('Street ', ABS(CHECKSUM(NEWID())) % 200),
    18 + ABS(CHECKSUM(NEWID())) % 40,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'Male' ELSE 'Female' END,
    CONCAT('07', ABS(CHECKSUM(NEWID())) % 99999999)
FROM sys.objects;


------------------------------------------------
-- 3. Elections (3 rows)
--    adminid picked from existing admins
------------------------------------------------
INSERT INTO election (electionid, title, [description], startdate, enddate, [status], adminid)
SELECT
    v.id,
    CONCAT('Election ', v.id),
    'Sample election description.',
    DATEADD(DAY, -20 * v.id, GETDATE()),
    DATEADD(DAY, -20 * v.id + 10, GETDATE()),
    'Completed',
    (SELECT TOP 1 a.adminid FROM [admin] a ORDER BY NEWID())
FROM (VALUES (1),(2),(3)) v(id);


------------------------------------------------
-- 4. Election results (1 per election)
--    satisfies UNIQUE INDEX on electionid
------------------------------------------------
INSERT INTO electionresult (resultid, totalvotes, electionid, candidateid)
SELECT
    ROW_NUMBER() OVER (ORDER BY e.electionid) AS resultid,  -- 1,2,3
    ABS(CHECKSUM(NEWID())) % 300          AS totalvotes,
    e.electionid,
    0                                     AS candidateid    -- temporary, updated later
FROM election e;


------------------------------------------------
-- 5. Candidates (multiple per election)
--    each candidate.resultid points to its election's resultid
------------------------------------------------
;WITH nums AS (
    SELECT TOP 10 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO candidate (candidateid, fullname, party, biography, photourl, electionid, resultid)
SELECT
    ROW_NUMBER() OVER (ORDER BY e.electionid, n.n)           AS candidateid,
    CONCAT('Candidate ', ROW_NUMBER() OVER (ORDER BY e.electionid, n.n)) AS fullname,
    CONCAT('Party ', ABS(CHECKSUM(NEWID())) % 5)             AS party,
    'Biography...'                                           AS biography,
    CONCAT('photo', ROW_NUMBER() OVER (ORDER BY e.electionid, n.n), '.jpg') AS photourl,
    e.electionid,
    er.resultid                                              AS resultid   -- ✅ valid FK
FROM election e
JOIN electionresult er ON er.electionid = e.electionid
JOIN nums n ON 1 = 1;     -- 10 candidates per election (3*10 = 30)


------------------------------------------------
-- 6. Set winner in electionresult.candidateid
--    choose the smallest candidateid per election as the "winner"
------------------------------------------------
;WITH winners AS (
    SELECT 
        e.electionid,
        MIN(c.candidateid) AS winner_candidateid
    FROM election e
    JOIN candidate c ON c.electionid = e.electionid
    GROUP BY e.electionid
)
UPDATE er
SET er.candidateid = w.winner_candidateid
FROM electionresult er
JOIN winners w 
    ON w.electionid = er.electionid;

------------------------------------------------
-- 7. Audit logs (100 rows)
------------------------------------------------
INSERT INTO auditlog (logid, [action], actorid, actortype, [description], [timestamp], voterid, adminid)
SELECT TOP 100
    ROW_NUMBER() OVER (ORDER BY NEWID()) AS logid,
    'VOTE_CAST'                          AS [action],
    v.voterid                            AS actorid,
    'VOTER'                              AS actortype,
    'Voter performed an action.'         AS [description],
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 20, GETDATE()) AS [timestamp],
    v.voterid,
    (SELECT TOP 1 a.adminid FROM [admin] a ORDER BY NEWID())
FROM voter v
ORDER BY NEWID();

------------------------------------------------
-- 8. Votes (300 rows)
--    votes are consistent: candidate belongs to the same election
------------------------------------------------
INSERT INTO vote (voteid, votetime, nota, voterid, electionid, candidateid)
SELECT TOP 300
    ROW_NUMBER() OVER (ORDER BY NEWID()) AS voteid,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 30, GETDATE()) AS votetime,
    ABS(CHECKSUM(NEWID())) % 2                          AS nota,
    v.voterid,                                          -- ✅ always valid voter
    e.electionid,
    c.candidateid
FROM election e
JOIN candidate c ON c.electionid = e.electionid
JOIN voter v ON 1 = 1          -- cross join with voters
ORDER BY NEWID();
