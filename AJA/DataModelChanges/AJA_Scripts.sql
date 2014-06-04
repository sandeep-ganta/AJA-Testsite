/*copy data from one db table to another db table */

INSERT INTO aja.dbo.Countries
SELECT * FROM User_01.dbo.Countries

Insert into aja.dbo.Specialties
select * from User_01.dbo.Specialties

insert into aja.dbo.TypePractice
select * from User_01.dbo.TypePractice


ALTER TABLE dbo.AJA_tbl_Users  ADD CPswd nvarchar(150),Fname nvarchar(50),Lname nvarchar(50),Pincode int
GO

alter table dbo.Countries alter column CountryID nvarchar(50) 
Go
