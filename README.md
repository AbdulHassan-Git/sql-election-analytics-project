
## 📘 Election Management System — SQL Server Project
A complete end-to-end Election Management System built using Microsoft SQL Server, featuring:  
- Full relational database schema  
- Referential integrity (PK/FK constraints)  
- Randomised data seeding  
- Comprehensive SQL analysis  
- Data-driven insights on voter behaviour, party performance, turnout, and more  
This project demonstrates real-world database design, data engineering, and analytical SQL skills.
________________________________________
## 🗂 Table of Contents
1.	Project Overview
2.	Database Design
3.	Database Creation
4.	ERD Summary
5.	Setup Instructions
6.	Data Seeding
7.	SQL Analysis
8.	Insights Summary
________________________________________
## 📌 Project Overview
This Election Management System simulates election processes, including: 
-   Managing admins   
- 	Registering voters   
- 	Setting up elections   
- 	Adding candidates   
- 	Casting votes  
- 	Recording results  
- 	Tracking actions through audit logs  
## It includes extensive analysis covering:  
-	Election winners  
-	Party strengths  
-	Turnout rates  
-	Age & gender behaviour  
-	NOTA vote trends  
-	Winner margins  
-	Voter engagement patterns  
________________________________________
## 🧱 Database Design
The database consists of seven core tables:  
# Table	Description  
- admin	Stores admin details  
- voter	Stores voter demographics  
- election	Election definitions  
- candidate	Candidates participating in an election  
- vote	Individual votes (candidate or NOTA)  
- electionresult	Final winner data  
- auditlog	Tracks actions (e.g., vote casting)  
________________________________________
## 🏗️ Database Creation
The database was created manually using SQL Server.  
Below is an example of how the structure was built.
________________________________________
## 📌 Step 1 — Create the Database
CREATE DATABASE ElectionDB;  
GO  
USE ElectionDB;  
GO
________________________________________
## 📌 Step 2 — Create Core Tables
Example: Admin Table  
CREATE TABLE admin (  
    adminid INT IDENTITY(1,1) PRIMARY KEY,  
    username VARCHAR(50) NOT NULL,  
    password VARCHAR(50) NOT NULL,  
    email VARCHAR(50) NOT NULL,  
    createdat DATE NOT NULL  
);  
Example: Voter Table    
CREATE TABLE voter (  
    voterid INT IDENTITY(1,1) PRIMARY KEY,  
    fullname VARCHAR(50) NOT NULL,  
    email VARCHAR(30) NOT NULL,  
    dob DATE NOT NULL,  
    nationalid VARCHAR(50) NOT NULL,  
    registereddate DATE NOT NULL,  
    password VARCHAR(30) NOT NULL,  
    address VARCHAR(50) NOT NULL,  
    age INT NOT NULL,  
    gender VARCHAR(30) NOT NULL,  
    phone VARCHAR(50) NOT NULL  
);
________________________________________
## 📌 Step 3 — Add Foreign Keys
Example:  
ALTER TABLE election  
ADD CONSTRAINT election_admin_fk  
FOREIGN KEY (adminid) REFERENCES admin(adminid);  
ALTER TABLE vote  
ADD CONSTRAINT vote_candidate_fk  
FOREIGN KEY (candidateid) REFERENCES candidate(candidateid);  
These relationships ensure strict data integrity.
________________________________________
## 📌 Step 4 — Add Indexes (Optional)  
CREATE INDEX idx_vote_electionid ON vote(electionid);  
CREATE INDEX idx_candidate_electionid ON candidate(electionid);  
________________________________________
## 📌 Step 5 — Validate the Structure  
SELECT * FROM sys.tables;  
SELECT * FROM sys.foreign_keys;  
This confirms all tables and relationships exist.  
________________________________________
## 🔗 ERD Summary
Relationships include:
-	Admin → Election (1-many)  
-	Election → Candidate (1-many)  
-	Election → Vote (1-many)  
-	Candidate → Vote (1-many)  
-	Voter → Vote (1-many)  
-	Election → ElectionResult (1-1)  
-	Voter/Admin → AuditLog (1-many)

  <img width="1332" height="778" alt="ERD_Diagram" src="https://github.com/user-attachments/assets/d10c529e-04e7-4e60-b050-b22c57e0d918" />
 
