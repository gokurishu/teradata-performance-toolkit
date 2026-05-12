SELECT
DataBaseName,            
TableName,                 
Version,                       
TableKind,                    
ProtectionType,                
JournalFlag,                   
CreatorName,                                                    
CreateTimeStamp,               
LastAlterName,                 
LastAlterTimeStamp,            
AccessCount,                   
LastAccessTimeStamp           

FROM DBC.TABLESV

WHERE DATABASENAME=''
AND
TABLENAME='';






SEL * FROM DBC.DATABASES
WHERE
DATABASENAME='STG_OER_T';
