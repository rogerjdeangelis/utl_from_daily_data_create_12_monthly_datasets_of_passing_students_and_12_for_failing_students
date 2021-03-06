From daily data create 12 monthly datasets of passing students and 12 datasets for failing students

Two Solutions

    1. DOSUBL
    2. DO_OVER

Paradigm shift - see old way on SAS Forum.

It seems like google and others are dropping 'open' URL shorteners?

https://communities.sas.com/t5/Base-SAS-Programming/deleting-and-keeping-observation-in-tables/m-p/466159/highlight/true#M118929


INPUT  (note data may not be sequential like this however months are grouped)
=============================================================================

  HAVE total obs=730

   Obs           DT    STATUS

     1    01JAN2008     fail
     2    01JAN2008     pass
     3    02JAN2008     fail
     4    02JAN2008     pass
     5    03JAN2008     fail
     ...

    59    30JAN2008     fail
    60    30JAN2008     pass
    61    31JAN2008     fail
    62    31JAN2008     pass
     ...
    63    01FEB2008     fail
    64    01FEB2008     pass
    65    02FEB2008     fail
    66    02FEB2008     pass
    67    03FEB2008     fail
    68    03FEB2008     pass
    ...

   115    27FEB2008     fail
   116    27FEB2008     pass
   117    28FEB2008     fail
   118    28FEB2008     pass
   119    29FEB2008     fail
   120    29FEB2008     pass
   ...


 EXAMPLE OUTPUT

   (separate pass and fail monthly datasets)


  WORK.FAIL_2008_01 (January 2008 Failing Students) Obs=31

   Obs           DT    STATUS

     1    01JAN2008     fail
     3    02JAN2008     fail
     ...

    60    30JAN2008     fail
    62    31JAN2008     fail



  WORK.PASS_2008_01 (January 2008 Passing Students) Obs=31

   Obs           DT    STATUS

     2    01JAN2008     pass
     4    02JAN2008     pass
     ...

    60    30JAN2008     pass
    62    31JAN2008     pass


 LOG for Job Status
 WORK.LOG total obs=12

   YYMM      FAIL_DATASET       PASS_DATASET

  201701    Dataset Created    Dataset Created
  201702    Dataset Created    Dataset Created
  201703    Dataset Created    Dataset Created
  201704    Dataset Created    Dataset Created
  201705    Dataset Created    Dataset Created
  201706    Dataset Created    Dataset Created
  201707    Dataset Created    Dataset Created
  201708    Dataset Created    Dataset Created
  201709    Dataset Created    Dataset Created
  201710    Dataset Created    Dataset Created
  201711    Dataset Created    Dataset Created
  201712    Dataset Created    Dataset Created


PROCESS
=======

 1. DOSUBL (SAS needs to upgrade compliler)

  data log;

    format dt yymm6.;

    set have;

    by dt groupformat notsorted;

    yymm=put(dt,yymmn6. -l) ;
    call symputx('yymm',yymm);

    if last.dt then do;
      rc=dosubl('
       data fail_&yymm. pass_&yymm.;
          set have(where=(put(dt,yymmn6. -l)="&yymm"));
          if status="fail" then output fail_&yymm;
          else output pass_&yymm;
       run;quit;
      ');

      if rc=0 then do;
            fail="Dataset Created";
            pass="Dataset Created";
            output;
      end;
      else do
            pass="Error";
            fail="Error";
            output;
      end;
      keep yymm fail pass;
    end;

  run;quit;

2. DO_OVER

  proc sql;
     select distinct(put(dt,yymmn.6 -l)) into :yymm separated by " " from have
  ;quit;

  data

    %array(dsns,values=&yymm)
    %do_over(dsns,phrase=fail_? pass_?)
    ;

    set have;

    if status="fail" then do;
       %do_over(dsns,phrase=%str(if put(dt,yymmn6.)="?" then output Fail_?;),between=else)
    end;

    else if status="pass" then do;
       %do_over(dsns,phrase=%str(if put(dt,yymmn6.)="?" then output Pass_?;),between=else)
    end;

  run;quit;

OUTPUT
======

   WORK.FAIL_2008_01 (January 2008 Failing Students) Obs=31

   Obs           DT    STATUS

     1    01JAN2008     fail
     3    02JAN2008     fail
     ...

    60    30JAN2008     fail
    62    31JAN2008     fail



   WORK.FAIL_2008_02 (January 2008 Passing Students) Obs=31

   Obs           DT    STATUS

     2    01JAN2008     pass
     4    02JAN2008     pass
     ...

    60    30JAN2008     pass
    62    31JAN2008     pass

  NOTE: There were 730 observations read from the data set WORK.HAVE.
  NOTE: The data set WORK.FAIL_201701 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201701 has 31 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201702 has 28 observations and 2 variables.
  NOTE: The data set WORK.PASS_201702 has 28 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201703 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201703 has 31 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201704 has 30 observations and 2 variables.
  NOTE: The data set WORK.PASS_201704 has 30 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201705 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201705 has 31 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201706 has 30 observations and 2 variables.
  NOTE: The data set WORK.PASS_201706 has 30 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201707 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201707 has 31 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201708 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201708 has 31 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201709 has 30 observations and 2 variables.
  NOTE: The data set WORK.PASS_201709 has 30 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201710 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201710 has 31 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201711 has 30 observations and 2 variables.
  NOTE: The data set WORK.PASS_201711 has 30 observations and 2 variables.
  NOTE: The data set WORK.FAIL_201712 has 31 observations and 2 variables.
  NOTE: The data set WORK.PASS_201712 has 31 observations and 2 variables.

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;
  data have;
    format dt date9.;
     do dt='01JAN2017'd to '31DEC2017'd;
      status='fail'; output;
      status='pass'; output;
    end;
  run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process

