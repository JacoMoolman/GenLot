# $file="C:\Apps\PSdemo\PastLottoNumsTEST.txt"
$file="E:\Projects\GENLOT\PastLottoNums.txt"
$outputfile="E:\Projects\GENLOT\LOTOUT.txt"

$NumberOfTicketsToPlay=20 #20
$NumberOfNumbersInLotto=6 #5
$PopulationNumerY=30 #30
$Mutation=49 #Out of 10
$MaxMutationValue=50

$POP = New-Object 'object[,,]' $PopulationNumerY,$NumberOfTicketsToPlay,$NumberOfNumbersInLotto
$POPWINS = New-Object 'object[,]' $PopulationNumerY,$NumberOfTicketsToPlay
$TOTALPOPWINS = New-Object 'object[]' $PopulationNumerY
$CURCHECKLOTNUMS = New-Object 'object[]' $PopulationNumerY
$BESTPOPS= New-Object 'object[]' 2
$COPYOFBESTPOPS = New-Object 'object[,,]' 2,$NumberOfTicketsToPlay,$NumberOfNumbersInLotto

$DB = Get-Content $file

$global:number
# $global:BESTPOP 
# $global:2BESTPOP


function GenNumber
{ 
    $number=Get-Random -Maximum 51 -Minimum 1
    return $number
}


function InitilizePop
{
    for ($i = 0 ; $i -le $PopulationNumerY-1; $i++)   # LOOP THROUGH POPULATION
    {
        Write-Host $i -ForegroundColor Blue
        for ($y = 0 ; $y -le $NumberOfTicketsToPlay-1; $y++) #LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {
            write-host " " $y " " -NoNewline -ForegroundColor Green
            for ($x = 0 ; $x -le $NumberOfNumbersInLotto-1; $x++)  #LOOP THROUGH THE NUMBERS IN EACH TICKET
            {
                $NewNumber=GenNumber
                # $NewNumber=1
                $POP[$i,$y,$x]=$NewNumber

                $COUNT=0
                 for ($q = 0 ; $q -le $NumberOfNumbersInLotto-1; $q++)  #LOOP THROUGH THE NUMBERS IN EACH TICKET AGAIN TO CHECK FOR DUPLICATES
                 {
                    if ($POP[$i,$y,$q] -eq $NewNumber)
                    {                        
                        $COUNT++
                        if ($COUNT -gt 1)
                        {
                            $NewNumber=GenNumber
                            $POP[$i,$y,$q]=$NewNumber
                            write-host "*" -NoNewline -ForegroundColor Yellow
                        }
                    }
                }
                Write-Host $POP[$i,$y,$x]"." -NoNewline -ForegroundColor Red
            }
        }
        Write-Host " "
    }
}

function ClearPOPWins
{
    for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
    {
        $TOTALPOPWINS[$POPNUM]=0
        for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
        {
            $POPWINS[$POPNUM,$TicketNum]=0
            # write-host $TOTALPOPWINS[$POPNUM]","$POPWINS[$POPNUM,$TicketNum]
        }
    }  
}


function CheckWinings 
{
    foreach ($Data in $DB)     #L1   LOOP THROUGH THE LIST OF PAST LOTTO NUMBERS
    {
        $Date, $Num1, $Num2, $Num3, $Num4, $Num5, $Num6 ,$Num7 = $Data -split ';'  
        $CURCHECKLOTNUMS[0]=$Num1;$CURCHECKLOTNUMS[1]=$Num2;$CURCHECKLOTNUMS[2]=$Num3;$CURCHECKLOTNUMS[3]=$Num4
        $CURCHECKLOTNUMS[4]=$Num5;$CURCHECKLOTNUMS[5]=$Num6;$CURCHECKLOTNUMS[6]=$Num7
        write-host
        write-host $CURCHECKLOTNUMS[0..6] -ForegroundColor Black -BackgroundColor Cyan -NoNewline
        write-host $Data -NoNewline -ForegroundColor Red
        
        
        for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
        {
            write-host $POPNUM -NoNewline -ForegroundColor Red
            for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
            {
                $POPWINS[$POPNUM,$PopTicket]=0
                write-host $PopTicket -NoNewline -ForegroundColor DarkBlue
                for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
                {
                    
                     write-host $POP[$POPNUM,$PopTicket,$TicketNum] -NoNewline -ForegroundColor DarkGreen
                    
                    for ($CheckLotnum = 0 ; $CheckLotnum -le $NumberOfNumbersInLotto; $CheckLotnum++) #L5 CHECK AGAINST EACH NUMBER IN THE LOTTO
                    {
                        
                        if ($CURCHECKLOTNUMS[$CheckLotnum] -eq $POP[$POPNUM,$PopTicket,$TicketNum])
                        {
                            $POPWINS[$POPNUM,$PopTicket]=$POPWINS[$POPNUM,$PopTicket]+1
                            write-host "#" -NoNewline -ForegroundColor Yellow
                        }
                    }
                }
            }
        }
    }
}


