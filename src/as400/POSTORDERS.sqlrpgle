     H DEBUG DATFMT(*ISO)
     H*================================================================
     H*  C R E A T I O N     P A R A M E T E R S                      *
     H*CRT:  CRTSQLRPGI dbgview(*source) commit(*none)               :*
     H*================================================================
     H AlwNull(*UsrCtl)

     fcustomeri1if   e           k disk    rename(CUSTOMER:CUSTOMERR)
     f                                     prefix('C_')
     fproducti1 if   e           k disk    rename(PRODUCT:PRODUCTR)
     f                                     prefix('P_')

     d main            pr                  extpgm('POSTORDERS')
     d  orderID                      30a
     d  customerName                 50a
     d  orderType                    10a
     d  orderDate                      d
     d  orderTime                      t
     d  orderStatus                  10a
     d  orderLines                         likeds(linesFmt) dim(10)
     d  erpOrderID                   30a
     d  returnCd                      3p 0
     d  returnMsg                   254a

     d linesFmt        DS                  Dim(10) qualified
     d   refID                       30a
     d   product                     30a
     d   price                       14p 4
     d   qty                         11p 3
     d   category                    30a
     d   division                    30a

     d i               s              2s 0
     d id              s                   like(c_id)
     d s_refID         s             30a
     d s_qty           s             11p 3
     d s_price         s             14p 4

     d main            pi
     d  orderID                      30a
     d  customerName                 50a
     d  orderType                    10a
     d  orderDate                      d
     d  orderTime                      t
     d  orderStatus                  10a
     d  orderLines                         likeds(linesFmt) dim(10)
     d  erpOrderID                   30a
     d  returnCd                      3p 0
     d  returnMsg                   254a

      /free
        dump(a);
        returnCd = 0;
        returnMsg = 'Order created successfully';
        // check customer
        chain customerName customerR;
        if not %found;
          returnCd = -1;
          returnMsg = 'Customer ' + %trim(customerName) + ' not found';
          return;
        endif;
        // check product
        for i = 1 to 10;
          if orderLines(i).product <> *blanks;
            setll orderLines(i).product productR;
            if not %equal;
              returnCd = -1;
              returnMsg = 'Product ' + %trim(orderLines(i).product) +
                          ' not found';
              return;
            endif;
          endif;
        endfor;
        // insert orders
        exec sql
          insert into ORDER (referenceID, customerID, orderType,
             orderDate, orderTime, orderStatus)
          values (:orderID, :C_ID, :orderType, :orderDate, :orderTime,
              :orderStatus);
        exec sql
          values identity_val_local() into :id;
        erpOrderID = %char(id);

        for i = 1 to 10;
          if orderLines(i).product <> *blanks;
            chain orderLines(i).product productr;
            s_refID = orderLines(i).refID;
            s_qty   = orderLines(i).qty  ;
            s_price = orderLines(i).price;
            exec sql
              insert into orderitem (referenceID, orderID, productID,
              price, quantity) values (:s_refID,
              :id, :p_id,:s_price, :s_qty);
          endif;
        endfor;
        return; // *inlr = *on;
      /end-free

