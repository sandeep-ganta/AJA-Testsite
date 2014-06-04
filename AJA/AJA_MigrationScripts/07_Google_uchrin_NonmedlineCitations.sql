select * ,substring(ArticleTitle,0,charINDEX('</title>',ArticleTitle)), charINDEX('</title>',ArticleTitle)  from NonMedlineCitations 
where charINDEX('</title>',ArticleTitle) > 0



update NonMedlineCitations
set
ArticleTitle = substring(ArticleTitle,0,charINDEX('</title>',ArticleTitle))
where charINDEX('</title>',ArticleTitle) > 0


select * ,substring(Abstract,0,charINDEX('</title>',Abstract)), charINDEX('</title>',Abstract)  from NonMedlineCitations 
where charINDEX('</title>',Abstract) > 0



update NonMedlineCitations
set
Abstract = substring(Abstract,0,charINDEX('</title>',Abstract))
where charINDEX('</title>',Abstract) > 0