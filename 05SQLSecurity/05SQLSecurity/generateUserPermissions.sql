/*
	To Extract User Database Permissions from a Database on SQL Server
*/

/*
CREATE USER [generateUserPermissions]
	WITHOUT LOGIN
	WITH DEFAULT_SCHEMA = dbo

GO

GRANT CONNECT TO [generateUserPermissions]
*/
/*
use [YourDB]
go
*/
set nocount off

IF OBJECT_ID(N'tempdb..##temp1') IS NOT NULL
     DROP TABLE ##temp1
  
create table ##temp1(query varchar(1000))

insert into ##temp1 
select 'use '+db_name() +';'

insert into ##temp1 
select 'go'

/*creating database roles*/
insert into ##temp1
                    select 'if DATABASE_PRINCIPAL_ID('''+name+''')  is null 
                    exec sp_addrole '''+name+''''  from sysusers
where issqlrole = 1 and (sid is not null and sid <> 0x0)

/*creating application roles*/
insert into ##temp1
                    select 'if DATABASE_PRINCIPAL_ID('+char(39)+name+char(39)+')
                    is null CREATE APPLICATION ROLE ['+name+'] WITH DEFAULT_SCHEMA = ['+
                    default_schema_name+'], Password='+char(39)+'Pass$w0rd123'+char(39)+' ;'
 from sys.database_principals
where type_desc='APPLICATION_ROLE'

insert into ##temp1 
                     select  
                                case  
                                          when state_desc='GRANT_WITH_GRANT_OPTION' 
                                                       then
                                                                substring (state_desc,0,6)+' '+permission_name+' to '+'['+USER_NAME(grantee_principal_id)+']'+' WITH GRANT OPTION ;'
                                                                
                                                         else 
                                                                  state_desc+' '+permission_name+' to '+'['+USER_NAME(grantee_principal_id)+']'+' ;'
                    END
from sys.database_permissions 
where class=0 and USER_NAME(grantee_principal_id) not in ('dbo','guest','sys','information_schema')

insert into ##temp1 
                    select 
                               case 
                                         when state_desc='GRANT_WITH_GRANT_OPTION' 
                                                   then
                                                             substring (state_desc,0,6)+' '+permission_name+' on '+OBJECT_SCHEMA_NAME(major_id)+'.['+OBJECT_NAME(major_id)
                                                             +'] to '+'['+USER_NAME(grantee_principal_id)+']'+' with grant option ;'
                                                     else 
                                                              state_desc+' '+permission_name+' on '+OBJECT_SCHEMA_NAME(major_id)+'.['+OBJECT_NAME(major_id)
                                                              +'] to '+'['+USER_NAME(grantee_principal_id)+']'+' ;'
                                  end
from sys.database_permissions where class=1 and USER_NAME(grantee_principal_id) not in ('public');


 insert into ##temp1 
                      select 
                                 case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION' 
                                                     then
                                                              substring (state_desc,0,6)+' '+permission_name+' ON schema::['+sa.name+
                                                               '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                                       else
                                                               state_desc+' '+permission_name+' ON schema::['+sa.name+
                                                               '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                       COLLATE LATIN1_General_CI_AS  
                                      end
from sys.database_permissions dp inner join sys.schemas sa on
 sa.schema_id = dp.major_id where dp.class=3

 insert into ##temp1 
                     select 
                                 case 
                                            when state_desc='GRANT_WITH_GRANT_OPTION'
                                             then
                                                    substring (state_desc,0,6)+' '+permission_name+' ON APPLICATION  ROLE::['+sa.name+
                                                     '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                             else
                                                      state_desc+' '+permission_name+' ON  APPLICATION ROLE::['+sa.name+
                                                      '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                      COLLATE LATIN1_General_CI_AS  
                         end
from sys.database_permissions dp inner join sys.database_principals  sa on
 sa.principal_id = dp.major_id where dp.class=4 and sa.type='A'

 insert into ##temp1 
                      select 
                                 case 
                                          when state_desc='GRANT_WITH_GRANT_OPTION' 
                                           then
                                                  substring (state_desc,0,6)+' '+permission_name+' ON   ROLE::['+sa.name+
                                                  '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                           else
                                                   state_desc+' '+permission_name+' ON   ROLE::['+sa.name+
                                                    '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                     COLLATE LATIN1_General_CI_AS  
                                           end
 from sys.database_permissions dp inner join
sys.database_principals  sa on sa.principal_id = dp.major_id 
 where dp.class=4 and sa.type='R'

 insert into ##temp1 
                      select 
                                  case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION' 
                                                       then
                                                               substring (state_desc,0,6)+' '+permission_name+' ON ASSEMBLY::['+sa.name+
                                                                '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                                        else
                                                                state_desc+' '+permission_name+' ON ASSEMBLY::['+sa.name+
                                                                 '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                                 COLLATE LATIN1_General_CI_AS  
                                       end
 from sys.database_permissions dp inner join sys.assemblies sa on
 sa.assembly_id = dp.major_id 
 where dp.class=5

 insert into ##temp1
                     select 
                                 case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION' 
                                            then
                                                    substring (state_desc,0,6)+'  '+permission_name+' ON type::['
                                                    +SCHEMA_NAME(schema_id)+'].['+sa.name+
                                                    '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                            else
                                                    state_desc+' '+permission_name+' ON type::['
                                                    +SCHEMA_NAME(schema_id)+'].['+sa.name+
                                                     '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                     COLLATE LATIN1_General_CI_AS  
                                              end
 from sys.database_permissions dp inner join sys.types sa on
 sa.user_type_id = dp.major_id 
 where dp.class=6


 insert into ##temp1
                      select 
                                 case 
                                          when state_desc='GRANT_WITH_GRANT_OPTION' 
                                           then
                                                     substring (state_desc,0,6)+'  '+permission_name+' ON  XML SCHEMA COLLECTION::['+
                                                     SCHEMA_NAME(SCHEMA_ID)+'].['+sa.name+'] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                            else
                                                     state_desc+' '+permission_name+' ON  XML SCHEMA COLLECTION::['+
                                                     SCHEMA_NAME(SCHEMA_ID)+'].['+sa.name+'] to ['+user_name(dp.grantee_principal_id)+'];'
                                                     COLLATE LATIN1_General_CI_AS  
                                   end
 from sys.database_permissions dp inner join sys.xml_schema_collections sa on
 sa.xml_collection_id = dp.major_id 
 where dp.class=10



insert into ##temp1
                    select
                               case 
                                         when state_desc='GRANT_WITH_GRANT_OPTION' 
                                          then
                                                   substring (state_desc,0,6)+'  '+permission_name+' ON message type::['+sa.name+
                                                    '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                           else
                                                    state_desc+' '+permission_name+' ON message type::['+sa.name+
                                                    '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                     COLLATE LATIN1_General_CI_AS  
                                             end
 from sys.database_permissions dp inner join sys.service_message_types sa on
 sa.message_type_id = dp.major_id 
 where dp.class=15


 insert into ##temp1
                      select 
                                  case 
                                            when state_desc='GRANT_WITH_GRANT_OPTION' 
                                              then
                                                       substring (state_desc,0,6)+'  '+permission_name+' ON contract::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                                else
                                                         state_desc+' '+permission_name+' ON contract::['+sa.name+
                                                         '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                         COLLATE LATIN1_General_CI_AS  
                                   end
 from sys.database_permissions dp inner join sys.service_contracts sa on
 sa.service_contract_id = dp.major_id 
 where dp.class=16



  insert into ##temp1
                      select 
                                 case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION' 
                                            then
                                                      substring (state_desc,0,6)+'  '+permission_name+' ON SERVICE::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                              else
                                                       state_desc+'  '+permission_name+' ON SERVICE::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                        COLLATE LATIN1_General_CI_AS  
                                    end
 from sys.database_permissions dp inner join sys.services sa on
 sa.service_id = dp.major_id 
 where dp.class=17


 insert into ##temp1 
                      select 
                                   case 
                                              when state_desc='GRANT_WITH_GRANT_OPTION'
                                               then
                                                          substring (state_desc,0,6)+'  '+permission_name+' ON REMOTE SERVICE BINDING::['+sa.name+
                                                          '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                                 else
                                                          state_desc+' '+permission_name+' ON REMOTE SERVICE BINDING::['+sa.name+
                                                           '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                          COLLATE LATIN1_General_CI_AS  
                                      end
 from sys.database_permissions dp inner join sys.remote_service_bindings sa on
 sa.remote_service_binding_id = dp.major_id 
 where dp.class=18

 insert into ##temp1
                      select
                                  case 
                                            when state_desc='GRANT_WITH_GRANT_OPTION'
                                              then
                                                        substring (state_desc,0,6)+'  '+permission_name+' ON route::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                                else
                                                          state_desc+' '+permission_name+' ON route::['+sa.name+
                                                          '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                         COLLATE LATIN1_General_CI_AS  
                                      end
 from sys.database_permissions dp inner join sys.routes sa on
 sa.route_id = dp.major_id 
 where dp.class=19

 insert into ##temp1 
                      select 
                                 case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION' 
                                            then
                                                     substring (state_desc,0,6)+'  '+permission_name+' ON FULLTEXT CATALOG::['+sa.name+
                                                      '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                             else
                                                       state_desc+' '+permission_name+' ON FULLTEXT CATALOG::['+sa.name+
                                                       '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                        COLLATE LATIN1_General_CI_AS  
                                       end
 from sys.database_permissions dp inner join sys.fulltext_catalogs sa on
 sa.fulltext_catalog_id = dp.major_id 
 where dp.class=23

  insert into ##temp1 
                      select 
                                 case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION'
                                            then
                                                        substring (state_desc,0,6)+'  '+permission_name+' ON SYMMETRIC KEY::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                             else
                                                        state_desc+' '+permission_name+' ON SYMMETRIC KEY::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                        COLLATE LATIN1_General_CI_AS  
                                             end
 from sys.database_permissions dp inner join sys.symmetric_keys sa on
 sa.symmetric_key_id = dp.major_id 
 where dp.class=24

 insert into ##temp1 
                      select 
                                  case 
                                           when state_desc='GRANT_WITH_GRANT_OPTION' 
                                             then
                                                       substring (state_desc,0,6)+'  '+permission_name+' ON certificate::['+sa.name+
                                                        '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                               else
                                                          state_desc+' '+permission_name+' ON certificate::['+sa.name+
                                                          '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                           COLLATE LATIN1_General_CI_AS  
                                   end
 from sys.database_permissions dp inner join sys.certificates sa on
 sa.certificate_id = dp.major_id 
 where dp.class=25


 insert into ##temp1 
                     select 
                                 case 
                                          when state_desc='GRANT_WITH_GRANT_OPTION' 
                                          then
                                                     substring (state_desc,0,6)+'  '+permission_name+' ON ASYMMETRIC KEY::['+sa.name+
                                                     '] to ['+user_name(dp.grantee_principal_id)+'] with grant option ;'
                                             else
                                                      state_desc+' '+permission_name+' ON ASYMMETRIC KEY::['+sa.name+
                                                       '] to ['+user_name(dp.grantee_principal_id)+'] ;'
                                                       COLLATE LATIN1_General_CI_AS  
                        end
 from sys.database_permissions dp inner join sys.asymmetric_keys sa on
 sa.asymmetric_key_id = dp.major_id 
 where dp.class=26

insert into ##temp1 
                     select  'exec sp_addrolemember ''' +p.NAME+''','+'['+m.NAME+']'+' ;'
FROM sys.database_role_members rm
JOIN sys.database_principals p
ON rm.role_principal_id = p.principal_id
JOIN sys.database_principals m
ON rm.member_principal_id = m.principal_id
where m.name not like 'dbo';




 
select *  from ##temp1  