________________________________________
## ⚙️ Setup Instructions
1. Clone the Repository    
git clone (https://github.com/AbdulHassan-Git/sql-election-analytics-project)   
2. Open SQL Server Management Studio (SSMS)  
3. Create the database (shown above)  
4. Run schema.sql  
5. Run seed.sql  
________________________________________
## 🌱 Data Seeding
this database includes:
-	5 Admins  
-	100 Voters  
-	3 Elections
-	30 Candidates
-	300 Votes
-	100 Audit logs  
Pre-generated using SQL with ROW_NUMBER(), NEWID(), CHECKSUM(), etc.
________________________________________
## 📊 SQL Analysis  

1. Election Winners  
Election	Winner	Party	Votes  
General elections	Candidate 1	Party 3	60  
Local government	Candidate 11	Party 2	169  
Parliamentary elections	Candidate 21	Party 3	96  
🔍 Insight:  
Party 3 dominates with 2/3 wins.
________________________________________
2. Votes Per Candidate  
Candidate 3 leads with 18 votes.  
🔍 Insight:  
Strong support for Party 3 candidates across elections.
________________________________________
3. Votes Per Election 
Election	Total Votes	Unique Voters  
General elections	107	66  
Local government	97	66  
Parliamentary elections	96	64  
🔍 Insight:  
Turnout extremely consistent.
________________________________________
4. Votes Per Party  
Party	Votes  
Party 3	123  
Party 2	59  
Party 1	51  
Party 0	42  
Party 4	25  
🔍 Insight:
Party 3 is overwhelmingly dominant.
________________________________________
5. Gender Breakdown  
Gender	Count  
Female	56  
Male	44  
________________________________________
6. Age Groups  
Age Group	Voters  
26–35	36  
36–45	23  
46–55	20  
18–25	12  
56+	9  
________________________________________
7. Voter Engagement  
Voter 9 cast 8 votes — the highest.
________________________________________
8. Audit Log Activity  
Action	Count  
VOTE_CAST	100  
________________________________________
9. Highest Turnout Election  
General elections — 107 votes
________________________________________
10. Most Popular Candidate  
Candidate 3 — 18 votes  
________________________________________
11. NOTA Usage  
NOTA	Count  
0	160  
1	140  
________________________________________
12. Gender Voting Participation  
Gender	Votes Cast  
Female	168  
Male	132  
________________________________________
13. Age vs Voting Likelihood  
Age Group	Votes Cast  
26–35	103  
36–45	70  
46–55	69  
18–25	32  
56+	26  
________________________________________
14. Winner Margins  
Election	Winner	Runner-Up	Margin  
General elections	Candidate 3	Candidate 7	5  
Local government	Candidate 12	Candidate 13	0 (tie)  
Parliamentary elections	Candidate 22	Candidate 28	1  
________________________________________
15. Turnout Percentage  
94% turnout
________________________________________
## 🧠 Insights Summary  
-	Party 3 dominates votes and wins.
-	Ages 26–55 are the core voting demographic.
-	Turnout is extremely high (94%).
-	Gender participation perfectly matches gender distribution.
-	NOTA usage is high (46%), indicating potential lack of strong candidate trust.
-	Elections are competitive, with one producing a tie and another decided by 1 vote.
________________________________________
## 👤 Author  
Abdul Valiyapurakkal Hassan  
📧 Abdulkhayyoom896@gmail.com | 💼 www.linkedin.com/in/abdul-khayyoom-v-h-a65865125 | 🌐 https://github.com/AbdulHassan-Git