function CalcPopWins
{
    write-host ""
    for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
    {
        write-host $POPNUM -ForegroundColor Green -NoNewline

        for ($TicketNum = 0 ; $TicketNum -le $NumberOfTicketsToPlay-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
        {
            # write-host "POP#:"$POPNUM "TICKET#:"$TicketNum "WINS:"$POPWINS[$POPNUM,$TicketNum]
            write-host $POPWINS[$POPNUM,$TicketNum] -NoNewline -ForegroundColor Blue
            $TOTALPOPWINS[$POPNUM]=$TOTALPOPWINS[$POPNUM]+$POPWINS[$POPNUM,$TicketNum]
        }
        # write-host 
    }  


}


function CalcBestPops
{
    $BEST=0;$2NDBEST=0;$BESTPOPS[0]=0;$BESTPOPS[1]=0

#### CALULATE BEST AND SECOND BEST POPULATION
for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
{
    if ($TOTALPOPWINS[$POPNUM] -gt $BEST)
    {
        $BEST=$TOTALPOPWINS[$POPNUM]
        $BESTPOPS[0]=$POPNUM
    }

    if (($TOTALPOPWINS[$POPNUM] -gt $2NDBEST) -and ($TOTALPOPWINS[$POPNUM] -lt $BEST))
    {
        $2NDBEST=$TOTALPOPWINS[$POPNUM]
        $BESTPOPS[1]=$POPNUM
    }
    # write-host "POP:"$POPNUM "TOTAL WINS:"$TOTALPOPWINS[$POPNUM]
}

write-host""
write-host "BESTPOP:"$BESTPOPS[0] " with "$BEST" winnings" -ForegroundColor Red
Add-Content -Path $outputfile -Value $RunCount":"$BEST
write-host "2BESTPOP:"$BESTPOPS[1]" with "$2NDBEST" winnings" -ForegroundColor Blue
}


function DisplayBESTPOPNumbers
{
    write-host ""
    write-host "BEST NUMBERS of POP" $BESTPOPS[0]
    for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
    {
        for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
        {
            write-host $POP[$BESTPOPS[0],$PopTicket,$TicketNum]" " -NoNewline -ForegroundColor DarkCyan
        }
        write-host
    }
    
    # write-host ""
    # write-host "SECOND BEST NUMBERS of POP" $BESTPOPS[1]    
    # for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
    # {
    #     for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
    #     {
    #         write-host $POP[$BESTPOPS[1],$PopTicket,$TicketNum]" " -NoNewline
    #     }
    #     write-host
    # }
}



function CopyOutBestAndSecondBest
{
    for ($WINPOPNUM = 0 ; $WINPOPNUM -le 1; $WINPOPNUM++)  #2 LOOP THROUGH POPULATION
    {
        # write-host "WINPOPWIN" $WINPOPNUM
        # write-host $BESTPOPS[$WINPOPNUM]
        for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {
            for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
            {
                # write-host "COPY"
                $COPYOFBESTPOPS[0,$PopTicket,$TicketNum]=$POP[$BESTPOPS[$WINPOPNUM],$PopTicket,$TicketNum]
                write-host $COPYOFBESTPOPS[0,$PopTicket,$TicketNum]" " -NoNewline
                # write-host $POP[$BESTPOPS[$WINPOPNUM],$PopTicket,$TicketNum]
            }
            write-host
        }
    }
}




function DoTheMatingDanceRandomSplit
{
    write-host "MATING POP " $BESTPOPS[0] "WITH " $BESTPOPS[1]
    write-host ""
    for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
    {
        
        $MALEFAMLE=Get-Random -Maximum 2 -Minimum 0


        for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {        
            $WHERE2SPLIT=Get-Random -Maximum $NumberOfTicketsToPlay -Minimum 1
            for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
            {
                $POP[$POPNUM,$PopTicket,$TicketNum]=$COPYOFBESTPOPS[$MALEFAMLE,$WHERE2SPLIT,$TicketNum]
            }
        }
    }

}


function DoTheMatingDanceOnlyBest
{
    write-host "BEST POP is " $BESTPOPS[0]
    for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
    {
        for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {
            for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
            {
                # $POP[$POPNUM,$PopTicket,$TicketNum]=$COPYOFBESTPOPS[$BESTPOPS[0],$PopTicket,$TicketNum]
                $POP[$POPNUM,$PopTicket,$TicketNum]=$POP[$BESTPOPS[0],$PopTicket,$TicketNum]
                # write-host "M:"$POP[$POPNUM,$PopTicket,$TicketNum]
            } 
        }
    }
}



function DisplayPoPNumbers
{
    Write-host "JUST MAKING THE BEST POP ALL POP"
    for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
    {
        Write-host "POP NUMBER:" $POPNUM
        for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {        
            write-host "POP TICKET:" $PopTicket "::" -NoNewline
            for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
            {
                write-host $POP[$POPNUM,$PopTicket,$TicketNum]" " -NoNewline
            }
            write-host
        }
        write-host
    }

}



function AddMutation
{
    for ($POPNUM = 0 ; $POPNUM -le $PopulationNumerY-1; $POPNUM++)  #2 LOOP THROUGH POPULATION
    {
        # write-host $POPNUM
        for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {
            for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
            {
                # $NewMutNumber=Get-Random -Maximum 51 -Minimum 1
                $MutationChance=Get-Random -Maximum $MaxMutationValue -Minimum 0;# write-host $MutationChance
                if ($MutationChance -lt $Mutation)
                {
                    $NewMutNumber=GenNumber; #write-host "NewMutation is" $NewMutNumber
                    for ($q = 0 ; $q -le $NumberOfNumbersInLotto-1; $q++)  #LOOP THROUGH THE NUMBERS IN EACH TICKET AGAIN TO CHECK FOR DUPLICATES
                    {
                        if ($POP[$POPNUM,$PopTicket,$q] -eq $NewMutNumber)
                        {                
                            # write-host "Found Same " $POP[$POPNUM,$PopTicket,$q] ":" $NewMutNumber       
                            $NewMutNumber=GenNumber
                            $POP[$POPNUM,$PopTicket,$q]=$NewMutNumber
                       }
                   }  
                #    write-host "Mutated "$POP[$POPNUM,$PopTicket,$TicketNum]" to "$NewMutNumber -ForegroundColor DarkBlue              
                }
            } 
        }
    }
}


Function WriteBestPopToFile
{   
        # Write-host "POP NUMBER:" $POPNUM
        for ($PopTicket = 0 ; $PopTicket -le $NumberOfTicketsToPlay-1; $PopTicket++) #L3  LOOP THROUGH THE NUMBER OF TICKETS OF EACH POP MEMBER
        {        
            # write-host "POP TICKET:" $PopTicket "::" -NoNewline
            $TmpTickLine=""
            for ($TicketNum = 0 ; $TicketNum -le $NumberOfNumbersInLotto-1; $TicketNum++) #L4 EACH TICKET NUMBER FOR EACH POP's RANGE OF TICKETS
            {
                $TmpTickLine=$TmpTickLine+$POP[$BESTPOPS[0],$PopTicket,$TicketNum]+" "
                # Set-Content -Path $outputfile -Value $POP[$POPNUM,$PopTicket,$TicketNum]
                write-host $POP[$POPNUM,$PopTicket,$TicketNum]" " -NoNewline -ForegroundColor Blue
            }
            Add-Content -Path $outputfile -Value $TmpTickLine
        }
        # write-host " " | Out-File -FilePath $outputfile
}






# RANDOM SPLIT 
# RANDOM ACROSS THE BOARD
# EVERY SECOND ONE

InitilizePop

Clear-Content -Path $outputfile -Force

$RunCount=0
while (1 -gt 0)
{

    # Clear-Host
    # Clear-Content -Path $outputfile -Force

    write-host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    $RunCount++
    write-host
    write-host "                                                                                           RUN COUNT:" $RunCount -ForegroundColor Yellow
    write-host
    # Add-Content -Path $outputfile -Value $RunCount
    ClearPOPWins
    CheckWinings
    CalcPopWins
    CalcBestPops

    # DisplayBESTPOPNumbers

    # CopyOutBestAndSecondBest

    #NEW POP
                # DoTheMatingDanceRandomSplit
    DoTheMatingDanceOnlyBest

    AddMutation

    DisplayBESTPOPNumbers
    # WriteBestPopToFile
    # DisplayPoPNumbers
    # Start-Sleep 1
}




