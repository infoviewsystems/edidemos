     H DEBUG DATFMT(*ISO)
     H*================================================================
     H*  C R E A T I O N     P A R A M E T E R S                      *
     H*CRT: CRTBNDRPG                DFTACTGRP(*NO) ACTGRP(*CALLER) +:*
     H*CRT:  dbgview(*all) option(*nodebugio)                        :*
     H*
     H*     Add trigger to order status file:
     H*
     H*  ADDPFTRG FILE(EDIDEMOS/order)      TRGTIME(*AFTER) TRGEVENT(*UPDATE)
     H*     PGM(edidemos/ordststrg) TRG(ORDSTSTRG_UPDATE)
     H*
     H*
     H*================================================================
     H*
     H* Description:    Mule EDI demo - order status change trigger
     H*                 For this demo it will only fire on INSERT or
     H*                 status change
     H*
     H* Author :        Dmitriy Kuznetsov__________
     H* Creation date:  09/19/2018
     H*
       // Main procedure interface
     D Main            PR                  EXTPGM('ORDSTSTRG')
     D  Trgbuffer                          LIKEDS(Trginfo)
     D  Trgbufferlen                 10I 0

     d crttrn          pr                  extpgm('CRTTRN')
     d  transType                    10    const options(*nopass)
     d  altTrnID                     30    const options(*nopass)
     d  reqData                     254a   const options(*nopass)
     d  transID                      20i 0       options(*nopass)
     d  returnCd                      3s 0       options(*nopass)
     d  returnMsg                   254          options(*nopass)

     d transID         s             20i 0
     d c#trnType       s             10    inz('EDIDEMO')
     d returnCd        s              3s 0
     d returnMsg       s            254


     D Main            PI
     D  Trgbuffer                          LIKEDS(Trginfo)
     D  Trgbufferlen                 10I 0

       // Constants
       // Possible values for Event
     D Insert          C                   '1'
     D Delete          C                   '2'
     D Update          C                   '3'
     D Read            C                   '4'

       // Possible values for Time
     D After           C                   '1'
     D Before          C                   '2'

       // Possible values for Commitlocklev
     D Cmtnone         C                   '0'
     D Cmtchange       C                   '1'
     D Cmtcs           C                   '2'
     D Cmtall          C                   '3'

       // Trigger buffer information
     D Trginfo         DS
     D  File                         10
     D  Library                      10
     D  Member                       10
     D  Event                         1
     D  Time                          1
     D  Commitlocklev                 1
     D                                3
     D  Ccsid                        10I 0
     D  Rrn                          10I 0
     D                                4
     D  Befrecoffset                 10I 0
     D  Befreclen                    10I 0
     D  Befnulloffset                10I 0
     D  Befnulllen                   10I 0
     D  Aftrecoffset                 10I 0
     D  Aftreclen                    10I 0
     D  Aftnulloffset                10I 0
     D  Aftnulllen                   10I 0

       // "Before" record image
     D Befrecptr       S               *
     D old           E DS                  Extname(ORDER)
     D                                     Based(Befrecptr)
     D                                     Qualified

       // "After" record image
     D Aftrecptr       S               *
     D new           E DS                  Extname(ORDER)
     D                                     Based(Aftrecptr)
     D                                     Qualified

      /Free
       Befrecptr = %ADDR(Trgbuffer) + Trgbuffer.Befrecoffset;
       Aftrecptr = %ADDR(Trgbuffer) + Trgbuffer.Aftrecoffset;

         select;
         when TRGBUFFER.EVENT = Insert;
              callp(e) crttrn(c#trntype:*blanks:
                     'INSERT,' + %char(new.ID)     + ',' +
                     new.REFER00001   + ',' + old.ORDER00001
                     + ',' + new.ORDER00001 :
                     transID:returnCd:returnMsg);
         when TRGBUFFER.EVENT = Update and
              (new.ORDER00001  <> old.ORDER00001);
              callp(e) crttrn(c#trntype:*blanks:
                     'UPDATE,' + %char(new.ID)     + ',' +
                     new.REFER00001   + ',' + old.ORDER00001
                     + ',' + new.ORDER00001 :
                     transID:returnCd:returnMsg);
         endsl;
       // close files
       callp(e) crttrn();
       *inlr = *on;
       Return;

      /End-free
