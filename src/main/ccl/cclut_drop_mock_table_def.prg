drop program cclut_drop_mock_table_def:dba go
create program cclut_drop_mock_table_def:dba

/**
  A prompt program to drop the table definition for a CCL Unit mock table.
  @arg (vc) 
    The output destination for the results.
    @default MINE
  @arg (vc) 
    The name of the mock table to be dropped.
*/
prompt
    "Output destination [MINE]: " = "MINE", 
    "Table Name: " = ""

with outputDestination, tableName

declare public::dropTable(cclutTableName = vc) = null with protect
declare public::main(null) = null with protect

record cclutDropMockTableReply (1 status = c1 1 message = vc) with protect

if (validate(_memory_reply_string) = FALSE)
    declare _memory_reply_string = vc with protect, noconstant("")
endif
    
subroutine public::dropTable(cclutTableName)
    declare cclutErrorCode = i4 with protect, noconstant(0)
    declare cclutErrorMessage = vc with protect, noconstant("")
    if(cclutTableName = "CUST_CCLUT*")
        call parser(concat(" drop table ", cclutTableName, " go"))
        set cclutErrorCode = error(cclutErrorMessage, 0)
        if (cclutErrorCode = 0)
            set cclutDropMockTableReply->status = "S"
            set cclutDropMockTableReply->message = concat("Table ", cclutTableName, " was dropped")
        else
            set cclutErrorMessage = concat("Failed to drop table ", cclutTableName, char(10), char(13), cclutErrorMessage)
            set cclutDropMockTableReply->status = "F"
            set cclutDropMockTableReply->message = cclutErrorMessage
            call echo(cclutErrorMessage) ;intentional
        endif
    else
        set cclutErrorMessage = "Only CCL Unit mock tables can be dropped with this program"
        set cclutDropMockTableReply->status = "F"
        set cclutDropMockTableReply->message = cclutErrorMessage
        call echo(cclutErrorMessage) ;intentional
    endif
end ;cclutDropTableDefinition::dropTable

subroutine public::main(null)
    call dropTable($tableName)
end ;cclutDropTableDefinition::main

call main(null)

set _memory_reply_string = cnvtrectojson(cclutDropMockTableReply)

end go