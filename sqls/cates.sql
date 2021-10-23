create table kouhou.cates (
       id                 int  auto_increment not null,
       cate               text                not null,
       ena_flg            int                 not null default 1,
       del_flg            int                 not null default 0,
       reg_time           timestamp           not null default current_timestamp,
       upd_time           timestamp           not null default current_timestamp on update current_timestamp,
       primary key(id)
 );
