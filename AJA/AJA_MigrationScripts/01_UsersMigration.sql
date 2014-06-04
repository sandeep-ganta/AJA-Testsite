  -- AJA_tbl_Users
  SET IDENTITY_INSERT [dbo].AJA_tbl_Users ON
  INSERT INTO 
      AJA_tbl_Users([UserID]
      ,[Fname]
      ,[Lname]
      ,[UserTitle]
      ,[specialtyID]
      ,[CountryID]
      ,[Pincode]
      ,[EmailID]
      ,[UserName]
      ,[Password]
      ,[userType]
      ,[graduationYear]
      ,[yrsPractice]      
      ,[profession]
      ,[IseditorEmaiSend]      
      ,[IsSavedAqemaisend]
      ,[deleted_ind]
      ,[surveyValidated]
      ) 
 SELECT [userID]
      ,[firstName]
      ,[lastName]
      ,[title]
      ,[specialtyid]
      ,[countryID]
      ,[postalCode]
      ,[email]
      ,[userName]
      ,[password]
      ,[userType]
      ,[graduationYear]
      ,[yrsPractice]      
      ,[profession]
      ,[sendEmail]      
      ,[sasemail]
      ,[deleted_ind]
      ,[surveyValidated]     
      FROM User_01.dbo.Users
      SET IDENTITY_INSERT [dbo].AJA_tbl_Users OFF
      
     
     update AJA_tbl_Users set Activated=1
     
      
 --AJA_tbl_Roles
SET IDENTITY_INSERT [dbo].[AJA_tbl_Roles] ON
INSERT [dbo].[AJA_tbl_Roles] ([RoleID], [RoleName]) VALUES (0, N'All Users')
INSERT [dbo].[AJA_tbl_Roles] ([RoleID], [RoleName]) VALUES (1, N'Administrator')
INSERT [dbo].[AJA_tbl_Roles] ([RoleID], [RoleName]) VALUES (2, N'AJA User')
SET IDENTITY_INSERT [dbo].[AJA_tbl_Roles] OFF

--AJA_tbl_UserRoles
insert into AJA_tbl_UserRoles 
select UserID,2 from AJA_tbl_Users



 UPDATE olduser
    SET typePractice = SUBSTRING(typePractice,1,LEN(typePractice)-1)
    from [User_01].[dbo].[Users] olduser 
    where olduser.typePractice not in
    (select tp.TypePractice from [User_01].[dbo].TypePractice tp)
  
  UPDATE newuser
  SET newuser.typePracticeID = tp.id  
  FROM  [AJA_tbl_Users] newuser, 
        [User_01].[dbo].[Users] olduser,
        [User_01].[dbo].TypePractice tp
  WHERE newuser.UserID = olduser.userID
    AND olduser.typePractice = tp.TypePractice
    
    
     IF NOT EXISTS (SELECT * FROM AJA.dbo.AJA_tbl_Users WHERE UserName = 'admin')
 BEGIN
  
  INSERT INTO [AJA].[dbo].[AJA_tbl_Users]
           ([EmailID]
           ,[UserName]
           ,[Password]
           ,[Activated]
           ,[CreatedDate]
           ,[UpdatedDate]
           ,[UpdatedBy]
           ,[Fname]
           ,[Lname]
           ,[Pincode]
           ,[specialtyID]
           ,[CountryID]
           ,[graduationYear]
           ,[profession]
           ,[typePracticeID]
           ,[UserTitle]
           ,[IseditorEmaiSend]
           ,[IsSavedAqemaisend]
           ,[deleted_ind]
           ,[surveyValidated]
           ,[userType]
           ,[yrsPractice])
     VALUES
           ('admin@test.com'
           ,'admin'
           ,'Welcome1!'
           ,1
           ,GETDATE()
           ,''
           ,''
           ,'admin'
           ,'admin'
           ,12345
           ,1
           ,2
           ,2013
           ,'Physician'
           ,1	
           ,'Mr.'
           ,1
           ,1
           ,''
           ,''
           ,''
           ,'')
  
  END

    Declare @userid int
  
 select @userid= userid from AJA.dbo.AJA_tbl_Users where UserName='admin' 
  Insert into AJA.dbo.AJA_tbl_UserRoles values(@userid,1)