--*CRT: RUNSQLSTM COMMIT(*NONE) ERRLVL(30)            :*

set schema edidemos;

drop view productpricev1;
drop view inventoryv1;
drop view orderv1;
drop index customeri1;
drop index producti1;
drop table inventory;
drop table productprice;
drop table product;
drop table customer;
drop table order;
drop table orderitem;

-- Product Master
create table PRODUCT  (
  id          bigint not null generated always as identity primary key,
  name        char(30) not null,
  active      char(1) check (active in ('Y','N')) not null);

create unique index producti1 on product (name);

-- Product Price
create table PRODUCTPRICE (
  id          bigint not null generated always as identity
              primary key,
  productid   bigint not null,

  pricegroup char(10) not null,
  price       decimal(11, 5) not null default 0,
  constraint uk_product_price unique (productid, pricegroup),
  constraint fk_product_price foreign key (productid)
     references product (id) on delete cascade);

 create view productpricev1 as
   (select prc.productid, p.name as productName,
    prc.pricegroup, prc.price from
    product p join productprice prc on p.id = prc.productid);

-- Customer Master
create table CUSTOMER (
  id          bigint not null generated always as identity primary key,
  cstname     char(50) not null,
  addr1       char(50) not null,
  addr2       char(50) not null default ' ',
  city        char(50) not null,
  state       char(2) not null,
  zip         char(10) not null
  );

create unique index CUSTOMERI1 on customer (cstname);

-- Order
create table ORDER    (
  id          bigint not null generated always as identity primary key,
  referenceID  char(30) not null,
  customerID  bigint not null,
  ordertype   char(10) check(orderType in ('PO','SO')) not null,
  orderDate   date not null default current date,
  orderTime   time not null default current time,
  orderAmt    decimal(13,2) not null default 0,
  orderStatus char(10) check(orderStatus in ('NEW','SHIPPED','CANCELLED'))
              not null default 'NEW',
  constraint fk_customer_order foreign key (customerid)
     references customer (id) on delete cascade);

-- Order Item
create table ORDERITEM (
  id          bigint not null generated always as identity primary key,
  referenceID char(30) not null,
  orderID     bigint not null,
  productID   bigint not null,
  price       decimal(11,2) not null,
  quantity    decimal(7,0) not null,
  constraint fk_order_item     foreign key (orderID)
     references order    (id) on delete cascade,
  constraint fk_product_item   foreign key (productID)
     references product  (id) on delete cascade);

  create view orderv1 as (
  select a.id as orderid, a.referenceID, a.customerid, b.cstname,
  a.ordertype, a.orderdate, a.ordertime, a.orderstatus,
  c.id as lineID, c.referenceID as altLineID,c.productid,d.name as
  productName, price, quantity
  from order a join customer b on a.customerID = b.id
  join orderitem c on a.id = c.orderid
  join product d on c.productid = d.id );

-- Perpetual Inventory
create table INVENTORY  (
  id          bigint not null generated always as identity
              primary key,
  productid   bigint not null,
  storewhsid  bigint not null,
  locationid  bigint not null,
  bucket      char(20) not null,
  quantity    decimal(7, 0) not null,
  constraint uk_inventory unique (productid, storewhsid, locationid, bucket),
  constraint fk_product_inv   foreign key (productid)
     references product (id) on delete cascade);

create view inventoryv1    as
  (select inv.productid,  p.name as productName,
   inv.storewhsid, inv.locationid, inv.bucket, inv.quantity
   from product p join inventory inv on p.id = inv.productid);

-- Populate test data
 insert into product (name, active) values('TABLE', 'Y');
 insert into product (name, active) values('CHAIR', 'Y');
 insert into product (name, active) values('TV'   , 'Y');
 insert into product (name, active) values('9781138930230'   , 'Y');
 insert into product (name, active) values('9781138781818'   , 'Y');
 insert into product (name, active) values('9781138679337'   , 'Y');
 insert into product (name, active) values('9781138650053'   , 'Y');
 insert into product (name, active) values('9781138650039'   , 'Y');

 insert into productprice (productid, pricegroup, price)
 values (1, 'REGULAR', 100.00);
 insert into productprice (productid, pricegroup, price)
 values (1, 'SALE'   ,  80.00);
 insert into productprice (productid, pricegroup, price)
 values (2, 'REGULAR',  50.00);
 insert into productprice (productid, pricegroup, price)
 values (2, 'SALE'   ,  40.00);
 insert into productprice (productid, pricegroup, price)
 values (3, 'REGULAR', 500.00);
 insert into productprice (productid, pricegroup, price)
 values (3, 'SALE'   , 450.00);

 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 1, 1, 'ON HAND',10) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 1, 1, 'DISPLAY',1)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 1, 1, 'DAMAGED',2)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 1, 1, 'RESERVED',2) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 2, 1, 'ON HAND',20) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 2, 1, 'DISPLAY',2)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 2, 1, 'DAMAGED',3)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(1, 2, 1, 'RESERVED',3) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 1, 1, 'ON HAND',10) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 1, 1, 'DISPLAY',1)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 1, 1, 'DAMAGED',2)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 1, 1, 'RESERVED',2) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 2, 1, 'ON HAND',20) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 2, 1, 'DISPLAY',2)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 2, 1, 'DAMAGED',3)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(2, 2, 1, 'RESERVED',3) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 1, 1, 'ON HAND',10) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 1, 1, 'DISPLAY',1)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 1, 1, 'DAMAGED',2)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 1, 1, 'RESERVED',2) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 2, 1, 'ON HAND',20) ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 2, 1, 'DISPLAY',2)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 2, 1, 'DAMAGED',3)  ;
 insert into inventory (productid, storewhsid, locationid, bucket,
 quantity) values(3, 2, 1, 'RESERVED',3) ;

 insert into customer (cstname, addr1, city, state, zip) values(
 'GM','100 Ren Center','Detroit','MI','48243') ;
 insert into customer (cstname, addr1, city, state, zip) values(
 'Ford','1 American Rd','Dearborn','MI','48126') ;
 insert into customer (cstname, addr1, city, state, zip) values(
 'BIGRETAIL','123 Main St','Austin','TX','78714') ;

 insert into order (referenceID, customerID, orderType, orderAmt)  values(
   '10001',1,'PO',1000)  ;
 insert into order (referenceID, customerID, orderType, orderAmt)  values(
   '20001',2,'PO',2200)  ;

 insert into orderitem (referenceID,orderID, productID, price,quantity) values(
 '1',1,1,100,3);
 insert into orderitem (referenceID,orderID, productID, price,quantity) values(
 '2',1,2,200,5);
 insert into orderitem (referenceID,orderID, productID, price,quantity) values(
 '1',2,1,110,1);
 insert into orderitem (referenceID,orderID, productID, price,quantity) values(
 '2',2,3,500,1);
